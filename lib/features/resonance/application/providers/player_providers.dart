import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/user_storage_service.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/models/player_state.dart';
import '../../domain/models/playlist.dart';
import '../services/audio_player_service.dart';
import '../services/playlist_service.dart';
import 'resonance_providers.dart';

part 'player_providers.g.dart';

@Riverpod(keepAlive: true)
AudioPlayerService audioPlayerService(Ref ref) {
  ref.watch(userStorageEpochProvider);
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
}

@Riverpod(keepAlive: true)
PlaylistService playlistService(Ref ref) {
  ref.watch(userStorageEpochProvider);
  final service = PlaylistService();
  ref.onDispose(() => service.dispose());
  return service;
}

@Riverpod(keepAlive: true)
Stream<Playlist> playlistState(Ref ref) {
  final service = ref.watch(playlistServiceProvider);
  return service.playlistStream;
}

@Riverpod(keepAlive: true)
class PlayerStateNotifier extends _$PlayerStateNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _suppressAutoAdvanceOnNextCompletion = false;

  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    _subscriptions.clear();
  }

  @override
  PlayerState build() {
    ref.watch(userStorageEpochProvider);
    _cancelSubscriptions();
    _suppressAutoAdvanceOnNextCompletion = false;

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
        unawaited(
          audioPlayer.setSingleTrackLooping(
            playlist.repeatMode == RepeatMode.single,
          ),
        );
        final currentEntry = playlist.currentItem?.entry;
        state = state.copyWith(currentEntry: currentEntry);
      }),
    );

    _subscriptions.add(
      audioPlayer.completionStream.listen((_) {
        unawaited(_onTrackComplete());
      }),
    );

    _subscriptions.add(
      audioPlayer.playbackErrorStream.listen((error) {
        _suppressAutoAdvanceOnNextCompletion = true;
        unawaited(_handlePlaybackError(error));
      }),
    );

    ref.onDispose(() {
      _cancelSubscriptions();
    });

    return const PlayerState();
  }

  Future<void> playEntry(AudioEntry entry, {List<AudioEntry>? context}) async {
    if (context != null) {
      await playCollectionEntry(entry, context: context, playlistTitle: '合集播放');
      return;
    }

    await playAllEntry(entry, playlistTitle: '全部音频');
  }

  Future<void> playAllEntry(
    AudioEntry entry, {
    required String playlistTitle,
  }) async {
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    final playlistSvc = ref.read(playlistServiceProvider);

    // If this entry is already the currently loaded one, just continue playing
    // without reloading (avoids restarting from the beginning).
    if (state.currentEntry?.id == entry.id) {
      // Still update the playlist so position/context is correct,
      // but don't reload the audio source.
      playlistSvc.playEntryFromAll(entry);
      state = state.copyWith(playlistTitle: playlistTitle);
      return;
    }

    await audioPlayer.initialize();

    playlistSvc.playEntryFromAll(entry);

    state = state.copyWith(playlistTitle: playlistTitle);
    await audioPlayer.setSingleTrackLooping(
      playlistSvc.currentPlaylist.repeatMode == RepeatMode.single,
    );

    await _loadEntry(entry, autoplay: true);
  }

  Future<void> playCollectionEntry(
    AudioEntry entry, {
    required List<AudioEntry> context,
    required String playlistTitle,
  }) async {
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    final playlistSvc = ref.read(playlistServiceProvider);

    if (state.currentEntry?.id == entry.id) {
      playlistSvc.playEntryFromCollection(entry, context);
      state = state.copyWith(playlistTitle: playlistTitle);
      await audioPlayer.setSingleTrackLooping(
        playlistSvc.currentPlaylist.repeatMode == RepeatMode.single,
      );
      return;
    }

    await audioPlayer.initialize();
    playlistSvc.playEntryFromCollection(entry, context);

    state = state.copyWith(playlistTitle: playlistTitle);
    await audioPlayer.setSingleTrackLooping(
      playlistSvc.currentPlaylist.repeatMode == RepeatMode.single,
    );

    await _loadEntry(entry, autoplay: true);
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
    if (playlistSvc.next()) {
      final entry = playlistSvc.currentPlaylist.currentItem?.entry;
      if (entry != null) {
        await _loadEntry(entry, autoplay: true);
      }
    }
  }

  Future<void> previous() async {
    final playlistSvc = ref.read(playlistServiceProvider);

    if (playlistSvc.previous()) {
      final entry = playlistSvc.currentPlaylist.currentItem?.entry;
      if (entry != null) {
        await _loadEntry(entry, autoplay: true);
      }
    }
  }

  RepeatMode cycleRepeatMode() {
    final mode = ref.read(playlistServiceProvider).cycleRepeatMode();
    unawaited(
      ref
          .read(audioPlayerServiceProvider)
          .setSingleTrackLooping(mode == RepeatMode.single),
    );
    return mode;
  }

  void addToCurrentPlaylist(AudioEntry entry) {
    ref.read(playlistServiceProvider).addEntry(entry);
  }

  Future<void> playPlaylistItem(String uid) async {
    final playlistSvc = ref.read(playlistServiceProvider);

    final changed = playlistSvc.playItem(uid);
    if (!changed) return;

    final entry = playlistSvc.currentPlaylist.currentItem?.entry;
    if (entry == null) return;

    await _loadEntry(entry, autoplay: true);
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
        playlistTitle: '全部音频',
      );
      return;
    }

    if (wasCurrent) {
      final nextEntry = nextPlaylist.currentItem?.entry;
      if (nextEntry != null) {
        await _loadEntry(nextEntry, autoplay: wasPlaying);
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
      playlistTitle: '全部音频',
    );
  }

  Future<void> removeEntriesByEntryIds(Set<int> entryIds) async {
    if (entryIds.isEmpty) return;

    final playlistSvc = ref.read(playlistServiceProvider);
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    final previous = playlistSvc.currentPlaylist;
    final wasCurrentRemoved =
        previous.currentItem != null &&
        entryIds.contains(previous.currentItem!.entry.id);
    final wasPlaying = state.isPlaying;
    final changed = playlistSvc.removeEntriesByEntryIds(entryIds);

    if (!changed) return;

    final nextPlaylist = playlistSvc.currentPlaylist;
    if (nextPlaylist.isEmpty) {
      await audioPlayer.stop();
      state = state.copyWith(
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
        currentEntry: null,
        playlistTitle: '全部音频',
      );
      return;
    }

    if (wasCurrentRemoved) {
      final nextEntry = nextPlaylist.currentItem?.entry;
      if (nextEntry != null) {
        await _loadEntry(nextEntry, autoplay: wasPlaying);
      }
    }
  }

  void setSignalMode(SignalMode mode) {
    state = state.copyWith(signalMode: mode);
  }

  /// Refresh the current entry's metadata.
  /// When [updatedEntry] is provided, update in-memory state directly.
  /// Otherwise reload the current entry from the repository.
  Future<void> refreshCurrentEntry([AudioEntry? updatedEntry]) async {
    final resolvedEntry = updatedEntry ?? state.currentEntry;
    if (resolvedEntry == null) return;

    AudioEntry? nextEntry = updatedEntry;
    if (nextEntry == null) {
      final repo = ref.read(resonanceRepositoryProvider);
      nextEntry = await repo.getEntry(resolvedEntry.id);
    }
    if (nextEntry == null) return;

    if (state.currentEntry?.id == nextEntry.id) {
      state = state.copyWith(currentEntry: nextEntry);
      ref.read(audioPlayerServiceProvider).updateMediaItem(nextEntry);
    }
    ref.read(playlistServiceProvider).updateEntry(nextEntry);
  }

  Future<void> _onTrackComplete() async {
    if (_suppressAutoAdvanceOnNextCompletion) {
      _suppressAutoAdvanceOnNextCompletion = false;
      return;
    }

    final playlistSvc = ref.read(playlistServiceProvider);
    final playlist = playlistSvc.currentPlaylist;
    final audioPlayer = ref.read(audioPlayerServiceProvider);

    if (playlist.repeatMode == RepeatMode.single) {
      return;
    } else if (playlist.length <= 1) {
      await audioPlayer.pause();
      state = state.copyWith(isPlaying: false, position: Duration.zero);
    } else {
      await next();
    }
  }

  Future<void> _loadEntry(AudioEntry entry, {required bool autoplay}) async {
    _suppressAutoAdvanceOnNextCompletion = false;
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    await audioPlayer.setSource(entry);
    await audioPlayer.setSingleTrackLooping(
      ref.read(playlistServiceProvider).currentPlaylist.repeatMode ==
          RepeatMode.single,
    );
    if (autoplay) {
      await audioPlayer.play();
    } else {
      await audioPlayer.pause();
    }
  }

  Future<void> _handlePlaybackError(Object error) async {
    final audioPlayer = ref.read(audioPlayerServiceProvider);
    await audioPlayer.stop();
    state = state.copyWith(isPlaying: false, position: Duration.zero);
  }
}
