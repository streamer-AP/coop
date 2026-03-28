import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/logging/app_logger.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/repositories/resonance_repository.dart';

class ExportService {
  final ResonanceRepository _repository;

  ExportService(this._repository);

  /// 导出条目为 ZIP 压缩包并保存到用户选择的路径。
  Future<String?> exportEntry(AudioEntry entry) async {
    final mediaFile = File(entry.filePath);
    if (!await mediaFile.exists()) {
      throw Exception('媒体文件不存在');
    }

    final subtitles = await _repository.getSubtitlesForEntry(entry.id);
    final scriptPath = await _repository.getScriptFilePathForEntry(entry.id);

    final filesToPack = <String, File>{};
    filesToPack[p.basename(entry.filePath)] = mediaFile;

    if (entry.coverPath != null) {
      final coverFile = File(entry.coverPath!);
      if (await coverFile.exists()) {
        filesToPack[p.basename(entry.coverPath!)] = coverFile;
      }
    }

    for (final sub in subtitles) {
      final subFile = File(sub.filePath);
      if (await subFile.exists()) {
        filesToPack[p.basename(sub.filePath)] = subFile;
      }
    }

    if (scriptPath != null) {
      final scriptFile = File(scriptPath);
      if (await scriptFile.exists()) {
        filesToPack[p.basename(scriptPath)] = scriptFile;
      }
    }

    final defaultName = _buildDefaultZipName(entry.filePath);
    final tempZipPath = await _newTempZipPath(defaultName);
    final encoder = ZipFileEncoder()..create(tempZipPath);
    try {
      for (final mapEntry in filesToPack.entries) {
        encoder.addFile(mapEntry.value, mapEntry.key);
      }
    } finally {
      encoder.close();
    }

    final tempZip = File(tempZipPath);
    if (!await tempZip.exists() || await tempZip.length() == 0) {
      throw Exception('压缩导出文件失败');
    }

    final resolvedPath = await _saveZipFile(
      tempZip,
      dialogTitle: '导出条目',
      fileName: defaultName,
    );
    await _safeDeleteTempFile(tempZipPath);
    if (resolvedPath == null) return null;

    AppLogger().info(
      'Exported ${entry.title} as ZIP with ${filesToPack.length} files to $resolvedPath',
    );

    return resolvedPath;
  }

  /// 一键导出所有音频条目为单个 ZIP（每个条目一个子目录）。
  /// [onProgress] 回调参数: (已处理数, 总数)。
  Future<String?> exportAll({
    void Function(int current, int total)? onProgress,
  }) async {
    final entries = await _repository.getAllEntries();
    if (entries.isEmpty) {
      throw Exception('没有可导出的音频');
    }

    final tempZipPath = await _newTempZipPath('omao_export.zip');
    final encoder = ZipFileEncoder()..create(tempZipPath);
    try {
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        onProgress?.call(i, entries.length);

        final dirName = p.basenameWithoutExtension(entry.filePath);
        final mediaFile = File(entry.filePath);
        if (!await mediaFile.exists()) continue;

        encoder.addFile(mediaFile, '$dirName/${p.basename(entry.filePath)}');

        if (entry.coverPath != null) {
          final coverFile = File(entry.coverPath!);
          if (await coverFile.exists()) {
            encoder.addFile(
              coverFile,
              '$dirName/${p.basename(entry.coverPath!)}',
            );
          }
        }

        final subtitles = await _repository.getSubtitlesForEntry(entry.id);
        for (final sub in subtitles) {
          final subFile = File(sub.filePath);
          if (await subFile.exists()) {
            encoder.addFile(subFile, '$dirName/${p.basename(sub.filePath)}');
          }
        }

        final scriptPath = await _repository.getScriptFilePathForEntry(entry.id);
        if (scriptPath != null) {
          final scriptFile = File(scriptPath);
          if (await scriptFile.exists()) {
            encoder.addFile(scriptFile, '$dirName/${p.basename(scriptPath)}');
          }
        }
      }
    } finally {
      encoder.close();
    }

    onProgress?.call(entries.length, entries.length);

    final tempZip = File(tempZipPath);
    if (!await tempZip.exists() || await tempZip.length() == 0) {
      throw Exception('压缩导出文件失败');
    }

    final resolvedPath = await _saveZipFile(
      tempZip,
      dialogTitle: '导出全部音声',
      fileName: 'omao_export.zip',
    );
    await _safeDeleteTempFile(tempZipPath);
    if (resolvedPath == null) return null;

    AppLogger().info(
      'Exported all ${entries.length} entries to $resolvedPath',
    );

    return resolvedPath;
  }

  String _buildDefaultZipName(String mediaPath) {
    final baseName = p.basenameWithoutExtension(mediaPath);
    return '$baseName.zip';
  }

  Future<String?> _saveZipFile(
    File sourceZip, {
    required String dialogTitle,
    required String fileName,
  }) async {
    final normalizedName =
        fileName.toLowerCase().endsWith('.zip') ? fileName : '$fileName.zip';

    if (Platform.isAndroid) {
      final directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle,
      );
      if (directoryPath == null || directoryPath.isEmpty) {
        return null;
      }
      final targetPath = await _resolveCollision(
        p.join(directoryPath, normalizedName),
      );
      await sourceZip.copy(targetPath);
      return targetPath;
    }

    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: normalizedName,
      type: FileType.any,
    );
    if (selectedPath == null || selectedPath.isEmpty) {
      return null;
    }
    final normalizedPath =
        selectedPath.toLowerCase().endsWith('.zip')
            ? selectedPath
            : '$selectedPath.zip';
    final targetPath = await _resolveCollision(normalizedPath);
    await sourceZip.copy(targetPath);
    return targetPath;
  }

  Future<String> _newTempZipPath(String fileName) async {
    final baseName = fileName.toLowerCase().endsWith('.zip')
        ? p.basenameWithoutExtension(fileName)
        : fileName;
    final ts = DateTime.now().millisecondsSinceEpoch;
    return p.join(Directory.systemTemp.path, 'omao_${ts}_$baseName.zip');
  }

  Future<String> _resolveCollision(String originalPath) async {
    if (!await File(originalPath).exists()) {
      return originalPath;
    }

    final directory = p.dirname(originalPath);
    final baseName = p.basenameWithoutExtension(originalPath);
    final extension = p.extension(originalPath);
    var counter = 1;
    var candidate = p.join(directory, '$baseName$counter$extension');
    while (await File(candidate).exists()) {
      counter++;
      candidate = p.join(directory, '$baseName$counter$extension');
    }
    return candidate;
  }

  Future<void> _safeDeleteTempFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // ignore temp cleanup failure
    }
  }
}
