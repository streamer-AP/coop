import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/omao_toast.dart';
import '../../../../core/theme/app_icons.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../../application/services/export_service.dart';
import '../../application/services/playlist_service.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/repositories/resonance_repository.dart';
import 'collection_picker_dialog.dart';
import 'subtitle_cover_import_sheet.dart';

class AudioEntryActionSheet extends ConsumerWidget {
  const AudioEntryActionSheet({
    super.key,
    required this.entry,
    this.collectionId,
  });

  final AudioEntry entry;
  final int? collectionId;

  static Future<void> show(
    BuildContext context, {
    required AudioEntry entry,
    int? collectionId,
  }) {
    return showModalBottomSheet(
      context: context,
      builder:
          (_) =>
              AudioEntryActionSheet(entry: entry, collectionId: collectionId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInCollection = collectionId != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    isInCollection ? '歌单：' : '歌曲：',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF79747E),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF49454F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _ActionItem(
              svgPath: AppIcons.exportIcon,
              label: '导出',
              onTap: () {
                Navigator.of(context).pop();
                _showExportDialog(context, ref);
              },
            ),
            _ActionItem(
              svgPath: AppIcons.importIcon,
              label: '导入字幕/封面/台本',
              onTap: () {
                Navigator.of(context).pop();
                SubtitleCoverImportSheet.show(context, entry: entry);
              },
            ),
            _ActionItem(
              svgPath: AppIcons.rename,
              label: '重命名',
              onTap: () {
                final repo = ref.read(resonanceRepositoryProvider);
                final navigator = Navigator.of(context);
                final parentContext = navigator.context;
                navigator.pop();
                _showRenameDialog(parentContext, repo);
              },
            ),
            _ActionItem(
              svgPath: AppIcons.box,
              label: '添加到合集',
              onTap: () {
                Navigator.of(context).pop();
                _showAddToCollection(context);
              },
            ),
            _ActionItem(
              svgPath: AppIcons.add3,
              label: '添加到当前播放列表',
              onTap: () {
                Navigator.of(context).pop();
                _addToPlaylist(ref);
              },
            ),
            if (!isInCollection)
              _ActionItem(
                svgPath: AppIcons.delete,
                label: '删除音频',
                onTap: () {
                  final repo = ref.read(resonanceRepositoryProvider);
                  final playlistSvc = ref.read(playlistServiceProvider);
                  final playerNotifier = ref.read(
                    playerStateNotifierProvider.notifier,
                  );
                  Navigator.of(context).pop();
                  _showDeleteDialog(
                    context,
                    repo: repo,
                    playlistSvc: playlistSvc,
                    playerNotifier: playerNotifier,
                  );
                },
              ),
            if (isInCollection)
              _ActionItem(
                svgPath: AppIcons.delete,
                label: '移除音频',
                onTap: () {
                  final repo = ref.read(resonanceRepositoryProvider);
                  Navigator.of(context).pop();
                  _showRemoveFromCollectionDialog(context, repo: repo);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  '是否导出 ZIP 到本地\n字幕、封面、台本会一并打包',
                  style: TextStyle(fontSize: 14, color: Color(0xFF79747E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(color: Color(0xFF49454F)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _doExport(context, ref);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('确定'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _doExport(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(resonanceRepositoryProvider);
      final exportService = ExportService(repo);
      final exportPath = await exportService.exportEntry(entry);
      if (exportPath != null && context.mounted) {
        OmaoToast.show(context, '导出成功');
      }
    } catch (e) {
      if (context.mounted) {
        OmaoToast.show(context, '导出失败: $e', isSuccess: false);
      }
    }
  }

  void _showRenameDialog(BuildContext context, ResonanceRepository repo) {
    final controller = TextEditingController(text: entry.title);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('重命名'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '请输入新名称'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  var newTitle = controller.text.trim();
                  if (newTitle.isEmpty || newTitle == entry.title) {
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    return;
                  }
                  // 重名自动追加尾缀 1, 2, 3...
                  final existingTitles = await repo.getAllEntryTitles();
                  final otherTitles =
                      existingTitles.where((t) => t != entry.title).toSet();
                  if (otherTitles.contains(newTitle)) {
                    final base = newTitle;
                    var suffix = 1;
                    while (otherTitles.contains('$base$suffix')) {
                      suffix++;
                    }
                    newTitle = '$base$suffix';
                  }
                  await repo.updateEntry(entry.copyWith(title: newTitle));
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  void _showAddToCollection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => CollectionPickerDialog(
                  entryIds: [entry.id],
                  scrollController: scrollController,
                ),
          ),
    );
  }

  void _addToPlaylist(WidgetRef ref) {
    ref.read(playerStateNotifierProvider.notifier).addToCurrentPlaylist(entry);
  }

  void _showDeleteDialog(
    BuildContext context, {
    required ResonanceRepository repo,
    required PlaylistService playlistSvc,
    required PlayerStateNotifier playerNotifier,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('删除音频'),
            content: const Text('确定要删除该音频吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Remove from current playlist if present
                    final playlist = playlistSvc.currentPlaylist;
                    final playlistItem =
                        playlist.items
                            .where((item) => item.entry.id == entry.id)
                            .firstOrNull;
                    if (playlistItem != null) {
                      await playerNotifier.removeFromPlaylist(playlistItem.uid);
                    }
                    // Delete entry and all associated data + files
                    await repo.deleteEntryCompletely(entry.id);
                  } catch (e) {
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      OmaoToast.show(ctx, '删除失败: $e', isSuccess: false);
                    }
                    return;
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showRemoveFromCollectionDialog(
    BuildContext context, {
    required ResonanceRepository repo,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('移除音频'),
            content: const Text('确定要从合集中移除该音频吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  await repo.removeEntryFromCollection(entry.id, collectionId!);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('移除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({this.svgPath, required this.label, required this.onTap});

  final String? svgPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          svgPath != null
              ? AppIcons.icon(
                svgPath!,
                size: 24,
                color: const Color(0xFF49454F),
              )
              : null,
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Color(0xFF1C1B1F)),
      ),
      onTap: onTap,
    );
  }
}
