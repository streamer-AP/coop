import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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

    final archive = Archive();
    for (final mapEntry in filesToPack.entries) {
      final bytes = await mapEntry.value.readAsBytes();
      archive.addFile(ArchiveFile(mapEntry.key, bytes.length, bytes));
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes.isEmpty) {
      throw Exception('压缩导出文件失败');
    }

    final defaultName = _buildDefaultZipName(entry.filePath);
    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: '导出条目',
      fileName: defaultName,
      type: FileType.any,
      bytes: Uint8List.fromList(zipBytes),
    );

    if (selectedPath == null || selectedPath.isEmpty) {
      return null;
    }

    final resolvedPath = await _persistZipIfNeeded(
      selectedPath,
      Uint8List.fromList(zipBytes),
    );

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

    final archive = Archive();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      onProgress?.call(i, entries.length);

      final dirName = p.basenameWithoutExtension(entry.filePath);
      final mediaFile = File(entry.filePath);
      if (!await mediaFile.exists()) continue;

      archive.addFile(ArchiveFile(
        '$dirName/${p.basename(entry.filePath)}',
        (await mediaFile.length()),
        await mediaFile.readAsBytes(),
      ));

      if (entry.coverPath != null) {
        final coverFile = File(entry.coverPath!);
        if (await coverFile.exists()) {
          archive.addFile(ArchiveFile(
            '$dirName/${p.basename(entry.coverPath!)}',
            (await coverFile.length()),
            await coverFile.readAsBytes(),
          ));
        }
      }

      final subtitles = await _repository.getSubtitlesForEntry(entry.id);
      for (final sub in subtitles) {
        final subFile = File(sub.filePath);
        if (await subFile.exists()) {
          archive.addFile(ArchiveFile(
            '$dirName/${p.basename(sub.filePath)}',
            (await subFile.length()),
            await subFile.readAsBytes(),
          ));
        }
      }

      final scriptPath =
          await _repository.getScriptFilePathForEntry(entry.id);
      if (scriptPath != null) {
        final scriptFile = File(scriptPath);
        if (await scriptFile.exists()) {
          archive.addFile(ArchiveFile(
            '$dirName/${p.basename(scriptPath)}',
            (await scriptFile.length()),
            await scriptFile.readAsBytes(),
          ));
        }
      }
    }

    onProgress?.call(entries.length, entries.length);

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes.isEmpty) {
      throw Exception('压缩导出文件失败');
    }

    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: '导出全部音声',
      fileName: 'omao_export.zip',
      type: FileType.any,
      bytes: Uint8List.fromList(zipBytes),
    );

    if (selectedPath == null || selectedPath.isEmpty) {
      return null;
    }

    final resolvedPath = await _persistZipIfNeeded(
      selectedPath,
      Uint8List.fromList(zipBytes),
    );

    AppLogger().info(
      'Exported all ${entries.length} entries to $resolvedPath',
    );

    return resolvedPath;
  }

  String _buildDefaultZipName(String mediaPath) {
    final baseName = p.basenameWithoutExtension(mediaPath);
    return '$baseName.zip';
  }

  Future<String> _persistZipIfNeeded(
    String selectedPath,
    Uint8List bytes,
  ) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return selectedPath;
    }

    final normalizedPath =
        selectedPath.toLowerCase().endsWith('.zip')
            ? selectedPath
            : '$selectedPath.zip';
    final targetPath = await _resolveCollision(normalizedPath);
    final targetFile = File(targetPath);
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsBytes(bytes);
    return targetPath;
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
}
