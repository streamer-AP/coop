import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/logging/app_logger.dart';
import '../../domain/models/import_result.dart';

/// Callback for reporting import progress: (current, total).
typedef ImportProgressCallback = void Function(int current, int total);

/// File import service: handles file selection, zip extraction,
/// and automatic matching of audio with subtitle/cover/signal files.
class ImportService {
  static const _audioExtensions = {
    'mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg', 'wma',
  };
  static const _videoExtensions = {
    'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm',
  };
  static const _subtitleExtensions = {
    'srt', 'vtt', 'lrc', 'sub', 'stl', 'txt',
  };
  static const _coverExtensions = {
    'jpg', 'jpeg', 'png', 'tiff', 'tif', 'bmp', 'webp',
    'gif', 'heif', 'heic', 'hdr',
  };
  static const _signalExtensions = {'json'};

  static const _subtitlePriority = ['srt', 'vtt', 'sub', 'stl', 'lrc', 'txt'];
  static const _coverPriority = [
    'jpeg', 'jpg', 'png', 'tiff', 'tif', 'gif', 'webp',
    'bmp', 'heif', 'heic', 'hdr',
  ];

  final String _importDir;

  ImportService({required String importDirectory}) : _importDir = importDirectory;

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

  /// Import files from a list of paths.
  /// For zip files, extracts and processes contents.
  Future<ImportResult> importFiles(
    List<String> paths, {
    String? zipPassword,
    ImportProgressCallback? onProgress,
    List<String>? existingTitles,
  }) async {
    final succeeded = <ImportedItem>[];
    final failed = <ImportFailure>[];

    // Separate zips from regular files
    final zips = <String>[];
    final regularFiles = <String>[];

    for (final path in paths) {
      if (p.extension(path).toLowerCase() == '.zip') {
        zips.add(path);
      } else {
        regularFiles.add(path);
      }
    }

    // Extract zip files first
    for (final zipPath in zips) {
      try {
        final extracted = await _extractZip(zipPath, password: zipPassword);
        regularFiles.addAll(extracted);
      } catch (e) {
        failed.add(ImportFailure(
          fileName: p.basename(zipPath),
          reason: '解压失败: $e',
        ));
      }
    }

    // Categorize all files
    final audioFiles = <String>[];
    final subtitleFiles = <String>[];
    final coverFiles = <String>[];
    final signalFiles = <String>[];

    for (final filePath in regularFiles) {
      final ext = p.extension(filePath).toLowerCase().replaceFirst('.', '');
      if (_audioExtensions.contains(ext) || _videoExtensions.contains(ext)) {
        audioFiles.add(filePath);
      } else if (_subtitleExtensions.contains(ext)) {
        subtitleFiles.add(filePath);
      } else if (_coverExtensions.contains(ext)) {
        coverFiles.add(filePath);
      } else if (_signalExtensions.contains(ext)) {
        signalFiles.add(filePath);
      }
    }

    // Track used titles for deduplication
    final usedTitles = <String>{...?existingTitles};

    // Auto-match for each audio file
    for (var i = 0; i < audioFiles.length; i++) {
      final audioPath = audioFiles[i];
      onProgress?.call(i + 1, audioFiles.length);

      try {
        final destPath = await _copyToImportDir(audioPath);
        final rawTitle = _baseName(audioPath);
        final title = _deduplicateTitle(rawTitle, usedTitles);
        usedTitles.add(title);

        // Determine media type
        final ext = p.extension(audioPath).toLowerCase().replaceFirst('.', '');
        final mediaType = _videoExtensions.contains(ext) ? 'video' : 'audio';

        final matchedSubtitle = _findBestMatch(
          rawTitle,
          subtitleFiles,
          _subtitlePriority,
        );
        final matchedCover = _findBestMatch(
          rawTitle,
          coverFiles,
          _coverPriority,
        );
        final matchedSignal = _findBestMatch(
          rawTitle,
          signalFiles,
          null,
        );

        String? subtitleDest;
        String? coverDest;
        String? signalDest;

        if (matchedSubtitle != null) {
          subtitleDest = await _copyToImportDir(matchedSubtitle);
        }
        if (matchedCover != null) {
          coverDest = await _copyToImportDir(matchedCover);
        }
        if (matchedSignal != null) {
          signalDest = await _copyToImportDir(matchedSignal);
        }

        succeeded.add(ImportedItem(
          title: title,
          filePath: destPath,
          coverPath: coverDest,
          subtitlePath: subtitleDest,
          signalPath: signalDest,
          mediaType: mediaType,
        ));
      } catch (e) {
        failed.add(ImportFailure(
          fileName: p.basename(audioPath),
          reason: '$e',
        ));
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

  /// Auto-matching algorithm:
  /// Priority 1: exact basename match (ignoring extension)
  /// Priority 2: resource filename starts with audio basename
  /// Priority 3: first dot-segment matches
  String? _findBestMatch(
    String audioBaseName,
    List<String> candidates,
    List<String>? extensionPriority,
  ) {
    if (candidates.isEmpty) return null;

    // Priority 1: exact basename match
    final exact = _filterAndSort(
      candidates.where((c) => _baseName(c) == audioBaseName).toList(),
      extensionPriority,
    );
    if (exact.isNotEmpty) return exact.first;

    // Priority 2: starts with audio basename
    final startsWith = _filterAndSort(
      candidates.where((c) => _baseName(c).startsWith(audioBaseName)).toList(),
      extensionPriority,
    );
    if (startsWith.isNotEmpty) return startsWith.first;

    // Priority 3: first dot-segment matches
    final audioFirstPart = audioBaseName.split('.').first;
    final firstPart = _filterAndSort(
      candidates
          .where((c) => _baseName(c).split('.').first == audioFirstPart)
          .toList(),
      extensionPriority,
    );
    if (firstPart.isNotEmpty) return firstPart.first;

    return null;
  }

  List<String> _filterAndSort(
    List<String> files,
    List<String>? extensionPriority,
  ) {
    if (extensionPriority == null || files.length <= 1) return files;
    files.sort((a, b) {
      final extA = p.extension(a).toLowerCase().replaceFirst('.', '');
      final extB = p.extension(b).toLowerCase().replaceFirst('.', '');
      final indexA = extensionPriority.indexOf(extA);
      final indexB = extensionPriority.indexOf(extB);
      return (indexA == -1 ? 999 : indexA).compareTo(
        indexB == -1 ? 999 : indexB,
      );
    });
    return files;
  }

  String _baseName(String path) {
    return p.basenameWithoutExtension(path);
  }

  Future<String> _copyToImportDir(String sourcePath) async {
    final fileName = p.basename(sourcePath);
    var destPath = p.join(_importDir, fileName);
    final destFile = File(destPath);

    if (!await destFile.parent.exists()) {
      await destFile.parent.create(recursive: true);
    }

    // Handle file name conflicts
    if (await File(destPath).exists()) {
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
    }

    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<List<String>> _extractZip(
    String zipPath, {
    String? password,
  }) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(
      bytes,
      password: password,
    );

    final extractDir = p.join(
      _importDir,
      '_extracted_${p.basenameWithoutExtension(zipPath)}',
    );
    await Directory(extractDir).create(recursive: true);

    final extractedPaths = <String>[];

    for (final file in archive) {
      if (file.isFile) {
        final outPath = p.join(extractDir, file.name);
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
        extractedPaths.add(outPath);
      }
    }

    return extractedPaths;
  }

  /// Clean up extracted zip temp directories.
  Future<void> cleanupExtractedDirs() async {
    final dir = Directory(_importDir);
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      if (entity is Directory && p.basename(entity.path).startsWith('_extracted_')) {
        await entity.delete(recursive: true);
      }
    }
  }
}
