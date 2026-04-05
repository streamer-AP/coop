import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

import '../../../../core/logging/app_logger.dart';
import '../../../../core/platform/audio_artwork_bridge.dart';
import '../../../../core/platform/audio_embedded_lyrics_extractor.dart';
import '../../../../core/platform/audio_metadata_bridge.dart';
import '../../../../core/platform/media_extraction_bridge.dart';
import '../models/import_preview.dart';
import '../../domain/models/import_result.dart';
import 'media_support.dart';

/// Callback for reporting import progress: (current, total).
typedef ImportProgressCallback = void Function(int current, int total);

/// File import service: handles previewing and importing files, zip extraction,
/// audio extraction from videos, and automatic resource matching.
class ImportService {
  static const _subtitleExtensions = {'srt', 'vtt', 'lrc', 'sub', 'stl'};
  static const _coverExtensions = {
    'jpg',
    'jpeg',
    'png',
    'tiff',
    'tif',
    'bmp',
    'webp',
    'gif',
    'heif',
    'heic',
    'hdr',
  };
  static const _scriptExtensions = {'md', 'markdown', 'pdf', 'txt'};
  static const _signalExtensions = {'json'};

  static const _subtitlePriority = ['srt', 'vtt', 'sub', 'stl', 'lrc'];
  static const _coverPriority = [
    'jpeg',
    'jpg',
    'png',
    'tiff',
    'tif',
    'gif',
    'webp',
    'bmp',
    'heif',
    'heic',
    'hdr',
  ];
  static const _scriptPriority = ['md', 'markdown', 'pdf', 'txt'];
  static const _cp437ExtendedChars =
      'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥₧ƒáíóúñÑªº¿⌐¬½¼¡«»░▒▓│┤╡╢╖╕╣║╗╝╜╛'
      '┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀αßΓπΣσµτΦΘΩδ∞φε∩≡±≥≤⌠⌡÷≈°∙·√ⁿ²■ ';

  final String _importDir;
  final MediaExtractionBridge _mediaExtractionBridge;
  final AudioArtworkBridge _audioArtworkBridge;
  final AudioMetadataBridge _audioMetadataBridge;
  final AudioEmbeddedLyricsExtractor _audioEmbeddedLyricsExtractor;

  ImportService({
    required String importDirectory,
    MediaExtractionBridge? mediaExtractionBridge,
    AudioArtworkBridge? audioArtworkBridge,
    AudioMetadataBridge? audioMetadataBridge,
    AudioEmbeddedLyricsExtractor? audioEmbeddedLyricsExtractor,
  }) : _importDir = importDirectory,
       _mediaExtractionBridge =
           mediaExtractionBridge ?? MediaExtractionBridge(),
       _audioArtworkBridge = audioArtworkBridge ?? AudioArtworkBridge(),
       _audioMetadataBridge = audioMetadataBridge ?? AudioMetadataBridge(),
       _audioEmbeddedLyricsExtractor =
           audioEmbeddedLyricsExtractor ?? AudioEmbeddedLyricsExtractor();

