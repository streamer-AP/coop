import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/storage/file_manager.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/services/collection_service.dart';
import '../../domain/models/audio_collection.dart';
import 'create_collection_dialog.dart';
import '../../../../shared/widgets/top_banner_toast.dart';

class CollectionActionSheet extends ConsumerWidget {
  const CollectionActionSheet({super.key, required this.collection});

  final AudioCollection collection;

  static Future<void> show(
    BuildContext context, {
    required AudioCollection collection,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => CollectionActionSheet(collection: collection),
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
            const SizedBox(height: 8),
            ListTile(
              leading: AppIcons.icon(
                AppIcons.rename,
                size: 24,
                color: const Color(0xFF49454F),
              ),
              title: const Text('重命名'),
              onTap: () {
                final service = ref.read(collectionServiceProvider);
                Navigator.of(context).pop();
                _showRenameDialog(context, ref: ref, service: service);
              },
            ),
            ListTile(
              leading: AppIcons.icon(
                AppIcons.delete,
                size: 24,
                color: const Color(0xFF49454F),
              ),
              title: const Text('删除合集'),
              onTap: () {
                final service = ref.read(collectionServiceProvider);
                Navigator.of(context).pop();
                _showDeleteDialog(context, ref: ref, service: service);
              },
            ),
            ListTile(
              leading: AppIcons.icon(
                AppIcons.changeCover,
                size: 24,
                color: const Color(0xFF49454F),
              ),
              title: const Text('修改合集封面'),
              onTap: () {
                final container = ProviderScope.containerOf(
                  context,
                  listen: false,
                );
                final overlay = Overlay.of(context);
                final fileManager = ref.read(fileManagerProvider);
                final collectionService = ref.read(collectionServiceProvider);
                Navigator.of(context).pop();
                _pickCover(
                  container: container,
                  overlay: overlay,
                  fileManager: fileManager,
                  collectionService: collectionService,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context, {
    required WidgetRef ref,
    required CollectionService service,
  }) async {
    final newTitle = await CreateCollectionDialog.show(
      context,
      initialValue: collection.title,
      title: '修改合集名称',
      hintText: '请输入合集名称',
    );
    if (newTitle == null || newTitle.isEmpty || newTitle == collection.title) {
      return;
    }

    final uniqueTitle = await service.uniqueCollectionTitle(
      newTitle,
      excludeTitle: collection.title,
    );
    await service.updateCollection(collection.copyWith(title: uniqueTitle));
    ref.invalidate(collectionsProvider);
  }

  void _showDeleteDialog(
    BuildContext context, {
    required WidgetRef ref,
    required CollectionService service,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('删除合集'),
            content: const Text('确定要删除该合集吗？音频文件不会被删除。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  await service.deleteCollection(collection.id);
                  ref.invalidate(collectionsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _pickCover({
    required ProviderContainer container,
    required OverlayState overlay,
    required FileManager fileManager,
    required CollectionService collectionService,
  }) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final pickedPath = result.files.first.path;
    if (pickedPath == null) return;

    try {
      final importDir = fileManager.getImportDirectory();

      // Handle filename collisions
      final fileName = p.basename(pickedPath);
      var destPath = p.join(importDir, fileName);
      var counter = 1;
      while (await File(destPath).exists()) {
        final baseName = p.basenameWithoutExtension(fileName);
        final ext = p.extension(fileName);
        destPath = p.join(importDir, '$baseName($counter)$ext');
        counter++;
      }
      await File(pickedPath).copy(destPath);

      // Delete old cover file if exists
      if (collection.coverPath != null) {
        final oldFile = File(collection.coverPath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      await collectionService.updateCollection(
        collection.copyWith(coverPath: destPath),
      );
      container.invalidate(collectionsProvider);

      _showMessage(overlay, '封面已更新');
    } catch (e) {
      _showMessage(overlay, '更新失败: $e', isError: true);
    }
  }

  void _showMessage(
    OverlayState overlay,
    String text, {
    bool isError = false,
  }) {
    TopBannerToast.showOnOverlay(overlay, message: text, isError: isError);
  }
}
