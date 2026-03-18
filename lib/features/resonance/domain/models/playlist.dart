import 'package:freezed_annotation/freezed_annotation.dart';

import 'audio_entry.dart';

part 'playlist.freezed.dart';

enum RepeatMode {
  sequential,
  single,
  shuffle,
}

@freezed
class PlaylistItem with _$PlaylistItem {
  const factory PlaylistItem({
    required String uid,
    required AudioEntry entry,
  }) = _PlaylistItem;
}

@freezed
class Playlist with _$Playlist {
  const factory Playlist({
    @Default([]) List<PlaylistItem> items,
    @Default(-1) int currentIndex,
    @Default(RepeatMode.sequential) RepeatMode repeatMode,
  }) = _Playlist;

  const Playlist._();

  PlaylistItem? get currentItem =>
      currentIndex >= 0 && currentIndex < items.length
          ? items[currentIndex]
          : null;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
}
