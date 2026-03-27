import 'package:flutter_test/flutter_test.dart';
import 'package:omao_app/features/resonance/application/services/playlist_service.dart';
import 'package:omao_app/features/resonance/domain/models/audio_entry.dart';
import 'package:omao_app/features/resonance/domain/models/playlist.dart';

void main() {
  late PlaylistService service;
  late AudioEntry entryA;
  late AudioEntry entryB;
  late AudioEntry entryC;
  late AudioEntry entryD;

  setUp(() {
    service = PlaylistService();
    entryA = _entry(1, 'A');
    entryB = _entry(2, 'B');
    entryC = _entry(3, 'C');
    entryD = _entry(4, 'D');
  });

  test('playEntryFromAll creates a single-item playlist when empty', () {
    service.playEntryFromAll(entryA);

    final playlist = service.currentPlaylist;
    expect(playlist.repeatMode, RepeatMode.sequential);
    expect(playlist.currentIndex, 0);
    expect(playlist.items.map((item) => item.entry.id).toList(), [1]);
  });

  test('playEntryFromAll inserts a new entry after current and plays it', () {
    service.playEntryFromCollection(entryB, [entryA, entryB, entryC]);

    service.playEntryFromAll(entryD);

    final playlist = service.currentPlaylist;
    expect(playlist.currentIndex, 2);
    expect(playlist.items.map((item) => item.entry.id).toList(), [1, 2, 4, 3]);
    expect(playlist.currentItem?.entry.id, 4);
  });

  test(
    'playEntryFromAll moves an existing entry after current and plays it',
    () {
      service.playEntryFromCollection(entryB, [entryA, entryB, entryC]);

      service.playEntryFromAll(entryA);

      final playlist = service.currentPlaylist;
      expect(playlist.currentIndex, 1);
      expect(playlist.items.map((item) => item.entry.id).toList(), [2, 1, 3]);
      expect(playlist.currentItem?.entry.id, 1);
    },
  );

  test(
    'playEntryFromCollection without existing playlist always starts sequential',
    () {
      service.setRepeatMode(RepeatMode.single);

      service.playEntryFromCollection(entryB, [entryA, entryB, entryC]);

      final playlist = service.currentPlaylist;
      expect(playlist.repeatMode, RepeatMode.sequential);
      expect(playlist.currentIndex, 1);
      expect(playlist.items.map((item) => item.entry.id).toList(), [1, 2, 3]);
    },
  );

  test(
    'playEntryFromCollection preserves single-repeat with existing playlist',
    () {
      service.playEntryFromAll(entryD);
      service.setRepeatMode(RepeatMode.single);

      service.playEntryFromCollection(entryC, [entryA, entryB, entryC]);

      final playlist = service.currentPlaylist;
      expect(playlist.repeatMode, RepeatMode.single);
      expect(playlist.currentIndex, 2);
      expect(playlist.items.map((item) => item.entry.id).toList(), [1, 2, 3]);
    },
  );

  test(
    'playEntryFromCollection shuffles remaining entries around selected one',
    () {
      service.playEntryFromAll(entryD);
      service.setRepeatMode(RepeatMode.shuffle);

      service.playEntryFromCollection(entryB, [entryA, entryB, entryC]);

      final playlist = service.currentPlaylist;
      expect(playlist.repeatMode, RepeatMode.shuffle);
      expect(playlist.currentIndex, 0);
      expect(playlist.currentItem?.entry.id, 2);
      expect(playlist.items.skip(1).map((item) => item.entry.id).toSet(), {
        1,
        3,
      });
    },
  );

  test('removeEntriesByEntryIds removes entries and clamps current index', () {
    service.playEntryFromCollection(entryC, [entryA, entryB, entryC, entryD]);

    final changed = service.removeEntriesByEntryIds({2, 3});

    final playlist = service.currentPlaylist;
    expect(changed, isTrue);
    expect(playlist.items.map((item) => item.entry.id).toList(), [1, 4]);
    expect(playlist.currentIndex, 1);
    expect(playlist.currentItem?.entry.id, 4);
  });
}

AudioEntry _entry(int id, String title) {
  return AudioEntry(id: id, title: title, filePath: '/tmp/$title.mp3');
}
