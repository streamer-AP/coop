import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:omao_app/core/bluetooth/ble_connection_manager.dart';
import 'package:omao_app/core/bluetooth/ble_device_protocol.dart';
import 'package:omao_app/core/bluetooth/ble_signal_arbitrator.dart';
import 'package:omao_app/core/bluetooth/ble_signal_sender.dart';
import 'package:omao_app/core/bluetooth/models/ble_signal.dart';
import 'package:omao_app/features/story/application/services/story_bridge_service.dart';
import 'package:omao_app/features/story/domain/models/story_checkpoint.dart';
import 'package:omao_app/features/story/domain/models/story_progress.dart';
import 'package:omao_app/features/story/domain/repositories/story_repository.dart';
import 'package:omao_app/core/platform/unity_message.dart';

void main() {
  group('StoryBridgeService', () {
    late StreamController<UnityMessage> unityMessages;
    late _FakeStoryRepository repository;
    late _RecordingSignalArbitrator signalArbitrator;
    late List<UnityMessage> outboundMessages;
    late int showUnityCalls;
    late int showFlutterCalls;
    late int initUnityCalls;
    late List<String> invalidatedProgresses;
    late List<String> invalidatedCheckpoints;
    late StoryBridgeService service;

    setUp(() {
      unityMessages = StreamController<UnityMessage>.broadcast();
      repository = _FakeStoryRepository();
      signalArbitrator = _RecordingSignalArbitrator();
      outboundMessages = [];
      showUnityCalls = 0;
      showFlutterCalls = 0;
      initUnityCalls = 0;
      invalidatedProgresses = [];
      invalidatedCheckpoints = [];

      service = StoryBridgeService(
        unityMessages: unityMessages.stream,
        sendToUnity: (message) async => outboundMessages.add(message),
        showUnity: () async => showUnityCalls++,
        showFlutter: () async => showFlutterCalls++,
        initUnityEngine: () async => initUnityCalls++,
        storyRepository: repository,
        signalArbitrator: signalArbitrator,
        invalidateStoryProgress:
            (characterId, storyId) =>
                invalidatedProgresses.add('$characterId::$storyId'),
        invalidateStoryCheckpoints:
            (storyId) => invalidatedCheckpoints.add(storyId),
      );
    });

    tearDown(() {
      service.dispose();
      unityMessages.close();
    });

    test(
      'enterScene syncs progress to Unity before showing Unity view',
      () async {
        repository.checkpointsByStory['story-1'] = [
          const StoryCheckpoint(
            storyId: 'story-1',
            checkpointId: 'cp-1',
            sectionId: 'sec-1',
            isUnlocked: true,
          ),
          const StoryCheckpoint(
            storyId: 'story-1',
            checkpointId: 'cp-2',
            sectionId: 'sec-2',
            isUnlocked: false,
          ),
        ];

        await service.enterScene(
          characterId: 'orven',
          storyId: 'story-1',
          sceneId: 'story-scene',
          permissions: const ['PAGE_STORY_ORVEN_1_1'],
        );

        expect(initUnityCalls, 1);
        expect(showUnityCalls, 1);
        expect(outboundMessages.map((message) => message.type), [
          FlutterToUnityMessages.enterScene,
          FlutterToUnityMessages.userProgress,
        ]);
        expect(outboundMessages.last.data['completedSections'], <String>[
          'sec-1',
        ]);
      },
    );

    test('handles Unity bluetooth and progress callbacks', () async {
      await service.enterScene(
        characterId: 'orven',
        storyId: 'story-1',
        sceneId: 'story-scene',
      );
      outboundMessages.clear();

      await service.handleUnityMessage(
        const UnityMessage(
          type: UnityToFlutterMessages.bluetoothSignal,
          data: {
            'swing': 65,
            'vibration': 35,
            'signalDurationMs': 400,
            'signalDelayMs': 12,
          },
        ),
      );
      await service.handleUnityMessage(
        const UnityMessage(
          type: UnityToFlutterMessages.sectionComplete,
          data: {'sectionId': 'sec-1'},
        ),
      );
      await service.handleUnityMessage(
        const UnityMessage(
          type: UnityToFlutterMessages.checkpointReached,
          data: {
            'checkpointId': 'cp-1',
            'sectionId': 'sec-1',
            'isEnding': false,
          },
        ),
      );

      expect(signalArbitrator.submittedSignals, hasLength(1));
      expect(signalArbitrator.submittedSignals.single, isA<BleSignal>());
      expect(
        signalArbitrator.submittedSignals.single.source,
        SignalSource.story,
      );
      expect(signalArbitrator.submittedSignals.single.durationMs, 400);
      expect(signalArbitrator.submittedSignals.single.delayMs, 12);

      expect(repository.savedProgresses.single.currentSectionId, 'sec-1');
      expect(invalidatedProgresses, ['orven::story-1']);
      expect(repository.savedCheckpoints.single.checkpointId, 'cp-1');
      expect(invalidatedCheckpoints, ['story-1']);
      expect(outboundMessages.single.type, FlutterToUnityMessages.userProgress);
      expect(outboundMessages.single.data['completedSections'], <String>[
        'sec-1',
      ]);
    });

    test(
      'requestExit switches back to Flutter and releases story source',
      () async {
        await service.enterScene(
          characterId: 'orven',
          storyId: 'story-1',
          sceneId: 'story-scene',
        );

        await service.handleUnityMessage(
          const UnityMessage(type: UnityToFlutterMessages.requestExit),
        );

        expect(showFlutterCalls, 1);
        expect(signalArbitrator.releasedSources, contains(SignalSource.story));
      },
    );
  });
}

