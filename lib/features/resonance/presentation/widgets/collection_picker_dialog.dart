import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/collection_providers.dart';
import '../../domain/models/audio_collection.dart';

class CollectionPickerDialog extends ConsumerStatefulWidget {
  const CollectionPickerDialog({
    super.key,
    required this.entryIds,
    this.scrollController,
  });

  final List<int> entryIds;
  final ScrollController? scrollController;

  @override
  ConsumerState<CollectionPickerDialog> createState() =>
      _CollectionPickerDialogState();
}

class _CollectionPickerDialogState
    extends ConsumerState<CollectionPickerDialog> {
  final Set<int> _selectedCollectionIds = {};

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '添加到合集',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: _selectedCollectionIds.isEmpty ? null : _confirm,
                  child: Text(
                    '完成',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _selectedCollectionIds.isEmpty
                          ? const Color(0xFF79747E)
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // New collection button
          InkWell(
            onTap: _showNewCollectionDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF79747E),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '新建合集',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF79747E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: collectionsAsync.when(
              data: (collections) {
                if (collections.isEmpty) {
                  return const Center(
                    child: Text(
                      '暂无合集',
                      style: TextStyle(color: Color(0xFF79747E)),
                    ),
                  );
                }
                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    final isSelected =
                        _selectedCollectionIds.contains(collection.id);
                    return _CollectionItem(
                      collection: collection,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCollectionIds.remove(collection.id);
                          } else {
                            _selectedCollectionIds.add(collection.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    final service = ref.read(collectionServiceProvider);
    for (final collectionId in _selectedCollectionIds) {
      await service.addEntriesToCollection(widget.entryIds, collectionId);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加成功')),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _showNewCollectionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建合集'),
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
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final service = ref.read(collectionServiceProvider);
              final collection = AudioCollection(id: 0, title: name);
              final id = await service.createCollection(collection);
              if (widget.entryIds.isNotEmpty) {
                await service.addEntriesToCollection(widget.entryIds, id);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) Navigator.of(context).pop(true);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _CollectionItem extends StatelessWidget {
  const _CollectionItem({
    required this.collection,
    required this.isSelected,
    required this.onTap,
  });

  final AudioCollection collection;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFBDBDBD),
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            _buildCover(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collection.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '共 ${collection.entryCount} 个',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF79747E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (collection.coverPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(collection.coverPath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(),
        ),
      );
    }
    return _placeholderCover();
  }

  Widget _placeholderCover() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.library_music,
        size: 28,
        color: Color(0xFF79747E),
      ),
    );
  }
}
