import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/logging/app_logger.dart';
import '../../../../core/platform/media_extraction_bridge.dart';
import '../models/import_preview.dart';
import '../../domain/models/import_result.dart';
import 'media_support.dart';

/// Callback for reporting import progress: (current, total).
typedef ImportProgressCallback = void Function(int current, int total);

/// File import service: handles previewing and importing files, zip extraction,
/// audio extraction from videos, and automatic resource matching.
class ImportService {
  static const _subtitleExtensions = {'srt', 'vtt', 'lrc', 'sub', 'stl', 'txt'};
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
  static const _scriptExtensions = {
    'md',
    'markdown',
    'pdf',
    'rtf',
    'doc',
    'docx',
  };
  static const _signalExtensions = {'json'};

  static const _subtitlePriority = ['srt', 'vtt', 'sub', 'stl', 'lrc', 'txt'];
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
  static const _scriptPriority = [
    'md',
    'markdown',
    'pdf',
    'rtf',
    'docx',
    'doc',
  ];

  final String _importDir;
  final MediaExtractionBridge _mediaExtractionBridge;

  ImportService({
    required String importDirectory,
    MediaExtractionBridge? mediaExtractionBridge,
  }) : _importDir = importDirectory,
       _mediaExtractionBridge =
           mediaExtractionBridge ?? MediaExtractionBridge();

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
    final extracted = await _extractZip(zipPath, password: password);

    return _buildPreview(
      extracted.paths,
      sourceType: ImportSourceType.zip,
      archivePath: zipPath,
      extractedDir: extracted.directory,
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
  }) async {
    final paths = preview.selectedPaths;
    if (paths.isEmpty) {
      throw Exception('请先选择需要导入的文件');
    }

    if (!preview.hasSelectedMedia) {
      throw Exception('请至少选择一个音频或视频文件');
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

    for (var i = 0; i < mediaFiles.length; i++) {
      final mediaPath = mediaFiles[i];
      onProgress?.call(i + 1, mediaFiles.length);

      try {
        final rawTitle = _baseName(mediaPath);
        final title = _deduplicateTitle(rawTitle, usedTitles);
        usedTitles.add(title);

        final destPath = await _importMediaFile(mediaPath, rawTitle);
        const mediaType = 'audio';

        final matchedSubtitle = _takeBestMatch(
          rawTitle,
          remainingSubtitles,
          _subtitlePriority,
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
        }
        if (matchedScript != null) {
          scriptDest = await _copyToImportDir(matchedScript);
        }
        if (matchedSignal != null) {
          signalDest = await _copyToImportDir(matchedSignal);
        }

        succeeded.add(
          ImportedItem(
            title: title,
            filePath: destPath,
            coverPath: coverDest,
            subtitlePath: subtitleDest,
            scriptPath: scriptDest,
            signalPath: signalDest,
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
    return p.basenameWithoutExtension(path);
  }

  Future<String> _importMediaFile(String mediaPath, String rawTitle) async {
    final ext = p.extension(mediaPath).toLowerCase().replaceFirst('.', '');
    if (ResonanceMediaSupport.videoExtensions.contains(ext)) {
      final outputPath = await _reserveImportPath('$rawTitle.m4a');
      final extractedPath = await _mediaExtractionBridge.extractAudio(
        inputPath: mediaPath,
        outputPath: outputPath,
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
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes, password: password);

    final extractDir = await Directory.systemTemp.createTemp(
      'omao_zip_${p.basenameWithoutExtension(zipPath)}_',
    );

    final extractedPaths = <String>[];

    for (final file in archive) {
      if (file.isFile) {
        final outPath = p.join(extractDir.path, file.name);
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
        extractedPaths.add(outPath);
      }
    }

    return (directory: extractDir.path, paths: extractedPaths);
  }

  ImportPreview _buildPreview(
    List<String> paths, {
    required ImportSourceType sourceType,
    String? archivePath,
    String? extractedDir,
  }) {
    final items = paths
        .map((path) {
          final type = _classifyFile(path);
          final selectable = type != ImportPreviewItemType.unsupported;
          final name =
              extractedDir == null
                  ? p.basename(path)
                  : p.relative(path, from: extractedDir);

          return ImportPreviewItem(
            path: path,
            name: name,
            type: type,
            selected: selectable,
            selectable: selectable,
          );
        })
        .toList(growable: false);

    return ImportPreview(
      sourceType: sourceType,
      items: items,
      archivePath: archivePath,
      extractedDir: extractedDir,
    );
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

  bool _isSingleDirectorySelection(List<String> paths) {
    final parentDirectories =
        paths.map((path) => p.normalize(p.dirname(path))).toSet();
    return parentDirectories.length <= 1;
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

  Set<String> get subtitleExtensions => _subtitleExtensions;

  Set<String> get coverExtensions => _coverExtensions;

  Set<String> get scriptExtensions => _scriptExtensions;

  Set<String> get signalExtensions => _signalExtensions;
}
