import 'dart:async';

import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../../../core/bluetooth/models/ble_signal.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/platform/unity_message.dart';
import '../../domain/models/story_checkpoint.dart';
import '../../domain/models/story_progress.dart';
import '../../domain/repositories/story_repository.dart';

class StoryBridgeService {
  StoryBridgeService({
    required Stream<UnityMessage> unityMessages,
    required Future<void> Function(UnityMessage message) sendToUnity,
    required Future<void> Function() showUnity,
    required Future<void> Function() showFlutter,
    required Future<void> Function() initUnityEngine,
    required StoryRepository storyRepository,
    required BleSignalArbitrator signalArbitrator,
    required void Function(String characterId, String storyId)
    invalidateStoryProgress,
    required void Function(String storyId) invalidateStoryCheckpoints,
  }) : _sendToUnity = sendToUnity,
       _showUnity = showUnity,
       _showFlutter = showFlutter,
       _initUnityEngine = initUnityEngine,
       _storyRepository = storyRepository,
       _signalArbitrator = signalArbitrator,
       _invalidateStoryProgress = invalidateStoryProgress,
       _invalidateStoryCheckpoints = invalidateStoryCheckpoints {
    _unitySubscription = unityMessages.listen(handleUnityMessage);
  }

  final Future<void> Function(UnityMessage message) _sendToUnity;
  final Future<void> Function() _showUnity;
  final Future<void> Function() _showFlutter;
  final Future<void> Function() _initUnityEngine;
  final StoryRepository _storyRepository;
  final BleSignalArbitrator _signalArbitrator;
  final void Function(String characterId, String storyId)
  _invalidateStoryProgress;
  final void Function(String storyId) _invalidateStoryCheckpoints;

  late final StreamSubscription<UnityMessage> _unitySubscription;

  _StorySession? _activeSession;
  bool _bluetoothEnabled = true;
  String? _lastAnimationState;

  bool get bluetoothEnabled => _bluetoothEnabled;
  String? get lastAnimationState => _lastAnimationState;

  Future<void> prepareEngine() => _initUnityEngine();

  Future<void> enterScene({
    required String characterId,
    required String sceneId,
    String? storyId,
    List<String> permissions = const [],
  }) async {
    await _initUnityEngine();

    _activeSession = _StorySession(characterId: characterId, storyId: storyId);

    await _sendToUnity(
      UnityMessage(
        type: FlutterToUnityMessages.enterScene,
        data: {
          'characterId': characterId,
          'sceneId': sceneId,
          'storyId': storyId,
          'permissions': permissions,
        },
      ),
    );

    if (storyId != null) {
      await syncUserProgress(storyId: storyId);
    }

    await _showUnity();
  }

  Future<void> exitScene({bool notifyUnity = true}) async {
    if (notifyUnity) {
      await _sendToUnity(
        const UnityMessage(type: FlutterToUnityMessages.exitScene),
      );
    }

    _signalArbitrator.releaseSource(SignalSource.story);
    _activeSession = null;
    _lastAnimationState = null;
    _bluetoothEnabled = true;
    await _showFlutter();
  }

  Future<void> skipToCheckpoint(String checkpointId) {
    return _sendToUnity(
      UnityMessage(
        type: FlutterToUnityMessages.skipToCheckpoint,
        data: {'checkpointId': checkpointId},
      ),
    );
  }

