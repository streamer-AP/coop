import 'dart:async';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/subtitle.dart';
import '../services/subtitle_service.dart';
import 'player_providers.dart';
import 'resonance_providers.dart';

part 'subtitle_providers.g.dart';

enum SubtitleTranslationLanguage {
  zh('中文'),
  en('English'),
  ja('日本語'),
  ko('한국어');

  const SubtitleTranslationLanguage(this.label);
  final String label;
}

final subtitleFollowEnabledProvider = StateProvider<bool>((ref) => true);
final subtitleTranslationEnabledProvider = StateProvider<bool>((ref) => false);
final subtitleTranslationLanguageProvider =
    StateProvider<SubtitleTranslationLanguage>(
      (ref) => SubtitleTranslationLanguage.zh,
    );
final entryResourceRefreshTickProvider = StateProvider.family<int, int>(
  (ref, entryId) => 0,
);

@riverpod
SubtitleService subtitleService(Ref ref) {
  return SubtitleService();
}

@riverpod
class CurrentSubtitleNotifier extends _$CurrentSubtitleNotifier {
  @override
  ParsedSubtitle? build() {
    // Only watch currentEntry, NOT the full player state (which includes position).
    // Watching position would cause this to rebuild on every tick → flicker.
    final currentEntry = ref.watch(
      playerStateNotifierProvider.select((s) => s.currentEntry),
    );

    if (currentEntry == null) return null;

    ref.watch(entryResourceRefreshTickProvider(currentEntry.id));

    _loadSubtitle(currentEntry.id);
    return state; // Preserve previous state while loading, avoid null flash
  }

  Future<void> _loadSubtitle(int entryId) async {
    final repo = ref.read(resonanceRepositoryProvider);
    final subtitleSvc = ref.read(subtitleServiceProvider);

    final subtitleRefs = await repo.getSubtitlesForEntry(entryId);
    if (subtitleRefs.isEmpty) {
      state = null;
      return;
    }

    final subtitleRef = subtitleRefs.first;
    try {
      final content = await subtitleSvc.readTextFile(subtitleRef.filePath);
      state = subtitleSvc.parse(subtitleRef, content);
    } catch (_) {
      state = null;
    }
  }
}

@Riverpod(keepAlive: true)
class ActiveCueNotifier extends _$ActiveCueNotifier {
  @override
  int build() {
    final position = ref.watch(
      playerStateNotifierProvider.select((s) => s.position),
    );
    final subtitle = ref.watch(currentSubtitleNotifierProvider);

    if (subtitle == null) return -1;

    final subtitleSvc = ref.read(subtitleServiceProvider);
    return subtitleSvc.cueIndexAtPosition(subtitle, position);
  }
}

@riverpod
class FollowModeNotifier extends _$FollowModeNotifier {
  Timer? _restoreTimer;

  @override
  bool build() {
    ref.onDispose(() => _restoreTimer?.cancel());
    return true;
  }

  void disableTemporarily() {
    state = false;
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 3), () {
      state = true;
    });
  }

  void enable() {
    _restoreTimer?.cancel();
    state = true;
  }
}