  /// Pick regular files (non-zip) using the system file picker.
  Future<List<String>?> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    return result?.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
  }

  /// Pick a single zip archive.
  Future<String?> pickZipFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first.path;
  }

  Future<ImportPreview> prepareFilesPreview(List<String> paths) async {
    final normalizedPaths = paths
        .map(p.normalize)
        .toSet()
        .toList(growable: false);

    if (normalizedPaths.isEmpty) {
      throw Exception('未选择任何文件');
    }

    if (!_isSingleDirectorySelection(normalizedPaths)) {
      throw Exception('仅支持选择同一级目录中的文件');
    }

    return _buildPreview(normalizedPaths, sourceType: ImportSourceType.files);
  }

  Future<ImportPreview> prepareZipPreview(
    String zipPath, {
    String? password,
  }) async {
    // Read only the ZIP central directory (file names) without loading
    // any compressed data into memory. This keeps memory usage minimal
    // even for multi-GB archives.
    List<String> entryNames;
    try {
      final inputStream = InputFileStream(zipPath);
      final directory = ZipDirectory();
      directory.read(inputStream, password: password);
      entryNames =
          directory.fileHeaders
              .where((h) => !h.filename.endsWith('/'))
              .map((h) => _repairZipEntryName(h.filename))
              .toList();
      inputStream.close();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('filter') ||
          msg.contains('bad data') ||
          msg.contains('password') ||
          msg.contains('encrypted')) {
        if (password == null || password.isEmpty) {
          throw Exception('该压缩包可能有密码保护，请输入密码后重试');
        }
        throw Exception('密码错误或压缩包损坏，请检查密码后重试');
      }
      rethrow;
    }

    if (entryNames.isEmpty) {
      throw Exception('压缩包为空或密码错误');
    }

    // Build preview from entry names (no real paths on disk yet)
    return _buildPreview(
      entryNames,
      sourceType: ImportSourceType.zip,
      archivePath: zipPath,
    );
  }

  Future<void> cleanupPreview(ImportPreview? preview) async {
    final extractedDir = preview?.extractedDir;
    if (extractedDir == null) return;

    final directory = Directory(extractedDir);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<ImportResult> importPreview(
    ImportPreview preview, {
    ImportProgressCallback? onProgress,
    List<String>? existingTitles,
    String? password,
  }) async {
    if (preview.selectedPaths.isEmpty) {
      throw Exception('请先选择需要导入的文件');
    }

    if (!preview.hasSelectedMedia) {
      throw Exception('请至少选择一个音频或视频文件');
    }

    // For ZIP imports: extract now (deferred from preview stage)
    List<String> paths;
    String? tempDir;
    if (preview.sourceType == ImportSourceType.zip &&
        preview.extractedDir == null &&
        preview.archivePath != null) {
      // Report extraction phase
      onProgress?.call(-1, 0); // -1 signals "extracting"
      final extracted = await _extractZip(
        preview.archivePath!,
        password: password,
      );
      tempDir = extracted.directory;

      // Use all extracted files — the import categorization step will
      // handle which files are media, subtitles, covers, etc.
      // User deselections are rare for ZIP imports; the main use case is
      // selecting everything and importing.
      paths = extracted.paths;
    } else {
      paths = preview.selectedPaths;
    }

    final succeeded = <ImportedItem>[];
    final failed = <ImportFailure>[];

    // Categorize all files
    final mediaFiles = <String>[];
    final subtitleFiles = <String>[];
    final coverFiles = <String>[];
    final scriptFiles = <String>[];
    final signalFiles = <String>[];

    for (final filePath in paths) {
      final ext = p.extension(filePath).toLowerCase().replaceFirst('.', '');
      if (ResonanceMediaSupport.audioExtensions.contains(ext) ||
          ResonanceMediaSupport.videoExtensions.contains(ext)) {
        mediaFiles.add(filePath);
      } else if (_subtitleExtensions.contains(ext)) {
        subtitleFiles.add(filePath);
      } else if (_coverExtensions.contains(ext)) {
        coverFiles.add(filePath);
      } else if (_scriptExtensions.contains(ext)) {
        scriptFiles.add(filePath);
      } else if (_signalExtensions.contains(ext)) {
        signalFiles.add(filePath);
      }
    }

    // Track used titles for deduplication
    final usedTitles = <String>{...?existingTitles};

    final remainingSubtitles = List<String>.of(subtitleFiles);
    final remainingCovers = List<String>.of(coverFiles);
    final remainingScripts = List<String>.of(scriptFiles);
    final remainingSignals = List<String>.of(signalFiles);

    AppLogger().debug(
      'Import: ${mediaFiles.length} media, '
      '${subtitleFiles.length} subtitles, '
      '${coverFiles.length} covers',
    );
    for (final s in subtitleFiles) {
      AppLogger().debug('  subtitle: ${p.basename(s)} baseName=${_baseName(s)}');
    }

    for (var i = 0; i < mediaFiles.length; i++) {
      final mediaPath = mediaFiles[i];
      onProgress?.call(i + 1, mediaFiles.length);

      try {
        final rawTitle = _baseName(mediaPath);
        AppLogger().debug('  media[$i]: baseName=$rawTitle');
        final title = _deduplicateTitle(rawTitle, usedTitles);
        usedTitles.add(title);

        final destPath = await _importMediaFile(mediaPath, rawTitle);
        const mediaType = 'audio';

        final matchedSubtitle = _takeBestMatch(
          rawTitle,
          remainingSubtitles,
          _subtitlePriority,
        );
        AppLogger().debug(
          '  match result: subtitle=${matchedSubtitle != null ? p.basename(matchedSubtitle) : "NONE"}'
          ' (remaining=${remainingSubtitles.length})',
        );
        final matchedCover = _takeBestMatch(
          rawTitle,
          remainingCovers,
          _coverPriority,
        );
        final matchedScript = _takeBestMatch(
          rawTitle,
          remainingScripts,
          _scriptPriority,
        );
        final matchedSignal = _takeBestMatch(rawTitle, remainingSignals, null);

        String? subtitleDest;
        String? coverDest;
        String? scriptDest;
        String? signalDest;

        if (matchedSubtitle != null) {
          subtitleDest = await _copyToImportDir(matchedSubtitle);
        }
        if (matchedCover != null) {
          coverDest = await _copyToImportDir(matchedCover);
        } else {
          coverDest = await _extractEmbeddedCoverIfAvailable(
            audioPath: destPath,
            rawTitle: rawTitle,
          );
        }
        if (matchedScript != null) {
          scriptDest = await _copyToImportDir(matchedScript);
        }
        if (matchedSignal != null) {
          signalDest = await _copyToImportDir(matchedSignal);
        }

        // Try to read audio duration
        String? artist;
        String? album;
        int durationMs = 0;
        try {
          final player = AudioPlayer();
          try {
            final duration = await player.setFilePath(destPath);
            durationMs = duration?.inMilliseconds ?? 0;
          } finally {
            await player.dispose();
          }
        } catch (error) {
          throw Exception(_normalizeMediaProbeError(error, destPath));
        }

        final embeddedMetadata = await _extractEmbeddedMetadataIfAvailable(
          audioPath: destPath,
        );
        artist = embeddedMetadata?.artist;
        album = embeddedMetadata?.album;

        if (subtitleDest == null) {
          final embeddedLyrics = await _extractEmbeddedLyricsIfAvailable(
            audioPath: destPath,
          );
          if (embeddedLyrics?.timedLyrics != null) {
            subtitleDest = await _writeGeneratedTextResource(
              rawTitle: rawTitle,
              suffix: '_embedded_lyrics',
              extension: '.lrc',
              content: embeddedLyrics!.timedLyrics!,
            );
          } else if (scriptDest == null &&
              embeddedLyrics?.plainLyrics != null) {
            scriptDest = await _writeGeneratedTextResource(
              rawTitle: rawTitle,
              suffix: '_embedded_lyrics',
              extension: '.txt',
              content: embeddedLyrics!.plainLyrics!,
            );
          }
        }

        // LRC metadata tags are a fallback only. We don't override the
        // preserved filename-based title, and we only fill missing artist data.
        if (artist == null && matchedSubtitle != null) {
          try {
            final subExt = p.extension(matchedSubtitle).toLowerCase();
            if (subExt == '.lrc') {
              final lrcContent =
                  await File(subtitleDest ?? matchedSubtitle).readAsString();
              final arMatch = RegExp(r'\[ar:(.+?)\]').firstMatch(lrcContent);
              if (arMatch != null) {
                artist = arMatch.group(1)?.trim();
              }
            }
          } catch (_) {}
        }

        succeeded.add(
          ImportedItem(
            title: title,
            filePath: destPath,
            coverPath: coverDest,
            subtitlePath: subtitleDest,
            scriptPath: scriptDest,
            signalPath: signalDest,
            artist: artist,
            album: album,
            durationMs: durationMs,
            mediaType: mediaType,
          ),
        );
      } catch (e) {
        failed.add(
          ImportFailure(
            fileName: p.basename(mediaPath),
            reason: _normalizeError(e),
          ),
        );
      }
    }

    AppLogger().info(
      'Import complete: ${succeeded.length} succeeded, ${failed.length} failed',
    );

    // Clean up temp extraction directory for deferred ZIP imports
    if (tempDir != null) {
      try {
        await Directory(tempDir).delete(recursive: true);
      } catch (_) {}
    }

    return ImportResult(succeeded: succeeded, failed: failed);
  }

  /// Deduplicate title by appending numeric suffix.
  /// e.g. "file" → "file", "file" → "file1", "file" → "file2"
  String _deduplicateTitle(String title, Set<String> usedTitles) {
    if (!usedTitles.contains(title)) return title;

    var counter = 1;
    while (usedTitles.contains('$title$counter')) {
      counter++;
    }
    return '$title$counter';
  }

  String? _takeBestMatch(
    String mediaBaseName,
    List<String> candidates,
    List<String>? extensionPriority,
  ) {
    final matches =
        <
          ({
            String path,
            int rulePriority,
            int extensionRank,
            int originalIndex,
          })
        >[];

    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      final candidateBaseName = _baseName(candidate);
      final rulePriority = _matchRulePriority(mediaBaseName, candidateBaseName);
      if (rulePriority == null) continue;

      final extension = p
          .extension(candidate)
          .toLowerCase()
          .replaceFirst('.', '');
      final extensionRank =
          extensionPriority == null ? 0 : extensionPriority.indexOf(extension);

      matches.add((
        path: candidate,
        rulePriority: rulePriority,
        extensionRank: extensionRank == -1 ? 999 : extensionRank,
        originalIndex: index,
      ));
    }

    if (matches.isEmpty) {
      return null;
    }

    matches.sort((a, b) {
      final byRule = a.rulePriority.compareTo(b.rulePriority);
      if (byRule != 0) return byRule;

      final byExtension = a.extensionRank.compareTo(b.extensionRank);
      if (byExtension != 0) return byExtension;

      return a.originalIndex.compareTo(b.originalIndex);
    });

    final bestMatch = matches.first.path;
    candidates.remove(bestMatch);
    return bestMatch;
  }

  String _baseName(String path) {
    var name = p.basenameWithoutExtension(path);
    // Strip additional known media extensions (e.g. "song.wav.vtt" → "song")
    final knownExts = {
      ...ResonanceMediaSupport.audioExtensions,
      ...ResonanceMediaSupport.videoExtensions,
    };
    final trailing = p.extension(name).toLowerCase().replaceFirst('.', '');
    if (knownExts.contains(trailing)) {
      name = p.withoutExtension(name);
    }
    return name;
  }

  Future<String> _importMediaFile(String mediaPath, String rawTitle) async {
    final ext = p.extension(mediaPath).toLowerCase().replaceFirst('.', '');
    if (ResonanceMediaSupport.videoExtensions.contains(ext)) {
      // Native extraction now decides the real output container by audio codec.
      final suggestedOutputPath = await _reserveImportPath('$rawTitle.m4a');
      final extractedPath = await _mediaExtractionBridge.extractAudio(
        inputPath: mediaPath,
        outputPath: suggestedOutputPath,
      );
      await ResonanceMediaSupport.ensureLikelyPlayableMediaFile(
        extractedPath,
        label: '提取后的音频文件',
      );
      return extractedPath;
    }

    final copiedPath = await _copyToImportDir(mediaPath);
    await ResonanceMediaSupport.ensureLikelyPlayableMediaFile(
      copiedPath,
      label: '导入后的音频文件',
    );
    return copiedPath;
  }

  Future<String> _copyToImportDir(String sourcePath) async {
    final fileName = p.basename(sourcePath);
    final destPath = await _reserveImportPath(fileName);
    await _copyFileWithRetry(sourcePath, destPath);
    return destPath;
  }

  Future<String?> _extractEmbeddedCoverIfAvailable({
    required String audioPath,
    required String rawTitle,
  }) async {
    try {
      final suggestedOutputPath = await _reserveImportPath(
        '${rawTitle}_cover.jpg',
      );
      return await _audioArtworkBridge.extractEmbeddedArtwork(
        inputPath: audioPath,
        outputPath: suggestedOutputPath,
      );
    } catch (error, stackTrace) {
      AppLogger().warning(
        'Failed to extract embedded artwork for $audioPath: $error\n$stackTrace',
      );
      return null;
    }
  }

  Future<AudioEmbeddedMetadata?> _extractEmbeddedMetadataIfAvailable({
    required String audioPath,
  }) async {
    try {
      return await _audioMetadataBridge.extractEmbeddedMetadata(
        inputPath: audioPath,
      );
    } catch (error, stackTrace) {
      AppLogger().warning(
        'Failed to extract embedded metadata for $audioPath: $error\n$stackTrace',
      );
      return null;
    }
  }

  Future<EmbeddedLyricsData?> _extractEmbeddedLyricsIfAvailable({
    required String audioPath,
  }) async {
    try {
      return await _audioEmbeddedLyricsExtractor.extract(inputPath: audioPath);
    } catch (error, stackTrace) {
      AppLogger().warning(
        'Failed to extract embedded lyrics for $audioPath: $error\n$stackTrace',
      );
      return null;
    }
  }

  Future<String> _writeGeneratedTextResource({
    required String rawTitle,
    required String suffix,
    required String extension,
    required String content,
  }) async {
    final destPath = await _reserveImportPath('$rawTitle$suffix$extension');
    await File(destPath).writeAsString(
      content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim(),
      encoding: utf8,
    );
    return destPath;
  }

  Future<void> _copyFileWithRetry(String sourcePath, String destPath) async {
    final sourceFile = File(sourcePath);
    final destFile = File(destPath);

    await ResonanceMediaSupport.runWithPendingFsRetry(() async {
      if (await destFile.exists()) {
        await destFile.delete();
      }

      final sink = destFile.openWrite();
      try {
        await sink.addStream(sourceFile.openRead());
      } finally {
        await sink.close();
      }
    });
  }

  Future<String> _reserveImportPath(String fileName) async {
    var destPath = p.join(_importDir, fileName);
    final destFile = File(destPath);

    if (!await destFile.parent.exists()) {
      await destFile.parent.create(recursive: true);
    }

    if (!await destFile.exists()) {
      return destPath;
    }

    final baseName = p.basenameWithoutExtension(fileName);
    final ext = p.extension(fileName);
    var counter = 1;
    const maxAttempts = 100;

    do {
      destPath = p.join(_importDir, '$baseName($counter)$ext');
      counter++;
    } while (await File(destPath).exists() && counter <= maxAttempts);

    if (counter > maxAttempts && await File(destPath).exists()) {
      throw Exception('文件名冲突次数超过上限: $fileName');
    }

    return destPath;
  }

  Future<({String directory, List<String> paths})> _extractZip(
    String zipPath, {
    String? password,
  }) async {
    // Check file size — warn for very large archives
    final zipFileSize = await File(zipPath).length();
    if (zipFileSize > 2 * 1024 * 1024 * 1024) {
      // > 2GB: likely to cause OOM
      throw Exception('压缩包过大（${(zipFileSize / 1024 / 1024 / 1024).toStringAsFixed(1)}GB），'
          '请拆分后导入或直接导入文件');
    }

    final inputStream = InputFileStream(zipPath);

    Archive archive;
    try {
      archive = ZipDecoder().decodeStream(inputStream, password: password);
    } catch (e) {
      inputStream.close();
      final msg = e.toString().toLowerCase();
      if (msg.contains('filter') ||
          msg.contains('bad data') ||
          msg.contains('password') ||
          msg.contains('encrypted')) {
        if (password == null || password.isEmpty) {
          throw Exception('该压缩包可能有密码保护，请输入密码后重试');
        }
        throw Exception('密码错误或压缩包损坏，请检查密码后重试');
      }
      rethrow;
    }

    if (archive.isEmpty) {
      inputStream.close();
      throw Exception('压缩包为空或密码错误');
    }

    final extractDir = await Directory.systemTemp.createTemp(
      'omao_zip_${p.basenameWithoutExtension(zipPath)}_',
    );

    final extractedPaths = <String>[];

    for (final file in archive) {
      if (!file.isFile) continue;
      final repairedEntryName = _repairZipEntryName(file.name);
      final outPath = p.join(extractDir.path, repairedEntryName);
      await File(outPath).parent.create(recursive: true);
      final outStream = OutputFileStream(outPath);
      file.writeContent(outStream);
      outStream.close();
      extractedPaths.add(outPath);
    }

    inputStream.close();

    if (extractedPaths.isEmpty) {
      throw Exception('压缩包为空或密码错误');
    }

    return (directory: extractDir.path, paths: extractedPaths);
  }

  ImportPreview _buildPreview(
    List<String> paths, {
    required ImportSourceType sourceType,
    String? archivePath,
    String? extractedDir,
  }) {
    var items = paths
        .map((filePath) {
          final type = _classifyFile(filePath);
          final selectable = type != ImportPreviewItemType.unsupported;
          final name =
              extractedDir == null
                  ? p.basename(filePath)
                  : p.relative(filePath, from: extractedDir);

          return ImportPreviewItem(
            path: filePath,
            name: name,
            type: type,
            selected: selectable,
            selectable: selectable,
          );
        })
        .toList();

    // Pre-match subtitles/covers/scripts to media files for preview display
    items = _matchPreviewItems(items);

    return ImportPreview(
      sourceType: sourceType,
      items: items,
      archivePath: archivePath,
      extractedDir: extractedDir,
    );
  }

  List<ImportPreviewItem> _matchPreviewItems(List<ImportPreviewItem> items) {
    final mediaItems =
        items.where((item) => item.isMedia).toList();
    if (mediaItems.isEmpty) return items;

    final mediaBaseNames =
        mediaItems.map((item) => _baseName(item.path)).toList();

    return items.map((item) {
      if (item.isMedia ||
          item.type == ImportPreviewItemType.unsupported) {
        return item;
      }
      final itemBaseName = _baseName(item.path);
      for (var i = 0; i < mediaBaseNames.length; i++) {
        final priority = _matchRulePriority(mediaBaseNames[i], itemBaseName);
        if (priority != null) {
          return item.copyWith(
            matchedTo: mediaItems[i].name,
          );
        }
      }
      return item;
    }).toList();
  }

  ImportPreviewItemType _classifyFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    if (ResonanceMediaSupport.audioExtensions.contains(ext)) {
      return ImportPreviewItemType.audio;
    }
    if (ResonanceMediaSupport.videoExtensions.contains(ext)) {
      return ImportPreviewItemType.video;
    }
    if (_subtitleExtensions.contains(ext)) {
      return ImportPreviewItemType.subtitle;
    }
    if (_coverExtensions.contains(ext)) {
      return ImportPreviewItemType.cover;
    }
    if (_scriptExtensions.contains(ext)) {
      return ImportPreviewItemType.script;
    }
    if (_signalExtensions.contains(ext)) {
      return ImportPreviewItemType.signal;
    }
    return ImportPreviewItemType.unsupported;
  }

  /// On Android, FilePicker copies files to cache, so paths may differ even
  /// when the user selected from one directory. We only enforce this check
  /// when paths clearly come from different real directories (non-cache paths).
  bool _isSingleDirectorySelection(List<String> paths) {
    if (paths.length <= 1) return true;

    final parentDirectories =
        paths.map((path) => p.normalize(p.dirname(path))).toSet();

    // If all files share the same parent, pass.
    if (parentDirectories.length <= 1) return true;

    // On Android, FilePicker caches files under the app cache directory.
    // Different picker invocations or content providers may use different
    // cache sub-paths. Allow this case.
    final allCacheOrPicker = parentDirectories.every(
      (dir) => dir.contains('cache') || dir.contains('file_picker'),
    );
    if (allCacheOrPicker) return true;

    // Otherwise, genuinely different directories.
    return false;
  }

  int? _matchRulePriority(String mediaBaseName, String candidateBaseName) {
    if (candidateBaseName == mediaBaseName) {
      return 0;
    }

    if (candidateBaseName.startsWith(mediaBaseName)) {
      return 1;
    }

    final mediaFirstSegment = mediaBaseName.split('.').first;
    final candidateFirstSegment = candidateBaseName.split('.').first;
    if (candidateFirstSegment == mediaFirstSegment) {
      return 2;
    }

    return null;
  }

  String _normalizeError(Object error) {
    if (error is FileSystemException &&
        ResonanceMediaSupport.isPendingFsOperation(error)) {
      return '文件正在被系统读取，请稍后重试';
    }

    final message = '$error'.trim();
    if (message.startsWith('FileSystemException: ')) {
      return message.substring('FileSystemException: '.length);
    }
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    if (message.startsWith('Unsupported operation: ')) {
      return message.substring('Unsupported operation: '.length);
    }
    return message;
  }

  String _repairZipEntryName(String rawName) {
    final normalized = rawName.replaceAll('\\', '/');
    final repairedUtf8 = _tryDecodeCp437AsUtf8(normalized);
    if (repairedUtf8 != null &&
        _isRepairBetter(original: normalized, repaired: repairedUtf8)) {
      return repairedUtf8;
    }
    return normalized;
  }

  String? _tryDecodeCp437AsUtf8(String value) {
    final bytes = <int>[];

    for (final rune in value.runes) {
      if (rune >= 0 && rune < 128) {
        bytes.add(rune);
        continue;
      }

      final char = String.fromCharCode(rune);
      final index = _cp437ExtendedChars.indexOf(char);
      if (index < 0) {
        return null;
      }
      bytes.add(128 + index);
    }

    try {
      return utf8.decode(bytes, allowMalformed: false);
    } catch (_) {
      return null;
    }
  }

  bool _isRepairBetter({required String original, required String repaired}) {
    if (original == repaired) {
      return false;
    }

    return _nameReadabilityScore(repaired) >
        _nameReadabilityScore(original) + 2;
  }

  int _nameReadabilityScore(String value) {
    var score = 0;

    for (final rune in value.runes) {
      if (_isCjkRune(rune)) {
        score += 3;
        continue;
      }

      if (rune >= 0x20 && rune <= 0x7E) {
        score += 1;
        continue;
      }

      final char = String.fromCharCode(rune);
      if (_cp437ExtendedChars.contains(char)) {
        score -= 1;
      }
    }

    return score;
  }

  bool _isCjkRune(int rune) {
    return (rune >= 0x4E00 && rune <= 0x9FFF) ||
        (rune >= 0x3400 && rune <= 0x4DBF) ||
        (rune >= 0xF900 && rune <= 0xFAFF);
  }

  String _normalizeMediaProbeError(Object error, String path) {
    final raw = '$error'.trim();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }

    if (error is PlayerInterruptedException) {
      return '音频导入被中断，请重新导入：${p.basename(path)}';
    }

    if (error is PlayerException) {
      return '音频加载失败，请检查文件格式或重新导入：${p.basename(path)}';
    }

    if (error is PlatformException || error is FileSystemException) {
      return '媒体文件读取失败，请检查文件是否完整：${p.basename(path)}';
    }

    return '当前音频无法播放，请检查文件格式后重试';
  }

  Set<String> get subtitleExtensions => _subtitleExtensions;

  Set<String> get coverExtensions => _coverExtensions;

  Set<String> get scriptExtensions => _scriptExtensions;

  Set<String> get signalExtensions => _signalExtensions;
}