  Future<void> syncUserProgress({String? storyId}) async {
    final targetStoryId = storyId ?? _activeSession?.storyId;
    if (targetStoryId == null) return;

    final checkpoints = await _storyRepository.getCheckpoints(targetStoryId);
    final completedSections =
        checkpoints
            .where((checkpoint) => checkpoint.isUnlocked)
            .map((checkpoint) => checkpoint.sectionId)
            .where((sectionId) => sectionId.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    await _sendToUnity(
      UnityMessage(
        type: FlutterToUnityMessages.userProgress,
        data: {
          'storyId': targetStoryId,
          'completedSections': completedSections,
        },
      ),
    );
  }

  Future<void> syncBluetoothState({
    required bool connected,
    String? deviceModel,
  }) {
    return _sendToUnity(
      UnityMessage(
        type: FlutterToUnityMessages.bluetoothState,
        data: {'connected': connected, 'deviceModel': deviceModel},
      ),
    );
  }

  Future<void> setBluetoothEnabled(bool enabled) async {
    _bluetoothEnabled = enabled;

    await _sendToUnity(
      UnityMessage(
        type: FlutterToUnityMessages.bluetoothToggle,
        data: {'enabled': enabled},
      ),
    );

    if (!enabled) {
      _signalArbitrator.releaseSource(SignalSource.story);
    }
  }

  Future<void> handleUnityMessage(UnityMessage message) async {
    switch (message.type) {
      case UnityToFlutterMessages.bluetoothSignal:
        _handleBluetoothSignal(message.data);
        break;
      case UnityToFlutterMessages.sectionComplete:
        await _handleSectionComplete(message.data);
        break;
      case UnityToFlutterMessages.checkpointReached:
        await _handleCheckpointReached(message.data);
        break;
      case UnityToFlutterMessages.animationState:
        _lastAnimationState = _readString(message.data, const ['state']);
        break;
      case UnityToFlutterMessages.requestExit:
        await exitScene(notifyUnity: false);
        break;
      case UnityToFlutterMessages.storyComplete:
        await _handleStoryComplete(message.data);
        break;
    }
  }

  void _handleBluetoothSignal(Map<String, dynamic> data) {
    if (!_bluetoothEnabled) {
      _signalArbitrator.releaseSource(SignalSource.story);
      return;
    }

    final swing = _readInt(data, const ['swing']) ?? 0;
    final vibration = _readInt(data, const ['vibration']) ?? 0;
    final durationMs = _readInt(data, const ['durationMs', 'signalDurationMs']);
    final delayMs = _readInt(data, const ['delayMs', 'signalDelayMs']);

    _signalArbitrator.submitSignal(
      BleSignal(
        swing: swing.clamp(0, 100),
        vibration: vibration.clamp(0, 100),
        source: SignalSource.story,
        durationMs: durationMs,
        delayMs: delayMs,
      ),
    );
  }

  Future<void> _handleSectionComplete(Map<String, dynamic> data) async {
    final session = _activeSession;
    if (session == null || session.storyId == null) {
      AppLogger().warning(
        'Ignoring sectionComplete because no active story session exists.',
      );
      return;
    }

    final sectionId = _readString(data, const ['sectionId']);
    if (sectionId == null || sectionId.isEmpty) return;

    await _storyRepository.saveProgress(
      StoryProgress(
        characterId: session.characterId,
        storyId: session.storyId!,
        currentSectionId: sectionId,
      ),
    );
    _invalidateStoryProgress(session.characterId, session.storyId!);
  }

  Future<void> _handleCheckpointReached(Map<String, dynamic> data) async {
    final session = _activeSession;
    final storyId = _readString(data, const ['storyId']) ?? session?.storyId;
    final checkpointId = _readString(data, const ['checkpointId']);

    if (storyId == null || checkpointId == null || checkpointId.isEmpty) {
      return;
    }

    final sectionId =
        _readString(data, const ['sectionId']) ??
        session?.lastCompletedSectionId ??
        '';
    final isEnding = _readBool(data, const ['isEnding']) ?? false;

    await _storyRepository.saveCheckpoint(
      StoryCheckpoint(
        storyId: storyId,
        checkpointId: checkpointId,
        sectionId: sectionId,
        isEnding: isEnding,
        isUnlocked: true,
      ),
    );
    _invalidateStoryCheckpoints(storyId);

    if (session != null && session.storyId == storyId) {
      session.lastCompletedSectionId = sectionId.isEmpty ? null : sectionId;
      await syncUserProgress(storyId: storyId);
    }
  }

  Future<void> _handleStoryComplete(Map<String, dynamic> data) async {
    final session = _activeSession;
    if (session == null || session.storyId == null) {
      AppLogger().warning(
        'Ignoring storyComplete because no active story session exists.',
      );
      return;
    }

    final storyId = _readString(data, const ['storyId']) ?? session.storyId!;
    if (storyId != session.storyId) return;

    final currentProgress = await _storyRepository.getProgress(
      session.characterId,
      storyId,
    );

    await _storyRepository.saveProgress(
      StoryProgress(
        characterId: session.characterId,
        storyId: storyId,
        currentSectionId:
            currentProgress?.currentSectionId ?? session.lastCompletedSectionId,
        isCompleted: true,
      ),
    );
    _invalidateStoryProgress(session.characterId, storyId);
  }

  String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  bool? _readBool(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is bool) return value;
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'true':
          case '1':
            return true;
          case 'false':
          case '0':
            return false;
        }
      }
      if (value is num) return value != 0;
    }
    return null;
  }

  void dispose() {
    unawaited(_unitySubscription.cancel());
    _signalArbitrator.releaseSource(SignalSource.story);
  }
}

class _StorySession {
  _StorySession({required this.characterId, required this.storyId});

  final String characterId;
  final String? storyId;
  String? lastCompletedSectionId;
}