class _FakeStoryRepository implements StoryRepository {
  final Map<String, StoryProgress> progresses = {};
  final Map<String, List<StoryCheckpoint>> checkpointsByStory = {};
  final List<StoryProgress> savedProgresses = [];
  final List<StoryCheckpoint> savedCheckpoints = [];

  @override
  Future<StoryProgress?> getProgress(String characterId, String storyId) async {
    return progresses['$characterId::$storyId'];
  }

  @override
  Future<void> saveProgress(StoryProgress progress) async {
    progresses['${progress.characterId}::${progress.storyId}'] = progress;
    savedProgresses.add(progress);
  }

  @override
  Future<List<StoryCheckpoint>> getCheckpoints(String storyId) async {
    return List<StoryCheckpoint>.from(checkpointsByStory[storyId] ?? const []);
  }

  @override
  Future<void> saveCheckpoint(StoryCheckpoint checkpoint) async {
    final list = checkpointsByStory.putIfAbsent(checkpoint.storyId, () => []);
    final index = list.indexWhere(
      (item) => item.checkpointId == checkpoint.checkpointId,
    );

    if (index == -1) {
      list.add(checkpoint);
    } else {
      list[index] = checkpoint;
    }
    savedCheckpoints.add(checkpoint);
  }

  @override
  Future<void> unlockCheckpoint(String storyId, String checkpointId) async {
    final list = checkpointsByStory.putIfAbsent(storyId, () => []);
    final index = list.indexWhere((item) => item.checkpointId == checkpointId);
    if (index == -1) return;
    list[index] = list[index].copyWith(isUnlocked: true);
  }
}

class _RecordingSignalArbitrator extends BleSignalArbitrator {
  _RecordingSignalArbitrator()
    : super(BleSignalSender(_FakeBleConnectionManager(), BleDeviceProtocol()));

  final List<BleSignal> submittedSignals = [];
  final List<SignalSource> releasedSources = [];

  @override
  void submitSignal(BleSignal signal) {
    submittedSignals.add(signal);
  }

  @override
  void releaseSource(SignalSource source) {
    releasedSources.add(source);
  }
}

class _FakeBleConnectionManager extends _NoopBleConnectionManager {}

class _NoopBleConnectionManager extends BleConnectionManager {
  @override
  bool get isConnected => false;

  @override
  Future<void> writePayload(Uint8List payload) async {}
}
