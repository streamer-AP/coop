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
  /// If entry already exists, moves it to current+1 and plays it.
  /// Otherwise, inserts after current and plays.
  void playEntryFromAll(AudioEntry entry) {
    final items = List<PlaylistItem>.of(_playlist.items);
    final existingIndex = items.indexWhere((item) => item.entry.id == entry.id);

    if (_playlist.isEmpty) {
      _playlist = Playlist(
        items: [PlaylistItem(uid: _uuid.v4(), entry: entry)],
        currentIndex: 0,
        repeatMode: _playlist.repeatMode,
      );
    } else {
      final currentItem = _playlist.currentItem;
      final originalCurrentIndex = _clampInt(
        _playlist.currentIndex,
        0,
        items.length - 1,
      );
      PlaylistItem target;
      if (existingIndex >= 0) {
        target = items.removeAt(existingIndex);
      } else {
        target = PlaylistItem(uid: _uuid.v4(), entry: entry);
      }

      int insertAt;
      if (currentItem != null && currentItem.uid == target.uid) {
        insertAt = _clampInt(originalCurrentIndex + 1, 0, items.length);
      } else {
        final anchorIndex =
            currentItem == null
                ? -1
                : items.indexWhere((item) => item.uid == currentItem.uid);
        insertAt = anchorIndex >= 0 ? anchorIndex + 1 : items.length;
      }
      insertAt = _clampInt(insertAt, 0, items.length);
      items.insert(insertAt, target);

      _playlist = _playlist.copyWith(
        items: items,
        currentIndex: _clampInt(insertAt, 0, items.length - 1),
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
    final startIndex = collectionEntries.indexWhere((e) => e.id == entry.id);
    if (startIndex < 0 || collectionEntries.isEmpty) return;

    final hadExistingPlaylist = _playlist.isNotEmpty;

    if (!hadExistingPlaylist) {
      _playlist = Playlist(
        items:
            collectionEntries
                .map((e) => PlaylistItem(uid: _uuid.v4(), entry: e))
                .toList(),
        currentIndex: startIndex,
        repeatMode: RepeatMode.sequential,
      );
      _emit();
      return;
    }

    switch (_playlist.repeatMode) {
      case RepeatMode.sequential:
        _playlist = Playlist(
          items:
              collectionEntries
                  .map((e) => PlaylistItem(uid: _uuid.v4(), entry: e))
                  .toList(),
          currentIndex: startIndex,
          repeatMode: RepeatMode.sequential,
        );
      case RepeatMode.shuffle:
        _buildShuffleFromCollection(entry, collectionEntries);
      case RepeatMode.single:
        _playlist = Playlist(
          items:
              collectionEntries
                  .map((e) => PlaylistItem(uid: _uuid.v4(), entry: e))
                  .toList(),
          currentIndex: startIndex,
          repeatMode: RepeatMode.single,
        );
    }

    _emit();
  }

  void _buildShuffleFromCollection(AudioEntry entry, List<AudioEntry> entries) {
    final others =
        entries.where((e) => e.id != entry.id).toList()..shuffle(_random);
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
  /// If entry already exists, move it to current+1 without changing playhead.
  void addEntry(AudioEntry entry) {
    if (_playlist.isEmpty) {
      _playlist = Playlist(
        items: [PlaylistItem(uid: _uuid.v4(), entry: entry)],
        currentIndex: 0,
        repeatMode: _playlist.repeatMode,
      );
      _emit();
      return;
    }

    final items = List<PlaylistItem>.of(_playlist.items);
    final currentUid = _playlist.currentItem?.uid;
    final existingIndex = items.indexWhere((item) => item.entry.id == entry.id);
    PlaylistItem target;
    if (existingIndex >= 0) {
      target = items.removeAt(existingIndex);
    } else {
      target = PlaylistItem(uid: _uuid.v4(), entry: entry);
    }

    var insertAt = _clampInt(_playlist.currentIndex + 1, 0, items.length);
    if (existingIndex >= 0 && existingIndex < insertAt) {
      insertAt -= 1;
    }
    insertAt = _clampInt(insertAt, 0, items.length);
    items.insert(insertAt, target);

    var nextCurrentIndex = _playlist.currentIndex;
    if (currentUid != null) {
      nextCurrentIndex = items.indexWhere((item) => item.uid == currentUid);
    }

    _playlist = _playlist.copyWith(
      items: items,
      currentIndex: _clampInt(nextCurrentIndex, 0, items.length - 1),
    );
    _emit();
  }

  /// Select an existing item as current play item.
  bool playItem(String uid) {
    final index = _playlist.items.indexWhere((item) => item.uid == uid);
    if (index < 0) return false;

    _playlist = _playlist.copyWith(currentIndex: index);

    _emit();
    return true;
  }

  /// Move to next track. Returns true if the current entry actually changed.
  bool next() {
    if (_playlist.isEmpty) return false;
    if (_playlist.length == 1) return false;

    switch (_playlist.repeatMode) {
      case RepeatMode.sequential:
        final nextIndex = (_playlist.currentIndex + 1) % _playlist.length;
        _playlist = _playlist.copyWith(currentIndex: nextIndex);
      case RepeatMode.single:
        // Single repeat: next still moves to the next track per requirement
        final nextIndex = (_playlist.currentIndex + 1) % _playlist.length;
        _playlist = _playlist.copyWith(currentIndex: nextIndex);
      case RepeatMode.shuffle:
        if (_playlist.currentIndex >= _playlist.length - 1) {
          // Last item: reshuffle then play new first item
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

  /// Move to previous track. Returns true if the current entry actually changed.
  bool previous() {
    if (_playlist.isEmpty) return false;
    if (_playlist.length == 1) return false;

    final oldIndex = _playlist.currentIndex;

    switch (_playlist.repeatMode) {
      case RepeatMode.sequential:
        final prevIndex = (oldIndex - 1 + _playlist.length) % _playlist.length;
        _playlist = _playlist.copyWith(currentIndex: prevIndex);
      case RepeatMode.single:
        final prevIndex = (oldIndex - 1 + _playlist.length) % _playlist.length;
        _playlist = _playlist.copyWith(currentIndex: prevIndex);
      case RepeatMode.shuffle:
        if (oldIndex <= 0) {
          _playlist = _playlist.copyWith(currentIndex: _playlist.length - 1);
        } else {
          _playlist = _playlist.copyWith(currentIndex: oldIndex - 1);
        }
    }

    _emit();
    return _playlist.currentIndex != oldIndex;
  }

  void _reshuffle() {
    if (_playlist.length <= 1) return;

    // Reshuffle all items, ensuring the previously-playing item
    // does NOT end up first (to avoid repeating it immediately).
    final current = _playlist.currentItem;
    if (current == null) return;

    final allItems = List<PlaylistItem>.of(_playlist.items)..shuffle(_random);

    // If the last-played item ended up first, swap it away
    if (allItems.first.uid == current.uid && allItems.length > 1) {
      final swapIndex = 1 + _random.nextInt(allItems.length - 1);
      final tmp = allItems[0];
      allItems[0] = allItems[swapIndex];
      allItems[swapIndex] = tmp;
    }

    _playlist = _playlist.copyWith(items: allItems, currentIndex: 0);
  }

  /// Update an entry's metadata in the playlist (e.g. after cover import).
  void updateEntry(AudioEntry entry) {
    final items = _playlist.items;
    final index = items.indexWhere((item) => item.entry.id == entry.id);
    if (index < 0) return;

    final updated = List<PlaylistItem>.of(items);
    updated[index] = updated[index].copyWith(entry: entry);
    _playlist = _playlist.copyWith(items: updated);
    _emit();
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
        newCurrentIndex = _clampInt(newCurrentIndex, 0, newItems.length - 1);
      }
      _playlist = _playlist.copyWith(
        items: newItems,
        currentIndex: newCurrentIndex,
      );
    }

    _emit();
  }

  /// Remove all playlist items whose entry ids are present in [entryIds].
  /// Returns true when the playlist actually changed.
  bool removeEntriesByEntryIds(Set<int> entryIds) {
    if (entryIds.isEmpty || _playlist.isEmpty) return false;

    final currentUid = _playlist.currentItem?.uid;
    final newItems =
        _playlist.items
            .where((item) => !entryIds.contains(item.entry.id))
            .toList();

    if (newItems.length == _playlist.items.length) {
      return false;
    }

    if (newItems.isEmpty) {
      _playlist = _playlist.copyWith(items: [], currentIndex: -1);
      _emit();
      return true;
    }

    final preservedCurrentIndex =
        currentUid == null
            ? -1
            : newItems.indexWhere((item) => item.uid == currentUid);
    final nextCurrentIndex =
        preservedCurrentIndex >= 0
            ? preservedCurrentIndex
            : _clampInt(_playlist.currentIndex, 0, newItems.length - 1);

    _playlist = _playlist.copyWith(
      items: newItems,
      currentIndex: nextCurrentIndex,
    );
    _emit();
    return true;
  }

  void setRepeatMode(RepeatMode mode) {
    if (_playlist.repeatMode == mode) return;

    if (_playlist.isNotEmpty && mode == RepeatMode.shuffle) {
      final current = _playlist.currentItem;
      if (current != null) {
        final others =
            _playlist.items.where((i) => i.uid != current.uid).toList()
              ..shuffle(_random);
        _playlist = _playlist.copyWith(
          repeatMode: mode,
          items: [current, ...others],
          currentIndex: 0,
        );
      } else {
        _playlist = _playlist.copyWith(repeatMode: mode);
      }
    } else {
      _playlist = _playlist.copyWith(repeatMode: mode);
    }
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

  /// Update the in-memory entry for the currently playing item.
  /// Used when metadata (e.g. coverPath) changes in the DB.
  void updateCurrentEntry(AudioEntry entry) {
    final current = _playlist.currentItem;
    if (current == null || current.entry.id != entry.id) return;

    final items =
        _playlist.items
            .map(
              (item) =>
                  item.entry.id == entry.id
                      ? PlaylistItem(uid: item.uid, entry: entry)
                      : item,
            )
            .toList();

    _playlist = _playlist.copyWith(items: items);
    _emit();
  }

  void _emit() {
    _controller.add(_playlist);
  }

  int _clampInt(int value, int min, int max) {
    if (max < min) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void dispose() {
    _controller.close();
  }
}
