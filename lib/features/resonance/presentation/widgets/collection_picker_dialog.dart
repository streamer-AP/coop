import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_toast.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../../domain/models/audio_collection.dart';
import 'collection_card.dart';
import 'create_collection_dialog.dart';

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
  Set<int>? _alreadyInCollectionIds;

  @override
  void initState() {
    super.initState();
    _loadAlreadyInCollections();
  }

  Future<void> _loadAlreadyInCollections() async {
    final repo = ref.read(resonanceRepositoryProvider);
    final ids = await repo.getCollectionIdsContainingAllEntries(
      widget.entryIds,
    );
    if (mounted) {
      setState(() => _alreadyInCollectionIds = ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: _selectedCollectionIds.isEmpty ? null : _confirm,
                  child: Text(
                    '完成',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedCollectionIds.isEmpty
                              ? const Color(0xFF79747E)
                              : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          NewCollectionTile(onTap: _showNewCollectionDialog),
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
                    final alreadyAdded =
                        _alreadyInCollectionIds?.contains(collection.id) ??
                        false;
                    final isSelected = _selectedCollectionIds.contains(
                      collection.id,
                    );
                    return _CollectionItem(
                      collection: collection,
                      isSelected: isSelected,
                      isDisabled: alreadyAdded,
                      onTap:
                          alreadyAdded
                              ? null
                              : () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCollectionIds.remove(
                                      collection.id,
                                    );
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
    ref.invalidate(collectionsProvider);
    if (mounted) {
      OmaoToast.show(context, '添加成功');
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _showNewCollectionDialog() async {
    final name = await CreateCollectionDialog.show(context);
    if (!mounted || name == null || name.isEmpty) {
      return;
    }
    final service = ref.read(collectionServiceProvider);
    final uniqueName = await service.uniqueCollectionTitle(name);
    final collection = AudioCollection(id: 0, title: uniqueName);
    final id = await service.createCollection(collection);
    if (widget.entryIds.isNotEmpty) {
      await service.addEntriesToCollection(widget.entryIds, id);
    }
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _CollectionItem extends StatelessWidget {
  const _CollectionItem({
    required this.collection,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  final AudioCollection collection;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _SelectionIndicator(
                isSelected: isSelected,
                isDisabled: isDisabled,
              ),
              const SizedBox(width: 12),
              CollectionArtwork(coverPath: collection.coverPath),
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
                    Row(
                      children: [
                        if (isDisabled)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Text(
                              '已添加',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF797979),
                              ),
                            ),
                          ),
                        CollectionCountText(
                          count: collection.entryCount,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF797979),
                            height: 22 / 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.isSelected,
    required this.isDisabled,
  });

  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final assetPath =
        isDisabled
            ? AppIcons.circleAdded
            : (isSelected ? AppIcons.circleCheck : AppIcons.circleUnchecked);
    return AppIcons.asset(assetPath, width: 24, height: 24);
  }
}
