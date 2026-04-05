import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/storage/file_manager.dart';
import '../../domain/models/subtitle.dart';
import '../services/subtitle_service.dart';
import '../services/subtitle_translation_service.dart';
import 'player_providers.dart';
import 'resonance_providers.dart';

part 'subtitle_providers.g.dart';

enum SubtitleTranslationLanguage {
  zh('中文', 'zh'),
  ja('日本語', 'ja');

  const SubtitleTranslationLanguage(this.label, this.code);
  final String label;
  final String code;
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
SubtitleTranslationService subtitleTranslationService(Ref ref) {
  return SubtitleTranslationService(
    repository: ref.watch(resonanceRepositoryProvider),
    subtitleService: ref.watch(subtitleServiceProvider),
    fileManager: ref.watch(fileManagerProvider),
  );
}

@riverpod
class CurrentSubtitleNotifier extends _$CurrentSubtitleNotifier {
  int _loadGeneration = 0;

  @override
  ParsedSubtitle? build() {
    // Only watch currentEntry, NOT the full player state (which includes position).
    // Watching position would cause this to rebuild on every tick → flicker.
    final generation = ++_loadGeneration;
    final currentEntry = ref.watch(
      playerStateNotifierProvider.select((s) => s.currentEntry),
    );

    if (currentEntry == null) return null;

    ref.watch(entryResourceRefreshTickProvider(currentEntry.id));

    _loadSubtitle(currentEntry.id, generation);
    return state; // Preserve previous state while loading, avoid null flash
  }

  Future<void> _loadSubtitle(int entryId, int generation) async {
    final repo = ref.read(resonanceRepositoryProvider);
    final subtitleSvc = ref.read(subtitleServiceProvider);

    final subtitleRefs = await repo.getSubtitlesForEntry(entryId);
    AppLogger().debug(
      'SubtitleLoad: entryId=$entryId refs=${subtitleRefs.length}'
      '${subtitleRefs.isNotEmpty ? " path=${subtitleRefs.first.filePath}" : ""}',
    );
    if (_isStaleLoad(entryId, generation)) {
      return;
    }
    if (subtitleRefs.isEmpty) {
      state = null;
      return;
    }

    final subtitleRef = _pickPrimarySubtitleRef(subtitleRefs);
    try {
      final content = await subtitleSvc.readTextFile(subtitleRef.filePath);
      if (_isStaleLoad(entryId, generation)) {
        return;
      }
      AppLogger().debug(
        'SubtitleLoad: content length=${content.length}'
        ' first100=${content.substring(0, content.length > 100 ? 100 : content.length).replaceAll('\n', '\\n')}',
      );
      final parsed = subtitleSvc.parse(subtitleRef, content);
      AppLogger().debug(
        'SubtitleLoad: parsed cues=${parsed.cues.length}'
        ' format=${subtitleRef.format}',
      );
      state = parsed;
    } catch (e) {
      AppLogger().error('SubtitleLoad: parse error', error: e);
      if (_isStaleLoad(entryId, generation)) {
        return;
      }
      state = null;
    }
  }

  bool _isStaleLoad(int entryId, int generation) {
    return generation != _loadGeneration ||
        ref.read(playerStateNotifierProvider).currentEntry?.id != entryId;
  }
}

SubtitleRef _pickPrimarySubtitleRef(List<SubtitleRef> subtitleRefs) {
  return subtitleRefs.firstWhereOrNull(
        (ref) => _normalizeSubtitleLanguage(ref.language) == 'default',
      ) ??
      subtitleRefs.firstWhereOrNull(
        (ref) =>
            !_translationLanguageCodes.contains(
              _normalizeSubtitleLanguage(ref.language),
            ),
      ) ??
      subtitleRefs.first;
}

String _normalizeSubtitleLanguage(String language) {
  final normalized = language.trim().toLowerCase();
  if (normalized.startsWith('zh')) {
    return 'zh';
  }
  if (normalized.startsWith('ja')) {
    return 'ja';
  }
  return normalized;
}

const _translationLanguageCodes = {'zh', 'ja'};

@riverpod
Future<ParsedSubtitle?> translatedSubtitle(Ref ref) async {
  final enabled = ref.watch(subtitleTranslationEnabledProvider);
  if (!enabled) {
    return null;
  }

  final currentEntry = ref.watch(
    playerStateNotifierProvider.select((state) => state.currentEntry),
  );
  if (currentEntry == null) {
    return null;
  }

  ref.watch(entryResourceRefreshTickProvider(currentEntry.id));
  final targetLanguage = ref.watch(subtitleTranslationLanguageProvider);

  return ref
      .watch(subtitleTranslationServiceProvider)
      .loadOrCreateTranslatedSubtitle(
        entryId: currentEntry.id,
        targetLanguage: targetLanguage.code,
      );
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
