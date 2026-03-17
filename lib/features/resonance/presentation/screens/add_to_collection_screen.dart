import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../../domain/models/audio_entry.dart';

class AddToCollectionScreen extends ConsumerStatefulWidget {
  const AddToCollectionScreen({
    super.key,
    required this.collectionId,
    required this.existingEntryIds,
  });

  final int collectionId;
  final List<int> existingEntryIds;

  @override
  ConsumerState<AddToCollectionScreen> createState() =>
      _AddToCollectionScreenState();
}

class _AddToCollectionScreenState
    extends ConsumerState<AddToCollectionScreen> {
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(watchEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加音频'),
        actions: [
          TextButton(
            onPressed: _selectedIds.isEmpty ? null : _confirm,
            child: Text(
              '完成 (${_selectedIds.length})',
              style: TextStyle(
                color: _selectedIds.isEmpty
                    ? const Color(0xFF79747E)
                    : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('暂无音频'));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isExisting =
                  widget.existingEntryIds.contains(entry.id);
              final isSelected = _selectedIds.contains(entry.id);

              return _SelectableEntryTile(
                entry: entry,
                isSelected: isSelected,
                isDisabled: isExisting,
                onTap: isExisting
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(entry.id);
                          } else {
                            _selectedIds.add(entry.id);
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
    );
  }

  Future<void> _confirm() async {
    final service = ref.read(collectionServiceProvider);
    await service.addEntriesToCollection(
      _selectedIds.toList(),
      widget.collectionId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已成功添加 ${_selectedIds.length} 条音频')),
      );
      Navigator.of(context).pop(true);
    }
  }
}

class _SelectableEntryTile extends StatelessWidget {
  const _SelectableEntryTile({
    required this.entry,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  final AudioEntry entry;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = isDisabled ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDisabled)
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap?.call(),
                activeColor: AppColors.primary,
                shape: const CircleBorder(),
              )
            else
              const SizedBox(
                width: 48,
                child: Icon(Icons.check, color: Color(0xFFBDBDBD)),
              ),
            const SizedBox(width: 8),
            _buildCover(theme),
          ],
        ),
        title: Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          entry.artist ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCover(ThemeData theme) {
    if (entry.coverPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(entry.coverPath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(theme),
        ),
      );
    }
    return _placeholderCover(theme);
  }

  Widget _placeholderCover(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
