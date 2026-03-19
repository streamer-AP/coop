import 'dart:async';
import 'dart:io';

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

@riverpod
SubtitleService subtitleService(Ref ref) {
  return SubtitleService();
}

@riverpod
class CurrentSubtitleNotifier extends _$CurrentSubtitleNotifier {
  @override
  ParsedSubtitle? build() {
    final playerState = ref.watch(playerStateNotifierProvider);
    final currentEntry = playerState.currentEntry;

    if (currentEntry == null) return null;

    _loadSubtitle(currentEntry.id);
    return null;
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
      final content = await File(subtitleRef.filePath).readAsString();
      state = subtitleSvc.parse(subtitleRef, content);
    } catch (_) {
      state = null;
    }
  }
}

@riverpod
class ActiveCueNotifier extends _$ActiveCueNotifier {
  @override
  int build() {
    final playerState = ref.watch(playerStateNotifierProvider);
    final subtitle = ref.watch(currentSubtitleNotifierProvider);

    if (subtitle == null) return -1;

    final subtitleSvc = ref.read(subtitleServiceProvider);
    return subtitleSvc.cueIndexAtPosition(subtitle, playerState.position);
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
