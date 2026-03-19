import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/storage/file_manager.dart';
import '../../application/providers/import_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/models/subtitle.dart';
import '../../domain/repositories/resonance_repository.dart';
import 'import_instruction_sheet.dart';

class SubtitleCoverImportSheet extends ConsumerWidget {
  const SubtitleCoverImportSheet({super.key, required this.entry});

  final AudioEntry entry;

  static Future<void> show(BuildContext context, {required AudioEntry entry}) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SubtitleCoverImportSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '导入资源',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF79747E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ImportInstructionSheet.show(context),
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF79747E),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _ImportOption(
              icon: Icons.subtitles_outlined,
              label: '字幕',
              onTap: () {
                Navigator.of(context).pop();
                _pickAndImport(context, ref, _ManualImportType.subtitle);
              },
            ),
            _ImportOption(
              icon: Icons.article_outlined,
              label: '台本',
              onTap: () {
                Navigator.of(context).pop();
                _pickAndImport(context, ref, _ManualImportType.script);
              },
            ),
            _ImportOption(
              icon: Icons.image_outlined,
              label: '封面',
              onTap: () {
                Navigator.of(context).pop();
                _pickAndImport(context, ref, _ManualImportType.cover);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImport(
    BuildContext context,
    WidgetRef ref,
    _ManualImportType type,
  ) async {
    final importService = await ref.read(importServiceProvider.future);
    final allowedExtensions = switch (type) {
      _ManualImportType.subtitle => importService.subtitleExtensions.toList(),
      _ManualImportType.script => importService.scriptExtensions.toList(),
      _ManualImportType.cover => importService.coverExtensions.toList(),
    };

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result == null || result.files.isEmpty) return;

    final pickedPath = result.files.first.path;
    if (pickedPath == null) return;

    try {
      final fileManager = FileManager();
      final importDir = await fileManager.getImportDirectory();
      final destPath = await _copyIntoImportDirectory(importDir, pickedPath);
      final repo = ref.read(resonanceRepositoryProvider);

      switch (type) {
        case _ManualImportType.subtitle:
          await _replaceSubtitles(repo, destPath);
        case _ManualImportType.script:
          await _replaceScript(repo, destPath);
        case _ManualImportType.cover:
          await _replaceCover(repo, destPath);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${type.label}导入成功')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导入失败: $e')));
      }
    }
  }

  Future<void> _replaceSubtitles(
    ResonanceRepository repo,
    String destPath,
  ) async {
    final existingSubs = await repo.getSubtitlesForEntry(entry.id);
    for (final sub in existingSubs) {
      await _deleteFileIfExists(sub.filePath);
    }
    await repo.deleteSubtitlesForEntry(entry.id);

    final ext = p.extension(destPath).toLowerCase().replaceFirst('.', '');
    final format =
        SubtitleFormat.values.where((f) => f.name == ext).firstOrNull ??
        SubtitleFormat.srt;

    await repo.insertSubtitle(
      SubtitleRef(
        id: 0,
        entryId: entry.id,
        language: 'default',
        filePath: destPath,
        format: format,
      ),
    );
  }

  Future<void> _replaceScript(ResonanceRepository repo, String destPath) async {
    final existingScriptPath = await repo.getScriptFilePathForEntry(entry.id);
    if (existingScriptPath != null) {
      await _deleteFileIfExists(existingScriptPath);
    }
    await repo.deleteScriptFilesForEntry(entry.id);
    await repo.insertScriptFile(entry.id, destPath);
  }

  Future<void> _replaceCover(ResonanceRepository repo, String destPath) async {
    if (entry.coverPath != null) {
      await _deleteFileIfExists(entry.coverPath!);
    }
    await repo.updateEntry(entry.copyWith(coverPath: destPath));
  }

  Future<String> _copyIntoImportDirectory(
    String importDir,
    String sourcePath,
  ) async {
    final fileName = p.basename(sourcePath);
    var destPath = p.join(importDir, fileName);
    var counter = 1;
    while (await File(destPath).exists()) {
      final baseName = p.basenameWithoutExtension(fileName);
      final ext = p.extension(fileName);
      destPath = p.join(importDir, '$baseName($counter)$ext');
      counter++;
    }
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

enum _ManualImportType {
  subtitle('字幕'),
  script('台本'),
  cover('封面');

  const _ManualImportType(this.label);

  final String label;
}

class _ImportOption extends StatelessWidget {
  const _ImportOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF49454F), size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
