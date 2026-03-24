import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/storage/file_manager.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/import_providers.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../../application/providers/subtitle_providers.dart';
import '../../application/services/import_service.dart';
import '../../application/services/media_support.dart';
import '../../application/services/subtitle_service.dart';
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
                    child: AppIcons.icon(
                      AppIcons.search01,
                      size: 22,
                      color: const Color(0xFF79747E),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _ImportOption(
              svgPath: AppIcons.subtitle,
              label: '字幕',
              onTap: () => _onTap(context, ref, _ManualImportType.subtitle),
            ),
            _ImportOption(
              svgPath: AppIcons.translate,
              label: '台本',
              onTap: () => _onTap(context, ref, _ManualImportType.script),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, _ManualImportType type) {
    // 在 pop 之前把所有需要的 provider 值读出来，避免 dispose 后使用 ref
    final feedbackOverlay = Navigator.of(context, rootNavigator: true).overlay;
    final feedbackTopPadding = MediaQuery.paddingOf(context).top;
    final importServiceFuture = ref.read(importServiceProvider.future);
    final fileManager = ref.read(fileManagerProvider);
    final repo = ref.read(resonanceRepositoryProvider);
    final playerNotifier = ref.read(playerStateNotifierProvider.notifier);
    final subtitleService = ref.read(subtitleServiceProvider);
    final resourceRefreshTick = ref.read(
      entryResourceRefreshTickProvider(entry.id).notifier,
    );
    final playerState = ref.read(playerStateNotifierProvider);
    final resumePlaybackAfterPicker =
        playerState.currentEntry != null && playerState.isPlaying;

    Navigator.of(context).pop();

    _pickAndImport(
      type: type,
      feedbackOverlay: feedbackOverlay,
      feedbackTopPadding: feedbackTopPadding,
      importServiceFuture: importServiceFuture,
      fileManager: fileManager,
      repo: repo,
      playerNotifier: playerNotifier,
      subtitleService: subtitleService,
      resourceRefreshTick: resourceRefreshTick,
      resumePlaybackAfterPicker: resumePlaybackAfterPicker,
    );
  }

  Future<void> _pickAndImport({
    required _ManualImportType type,
    required OverlayState? feedbackOverlay,
    required double feedbackTopPadding,
    required Future<ImportService> importServiceFuture,
    required FileManager fileManager,
    required ResonanceRepository repo,
    required PlayerStateNotifier playerNotifier,
    required SubtitleService subtitleService,
    required StateController<int> resourceRefreshTick,
    required bool resumePlaybackAfterPicker,
  }) async {
    final importService = await importServiceFuture;
    final allowedExtensions = switch (type) {
      _ManualImportType.subtitle => importService.subtitleExtensions.toList(),
      _ManualImportType.script => importService.scriptExtensions.toList(),
    };

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
      withReadStream: true,
    );
    if (result == null || result.files.isEmpty) {
      await _resumePlaybackIfNeeded(
        playerNotifier,
        shouldResume: resumePlaybackAfterPicker,
      );
      return;
    }

    try {
      final importDir = fileManager.getImportDirectory();
      final pickedFile = result.files.first;
      final destPath = await _copyIntoImportDirectory(importDir, pickedFile);

      switch (type) {
        case _ManualImportType.subtitle:
          await _replaceSubtitles(repo, destPath, subtitleService);
          resourceRefreshTick.state++;
          break;
        case _ManualImportType.script:
          await _replaceScript(repo, destPath);
          resourceRefreshTick.state++;
          break;
      }

      _showMessage(
        feedbackOverlay,
        feedbackTopPadding,
        '${type.label}导入成功',
        isError: false,
      );
    } catch (e) {
      _showMessage(feedbackOverlay, feedbackTopPadding, '导入失败: $e');
    } finally {
      await _resumePlaybackIfNeeded(
        playerNotifier,
        shouldResume: resumePlaybackAfterPicker,
      );
    }
  }

  Future<void> _replaceSubtitles(
    ResonanceRepository repo,
    String destPath,
    SubtitleService subtitleService,
  ) async {
    await _validateSubtitleFile(destPath, subtitleService);

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

  Future<void> _validateSubtitleFile(
    String path,
    SubtitleService subtitleService,
  ) async {
    final content = await subtitleService.readTextFile(path);
    if (content.trim().isEmpty) {
      throw Exception('字幕文件为空');
    }

    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    final format =
        SubtitleFormat.values.where((f) => f.name == ext).firstOrNull;
    if (format == null) {
      throw Exception('不支持的字幕格式: .$ext');
    }

    try {
      final parsed = subtitleService.parse(
        SubtitleRef(
          id: 0,
          entryId: entry.id,
          language: 'default',
          filePath: path,
          format: format,
        ),
        content,
      );
      if (parsed.cues.isEmpty) {
        throw Exception('字幕内容为空或格式不受支持');
      }
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('字幕解析失败，请检查字幕格式或编码');
    }
  }

  Future<void> _replaceScript(ResonanceRepository repo, String destPath) async {
    final existingScriptPath = await repo.getScriptFilePathForEntry(entry.id);
    if (existingScriptPath != null) {
      await _deleteFileIfExists(existingScriptPath);
    }
    await repo.deleteScriptFilesForEntry(entry.id);
    await repo.insertScriptFile(entry.id, destPath);
  }

  Future<String> _copyIntoImportDirectory(
    String importDir,
    PlatformFile file,
  ) async {
    final fileName = file.name.trim();
    if (fileName.isEmpty) {
      throw Exception('所选文件缺少文件名');
    }

    var destPath = p.join(importDir, fileName);
    var counter = 1;
    while (await File(destPath).exists()) {
      final baseName = p.basenameWithoutExtension(fileName);
      final ext = p.extension(fileName);
      destPath = p.join(importDir, '$baseName($counter)$ext');
      counter++;
    }

    await ResonanceMediaSupport.runWithPendingFsRetry(() async {
      final destFile = File(destPath);
      if (await destFile.exists()) {
        await destFile.delete();
      }

      final readStream = file.readStream;
      if (readStream != null) {
        final sink = destFile.openWrite();
        try {
          await sink.addStream(readStream);
        } finally {
          await sink.close();
        }
        return;
      }

      final bytes = file.bytes;
      if (bytes != null) {
        await destFile.writeAsBytes(bytes, flush: true);
        return;
      }

      final sourcePath = file.path?.trim();
      if (sourcePath == null || sourcePath.isEmpty) {
        throw Exception('系统未返回可读取的文件内容，请换用“文件”来源后重试');
      }

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('所选文件无法读取: ${file.name}');
      }

      final sink = destFile.openWrite();
      try {
        await sink.addStream(sourceFile.openRead());
      } finally {
        await sink.close();
      }
    });

    return destPath;
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _resumePlaybackIfNeeded(
    PlayerStateNotifier playerNotifier, {
    required bool shouldResume,
  }) async {
    if (!shouldResume) return;
    try {
      await playerNotifier.play();
    } catch (_) {}
  }

  void _showMessage(
    OverlayState? overlay,
    double topPadding,
    String text, {
    bool isError = true,
  }) {
    if (overlay == null || !overlay.mounted) return;
    TopBannerToast.showOnOverlay(
      overlay,
      message: text,
      isError: isError,
      topPadding: topPadding,
    );
  }
}

enum _ManualImportType {
  subtitle('字幕'),
  script('台本');

  const _ManualImportType(this.label);

  final String label;
}

class _ImportOption extends StatelessWidget {
  const _ImportOption({
    required this.svgPath,
    required this.label,
    required this.onTap,
  });

  final String svgPath;
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
                AppIcons.icon(
                  svgPath,
                  size: 24,
                  color: const Color(0xFF49454F),
                ),
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
