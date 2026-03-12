import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../domain/models/audio_entry.dart';
import '../../domain/models/playlist.dart';

/// Manages the runtime playlist (in-memory, not persisted).
class PlaylistService {
  final _uuid = const Uuid();
  final _random = Random();

  Playlist _playlist = const Playlist();
  final _controller = StreamController<Playlist>.broadcast();

  Stream<Playlist> get playlistStream => _controller.stream;
  Playlist get currentPlaylist => _playlist;

  /// Play an entry from the "all entries" context.
  /// If list is empty, creates a new playlist with just this entry.
  /// If entry already exists, moves playhead to it.
  /// Otherwise, inserts after current and plays.
  void playEntryFromAll(AudioEntry entry) {
    final existingIndex = _playlist.items.indexWhere(
      (item) => item.entry.id == entry.id,
    );

    if (_playlist.isEmpty) {
      _playlist = Playlist(
        items: [PlaylistItem(uid: _uuid.v4(), entry: entry)],
        currentIndex: 0,
        repeatMode: _playlist.repeatMode,
      );
    } else if (existingIndex >= 0) {
      _playlist = _playlist.copyWith(currentIndex: existingIndex);
    } else {
      final insertAt = _playlist.currentIndex + 1;
      final newItems = List<PlaylistItem>.of(_playlist.items)
        ..insert(insertAt, PlaylistItem(uid: _uuid.v4(), entry: entry));
      _playlist = _playlist.copyWith(
        items: newItems,
        currentIndex: insertAt,
      );
    }

    _emit();
  }

  /// Play an entry from a collection context.
  /// Rebuilds the playlist based on the current repeat mode.
  void playEntryFromCollection(
    AudioEntry entry,
    List<AudioEntry> collectionEntries,
  ) {
    switch (_playlist.repeatMode) {
      case RepeatMode.sequential:
        _buildSequentialFromCollection(entry, collectionEntries);
      case RepeatMode.shuffle:
        _buildShuffleFromCollection(entry, collectionEntries);
      case RepeatMode.single:
        _playlist = Playlist(
          items: [PlaylistItem(uid: _uuid.v4(), entry: entry)],
          currentIndex: 0,
          repeatMode: RepeatMode.single,
        );
    }

    _emit();
  }

  void _buildSequentialFromCollection(
    AudioEntry entry,
    List<AudioEntry> entries,
  ) {
    final startIndex = entries.indexWhere((e) => e.id == entry.id);
    if (startIndex < 0) return;

    // Rotate so clicked entry is first
    final rotated = [
      ...entries.sublist(startIndex),
      ...entries.sublist(0, startIndex),
    ];

    _playlist = Playlist(
      items: rotated
          .map((e) => PlaylistItem(uid: _uuid.v4(), entry: e))
          .toList(),
      currentIndex: 0,
      repeatMode: RepeatMode.sequential,
    );
  }

  void _buildShuffleFromCollection(
    AudioEntry entry,
    List<AudioEntry> entries,
  ) {
    final others = entries.where((e) => e.id != entry.id).toList()..shuffle(_random);
    final items = [
      PlaylistItem(uid: _uuid.v4(), entry: entry),
      ...others.map((e) => PlaylistItem(uid: _uuid.v4(), entry: e)),
    ];

    _playlist = Playlist(
      items: items,
      currentIndex: 0,
      repeatMode: RepeatMode.shuffle,
    );
  }

  /// Add an entry to the end of the playlist without changing playhead.
  void addEntry(AudioEntry entry) {
    final newItems = List<PlaylistItem>.of(_playlist.items)
      ..add(PlaylistItem(uid: _uuid.v4(), entry: entry));
    _playlist = _playlist.copyWith(items: newItems);
    _emit();
  }

  /// Move to next track. Returns true if there is a next track.
  bool next() {
    if (_playlist.isEmpty) return false;

    switch (_playlist.repeatMode) {
      case RepeatMode.sequential:
        final nextIndex = (_playlist.currentIndex + 1) % _playlist.length;
        _playlist = _playlist.copyWith(currentIndex: nextIndex);
      case RepeatMode.single:
        // Stay on the same track (will replay)
        break;
      case RepeatMode.shuffle:
        if (_playlist.currentIndex >= _playlist.length - 1) {
          _reshuffle();
        } else {
          _playlist = _playlist.copyWith(
            currentIndex: _playlist.currentIndex + 1,
          );
        }
    }

    _emit();
    return true;
  }

  /// Move to previous track. Returns true if there is a previous track.
  bool previous() {
    if (_playlist.isEmpty) return false;

    switch (_playlist.repeatMode) {
      case RepeatMode.sequential:
        final prevIndex = (_playlist.currentIndex - 1 + _playlist.length) %
            _playlist.length;
        _playlist = _playlist.copyWith(currentIndex: prevIndex);
      case RepeatMode.single:
        break;
      case RepeatMode.shuffle:
        if (_playlist.currentIndex <= 0) {
          _playlist = _playlist.copyWith(
            currentIndex: _playlist.length - 1,
          );
        } else {
          _playlist = _playlist.copyWith(
            currentIndex: _playlist.currentIndex - 1,
          );
        }
    }

    _emit();
    return true;
  }

  void _reshuffle() {
    if (_playlist.length <= 1) return;

    final current = _playlist.currentItem;
    if (current == null) return;

    final others = _playlist.items.where((i) => i.uid != current.uid).toList()
      ..shuffle(_random);

    _playlist = _playlist.copyWith(
      items: [current, ...others],
      currentIndex: 0,
    );
  }

  /// Remove an item from the playlist.
  void removeItem(String uid) {
    final index = _playlist.items.indexWhere((i) => i.uid == uid);
    if (index < 0) return;

    final newItems = List<PlaylistItem>.of(_playlist.items)..removeAt(index);

    if (newItems.isEmpty) {
      _playlist = _playlist.copyWith(items: [], currentIndex: -1);
    } else {
      int newCurrentIndex = _playlist.currentIndex;
      if (index < newCurrentIndex) {
        newCurrentIndex--;
      } else if (index == newCurrentIndex) {
        newCurrentIndex = newCurrentIndex.clamp(0, newItems.length - 1);
      }
      _playlist = _playlist.copyWith(
        items: newItems,
        currentIndex: newCurrentIndex,
      );
    }

    _emit();
  }

  void setRepeatMode(RepeatMode mode) {
    _playlist = _playlist.copyWith(repeatMode: mode);
    _emit();
  }

  RepeatMode cycleRepeatMode() {
    const modes = RepeatMode.values;
    final nextIndex = (modes.indexOf(_playlist.repeatMode) + 1) % modes.length;
    final nextMode = modes[nextIndex];
    setRepeatMode(nextMode);
    return nextMode;
  }

  void clear() {
    _playlist = const Playlist();
    _emit();
  }

  void _emit() {
    _controller.add(_playlist);
  }

  void dispose() {
    _controller.close();
  }
}
