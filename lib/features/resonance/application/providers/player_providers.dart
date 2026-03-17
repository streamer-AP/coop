import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/audio_entry.dart';
import '../../domain/models/player_state.dart';
import '../../domain/models/playlist.dart';
import '../services/audio_player_service.dart';
import '../services/playlist_service.dart';

part 'player_providers.g.dart';

@Riverpod(keepAlive: true)
AudioPlayerService audioPlayerService(Ref ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
}

@Riverpod(keepAlive: true)
PlaylistService playlistService(Ref ref) {
  final service = PlaylistService();
  ref.onDispose(() => service.dispose());
  return service;
}

@Riverpod(keepAlive: true)
class PlayerStateNotifier extends _$PlayerStateNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  PlayerState build() {
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    final playlistSvc = ref.read(playlistServiceProvider);
    audioPlayer.setSkipHandlers(
      onSkipToNext: () => next(),
      onSkipToPrevious: () => previous(),
    );

    _subscriptions.add(
      audioPlayer.playingStream.listen((playing) {
        state = state.copyWith(isPlaying: playing);
      }),
    );

    _subscriptions.add(
      audioPlayer.positionStream.listen((position) {
        state = state.copyWith(position: position);
      }),
    );

    _subscriptions.add(
      audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          state = state.copyWith(duration: duration);
        }
      }),
    );

    _subscriptions.add(
      playlistSvc.playlistStream.listen((playlist) {
        final currentEntry = playlist.currentItem?.entry;
        state = state.copyWith(currentEntry: currentEntry);
      }),
    );

    _subscriptions.add(
      audioPlayer.completionStream.listen((_) {
        _onTrackComplete();
      }),
    );

    ref.onDispose(() {
      for (final sub in _subscriptions) {
        sub.cancel();
      }
      _subscriptions.clear();
    });

    return const PlayerState();
  }

  Future<void> playEntry(AudioEntry entry, {List<AudioEntry>? context}) async {
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    final playlistSvc = ref.read(playlistServiceProvider);

    await audioPlayer.initialize();

    if (context != null) {
      playlistSvc.playEntryFromCollection(entry, context);
    } else {
      playlistSvc.playEntryFromAll(entry);
    }

    await audioPlayer.setSource(entry);
    await audioPlayer.play();
  }

  Future<void> play() async {
    await ref.read(audioPlayerServiceProvider).play();
  }

  Future<void> pause() async {
    await ref.read(audioPlayerServiceProvider).pause();
  }

  Future<void> seekTo(Duration position) async {
    await ref.read(audioPlayerServiceProvider).seekTo(position);
  }

  Future<void> next() async {
    final playlistSvc = ref.read(playlistServiceProvider);
    final audioPlayer = ref.read(audioPlayerServiceProvider);

    if (playlistSvc.next()) {
      final entry = playlistSvc.currentPlaylist.currentItem?.entry;
      if (entry != null) {
        await audioPlayer.setSource(entry);
        await audioPlayer.play();
      }
    }
  }

  Future<void> previous() async {
    final playlistSvc = ref.read(playlistServiceProvider);
    final audioPlayer = ref.read(audioPlayerServiceProvider);

    if (playlistSvc.previous()) {
      final entry = playlistSvc.currentPlaylist.currentItem?.entry;
      if (entry != null) {
        await audioPlayer.setSource(entry);
        await audioPlayer.play();
      }
    }
  }

  RepeatMode cycleRepeatMode() {
    return ref.read(playlistServiceProvider).cycleRepeatMode();
  }

  void addToCurrentPlaylist(AudioEntry entry) {
    ref.read(playlistServiceProvider).addEntry(entry);
  }

  Future<void> playPlaylistItem(String uid) async {
    final playlistSvc = ref.read(playlistServiceProvider);
    final audioPlayer = ref.read(audioPlayerServiceProvider);

    final changed = playlistSvc.playItem(uid);
    if (!changed) return;

    final entry = playlistSvc.currentPlaylist.currentItem?.entry;
    if (entry == null) return;

    await audioPlayer.setSource(entry);
    await audioPlayer.play();
  }

  Future<void> removeFromPlaylist(String uid) async {
    final playlistSvc = ref.read(playlistServiceProvider);
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    final previous = playlistSvc.currentPlaylist;
    final removedIndex = previous.items.indexWhere((item) => item.uid == uid);
    if (removedIndex < 0) return;

    final wasCurrent = removedIndex == previous.currentIndex;
    final wasPlaying = state.isPlaying;

    playlistSvc.removeItem(uid);
    final nextPlaylist = playlistSvc.currentPlaylist;

    if (nextPlaylist.isEmpty) {
      await audioPlayer.stop();
      state = state.copyWith(
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
        currentEntry: null,
      );
      return;
    }

    if (wasCurrent) {
      final nextEntry = nextPlaylist.currentItem?.entry;
      if (nextEntry != null) {
        await audioPlayer.setSource(nextEntry);
        if (wasPlaying) {
          await audioPlayer.play();
        } else {
          await audioPlayer.pause();
        }
      }
    }
  }

  Future<void> clearPlaylist() async {
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    ref.read(playlistServiceProvider).clear();
    await audioPlayer.stop();
    state = state.copyWith(
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
      currentEntry: null,
    );
  }

  void setSignalMode(SignalMode mode) {
    state = state.copyWith(signalMode: mode);
  }

  void _onTrackComplete() {
    final playlistSvc = ref.read(playlistServiceProvider);
    final playlist = playlistSvc.currentPlaylist;

    if (playlist.repeatMode == RepeatMode.single) {
      ref.read(audioPlayerServiceProvider).seekTo(Duration.zero);
      ref.read(audioPlayerServiceProvider).play();
    } else {
      next();
    }
  }
}
