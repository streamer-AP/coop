import 'dart:convert';
import 'dart:io';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../../../core/storage/file_manager.dart';
import '../../domain/models/player_state.dart';
import '../../domain/models/signal_timeline.dart';
import '../services/audio_analysis_service.dart';
import '../services/signal_sync_service.dart';
import 'player_providers.dart';
import 'resonance_providers.dart';

part 'signal_providers.g.dart';

@riverpod
SignalSyncService signalSyncService(Ref ref) {
  final arbitrator = ref.watch(bleSignalArbitratorProvider);
  final audioPlayer = ref.read(audioPlayerServiceProvider);
  final service = SignalSyncService(
    arbitrator: arbitrator,
    getPosition: () => audioPlayer.player.position,
  );
  ref.onDispose(() => service.dispose());
  return service;
}

@riverpod
class SignalModeNotifier extends _$SignalModeNotifier {
  @override
  SignalMode build() {
    ref.listen(playerStateNotifierProvider, (prev, next) {
      if (prev?.currentEntry?.id != next.currentEntry?.id) {
        _onEntryChanged(next);
      }
      if (prev?.isPlaying != next.isPlaying) {
        _onPlayingChanged(next);
      }
    });

    return SignalMode.off;
  }

  Future<void> setMode(SignalMode mode) async {
    final syncService = ref.read(signalSyncServiceProvider);
    final playerState = ref.read(playerStateNotifierProvider);

    if (mode == SignalMode.off) {
      syncService.stop();
    } else if (mode == SignalMode.resonance && playerState.currentEntry != null) {
      await _startSync(playerState.currentEntry!.id);
    }

    state = mode;
    ref.read(playerStateNotifierProvider.notifier).setSignalMode(mode);
  }

  Future<void> _startSync(int entryId) async {
    final repo = ref.read(resonanceRepositoryProvider);
    final syncService = ref.read(signalSyncServiceProvider);

    var signalPath = await repo.getSignalFilePathForEntry(entryId);

    // Auto-generate signal file if none exists
    if (signalPath == null) {
      final entry = await repo.getEntry(entryId);
      if (entry == null) return;

      try {
        final analysisService = AudioAnalysisService();
        final fileManager = ref.read(fileManagerProvider);
        final generatedPath = await analysisService.analyzeAndSave(
          audioFilePath: entry.filePath,
          entryId: entryId,
          importDir: fileManager.getImportDirectory(),
        );
        await repo.insertSignalFile(entryId, generatedPath);
        signalPath = generatedPath;
      } catch (_) {
        // Analysis failed, continue without signal
        return;
      }
    }

    try {
      final content = await File(signalPath).readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      final timeline = SignalTimeline.fromJson(data);
      syncService.start(timeline);
    } catch (_) {
      // Signal file not available or invalid
    }
  }

  void _onEntryChanged(PlayerState playerState) {
    if (state == SignalMode.resonance && playerState.currentEntry != null) {
      _startSync(playerState.currentEntry!.id);
    }
  }

  void _onPlayingChanged(PlayerState playerState) {
    final syncService = ref.read(signalSyncServiceProvider);
    if (state != SignalMode.resonance) return;

    if (playerState.isPlaying) {
      syncService.resume();
    } else {
      syncService.pause();
    }
  }
}
