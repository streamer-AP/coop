import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/storage/file_manager.dart';
import '../../application/providers/collection_providers.dart';
import '../../domain/models/audio_collection.dart';

class CollectionActionSheet extends ConsumerWidget {
  const CollectionActionSheet({
    super.key,
    required this.collection,
  });

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
              leading: const Icon(
                Icons.drive_file_rename_outline,
                color: Color(0xFF49454F),
              ),
              title: const Text('重命名'),
              onTap: () {
                Navigator.of(context).pop();
                _showRenameDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color(0xFF49454F),
              ),
              title: const Text('删除合集'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.image_outlined,
                color: Color(0xFF49454F),
              ),
              title: const Text('修改合集封面'),
              onTap: () {
                Navigator.of(context).pop();
                _pickCover(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: collection.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改合集名称'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '请输入合集名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != collection.title) {
                await ref
                    .read(collectionServiceProvider)
                    .updateCollection(
                      collection.copyWith(title: newTitle),
                    );
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除合集'),
        content: const Text('确定要删除该合集吗？音频文件不会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(collectionServiceProvider)
                  .deleteCollection(collection.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCover(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final pickedPath = result.files.first.path;
    if (pickedPath == null) return;

    try {
      final fileManager = FileManager();
      final importDir = await fileManager.getImportDirectory();
      final destPath = p.join(importDir, p.basename(pickedPath));
      await File(pickedPath).copy(destPath);

      await ref
          .read(collectionServiceProvider)
          .updateCollection(collection.copyWith(coverPath: destPath));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('封面已更新')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }
}
