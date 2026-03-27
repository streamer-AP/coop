import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../../../core/platform/text_translation_bridge.dart';
import '../../../../core/storage/file_manager.dart';
import '../../domain/models/subtitle.dart';
import '../../domain/repositories/resonance_repository.dart';
import 'subtitle_service.dart';

class SubtitleTranslationService {
  SubtitleTranslationService({
    required ResonanceRepository repository,
    required SubtitleService subtitleService,
    required FileManager fileManager,
    TextTranslationBridge? textTranslationBridge,
  }) : _repository = repository,
       _subtitleService = subtitleService,
       _fileManager = fileManager,
       _textTranslationBridge =
           textTranslationBridge ?? TextTranslationBridge();

  static const _supportedLanguageCodes = {'zh', 'ja'};
  static const _translationBatchSize = 24;

  final ResonanceRepository _repository;
  final SubtitleService _subtitleService;
  final FileManager _fileManager;
  final TextTranslationBridge _textTranslationBridge;

  Future<ParsedSubtitle?> loadOrCreateTranslatedSubtitle({
    required int entryId,
    required String targetLanguage,
  }) async {
    final normalizedTarget = _normalizeLanguageCode(targetLanguage);
    if (!_supportedLanguageCodes.contains(normalizedTarget)) {
      throw Exception('当前仅支持中日互译');
    }

    final subtitleRefs = await _repository.getSubtitlesForEntry(entryId);
    if (subtitleRefs.isEmpty) {
      return null;
    }

    final cachedRef = subtitleRefs.lastWhereOrNull(
      (ref) => _normalizeLanguageCode(ref.language) == normalizedTarget,
    );
    if (cachedRef != null) {
      return _parseSubtitle(cachedRef);
    }

    final sourceRef = _findSourceSubtitle(subtitleRefs, normalizedTarget);
    if (sourceRef == null) {
      return null;
    }

    final sourceSubtitle = await _parseSubtitle(sourceRef);
    if (sourceSubtitle.cues.isEmpty) {
      return null;
    }

    final sourceLanguage = _resolveSourceLanguage(sourceRef, sourceSubtitle);
    if (sourceLanguage == null) {
      throw Exception('暂时无法识别字幕语言，仅支持中日互译');
    }
    if (sourceLanguage == normalizedTarget) {
      return null;
    }

    final translatedTexts = await _translateCueTexts(
      cues: sourceSubtitle.cues,
      sourceLanguage: sourceLanguage,
      targetLanguage: normalizedTarget,
    );
    if (translatedTexts.length != sourceSubtitle.cues.length) {
      throw Exception('翻译结果数量异常，请重试');
    }

    final translatedCues = [
      for (var i = 0; i < sourceSubtitle.cues.length; i++)
        SubtitleCue(
          start: sourceSubtitle.cues[i].start,
          end: sourceSubtitle.cues[i].end,
          text: translatedTexts[i],
        ),
    ];

    await _deleteExistingTranslation(entryId, normalizedTarget, subtitleRefs);
    final translatedPath = await _writeTranslatedSubtitleFile(
      entryId: entryId,
      targetLanguage: normalizedTarget,
      sourcePath: sourceRef.filePath,
      cues: translatedCues,
    );

    final translatedRef = SubtitleRef(
      id: 0,
      entryId: entryId,
      language: normalizedTarget,
      filePath: translatedPath,
      format: SubtitleFormat.srt,
    );
    await _repository.insertSubtitle(translatedRef);

    return ParsedSubtitle(ref: translatedRef, cues: translatedCues);
  }

  SubtitleRef? _findSourceSubtitle(
    List<SubtitleRef> subtitleRefs,
    String targetLanguage,
  ) {
    final candidates = subtitleRefs
        .where((ref) => _normalizeLanguageCode(ref.language) != targetLanguage)
        .toList(growable: false);
    if (candidates.isEmpty) {
      return null;
    }

    return candidates.firstWhereOrNull(
          (ref) =>
              !_supportedLanguageCodes.contains(
                _normalizeLanguageCode(ref.language),
              ),
        ) ??
        candidates.firstWhereOrNull(
          (ref) => _normalizeLanguageCode(ref.language) == 'default',
        ) ??
        candidates.first;
  }

  Future<ParsedSubtitle> _parseSubtitle(SubtitleRef ref) async {
    final content = await _subtitleService.readTextFile(ref.filePath);
    return _subtitleService.parse(ref, content);
  }

  String? _resolveSourceLanguage(SubtitleRef ref, ParsedSubtitle subtitle) {
    final normalized = _normalizeLanguageCode(ref.language);
    if (_supportedLanguageCodes.contains(normalized)) {
      return normalized;
    }

    final sample = subtitle.cues
        .take(12)
        .map((cue) => cue.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');
    if (sample.isEmpty) {
      return null;
    }

    return _guessLanguageFromText(sample);
  }

  String? _guessLanguageFromText(String text) {
    var kanaCount = 0;
    var cjkCount = 0;

    for (final rune in text.runes) {
      if ((rune >= 0x3040 && rune <= 0x309F) ||
          (rune >= 0x30A0 && rune <= 0x30FF) ||
          (rune >= 0x31F0 && rune <= 0x31FF)) {
        kanaCount++;
        continue;
      }

      if ((rune >= 0x4E00 && rune <= 0x9FFF) ||
          (rune >= 0x3400 && rune <= 0x4DBF) ||
          (rune >= 0xF900 && rune <= 0xFAFF)) {
        cjkCount++;
      }
    }

    if (kanaCount > 0) {
      return 'ja';
    }
    if (cjkCount > 0) {
      return 'zh';
    }
    return null;
  }

  Future<List<String>> _translateCueTexts({
    required List<SubtitleCue> cues,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final translated = <String>[];

    for (
      var offset = 0;
      offset < cues.length;
      offset += _translationBatchSize
    ) {
      final batch = cues.skip(offset).take(_translationBatchSize).toList();
      final requestIndexes = <int>[];
      final requestTexts = <String>[];
      final batchOutput = List<String>.filled(batch.length, '');

      for (var i = 0; i < batch.length; i++) {
        final originalText = batch[i].text;
        final text = originalText.trim();
        if (text.isEmpty) {
          batchOutput[i] = batch[i].text;
          continue;
        }

        final cueLanguage = _classifyCueLanguage(text);
        final cueLanguageCode = _cueLanguageCode(cueLanguage);
        if (cueLanguage == _CueLanguage.other ||
            cueLanguage == _CueLanguage.mixed ||
            cueLanguageCode == null ||
            cueLanguageCode == targetLanguage ||
            cueLanguageCode != sourceLanguage) {
          batchOutput[i] = originalText;
          continue;
        }

        requestIndexes.add(i);
        requestTexts.add(originalText);
      }

      if (requestTexts.isNotEmpty) {
        final responses = await _textTranslationBridge.translateBatch(
          texts: requestTexts,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
        if (responses.length != requestIndexes.length) {
          throw Exception('翻译结果缺失，请稍后重试');
        }
        for (var i = 0; i < requestIndexes.length; i++) {
          batchOutput[requestIndexes[i]] = responses[i].trim();
        }
      }

      translated.addAll(batchOutput);
    }

    return translated;
  }

  Future<void> _deleteExistingTranslation(
    int entryId,
    String targetLanguage,
    List<SubtitleRef> subtitleRefs,
  ) async {
    final existing = subtitleRefs
        .where((ref) => _normalizeLanguageCode(ref.language) == targetLanguage)
        .toList(growable: false);
    if (existing.isEmpty) {
      return;
    }

    for (final ref in existing) {
      final file = File(ref.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _repository.deleteSubtitlesForEntryLanguage(entryId, targetLanguage);
  }

  Future<String> _writeTranslatedSubtitleFile({
    required int entryId,
    required String targetLanguage,
    required String sourcePath,
    required List<SubtitleCue> cues,
  }) async {
    final translationDir = Directory(
      p.join(_fileManager.getImportDirectory(), 'translated_subtitles'),
    );
    if (!await translationDir.exists()) {
      await translationDir.create(recursive: true);
    }

    final sourceBaseName = p.basenameWithoutExtension(sourcePath);
    final filePath = p.join(
      translationDir.path,
      'entry_${entryId}_${sourceBaseName}_$targetLanguage.srt',
    );
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    await file.writeAsString(_buildSrtContent(cues), flush: true);
    return file.path;
  }

  String _buildSrtContent(List<SubtitleCue> cues) {
    final buffer = StringBuffer();
    for (var i = 0; i < cues.length; i++) {
      final cue = cues[i];
      buffer
        ..writeln(i + 1)
        ..writeln(
          '${_formatSrtDuration(cue.start)} --> ${_formatSrtDuration(cue.end)}',
        )
        ..writeln(cue.text)
        ..writeln();
    }
    return buffer.toString();
  }

  String _formatSrtDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(
      3,
      '0',
    );
    return '$hours:$minutes:$seconds,$milliseconds';
  }

  String _normalizeLanguageCode(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.startsWith('zh')) {
      return 'zh';
    }
    if (normalized.startsWith('ja')) {
      return 'ja';
    }
    return normalized;
  }

  _CueLanguage _classifyCueLanguage(String text) {
    var hasKana = false;
    var hasCjk = false;

    for (final rune in text.runes) {
      if ((rune >= 0x3040 && rune <= 0x309F) ||
          (rune >= 0x30A0 && rune <= 0x30FF) ||
          (rune >= 0x31F0 && rune <= 0x31FF)) {
        hasKana = true;
        continue;
      }

      if ((rune >= 0x4E00 && rune <= 0x9FFF) ||
          (rune >= 0x3400 && rune <= 0x4DBF) ||
          (rune >= 0xF900 && rune <= 0xFAFF)) {
        hasCjk = true;
      }
    }

    if (hasKana && hasCjk) {
      return _CueLanguage.mixed;
    }
    if (hasKana) {
      return _CueLanguage.ja;
    }
    if (hasCjk) {
      return _CueLanguage.zh;
    }
    return _CueLanguage.other;
  }

  String? _cueLanguageCode(_CueLanguage language) {
    return switch (language) {
      _CueLanguage.zh => 'zh',
      _CueLanguage.ja => 'ja',
      _CueLanguage.mixed || _CueLanguage.other => null,
    };
  }
}

enum _CueLanguage { zh, ja, mixed, other }
