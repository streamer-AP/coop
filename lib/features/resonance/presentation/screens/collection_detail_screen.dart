import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/omao_toast.dart';
import '../../../../core/theme/app_icons.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/sort_providers.dart';
import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../widgets/audio_entry_action_sheet.dart';
import '../widgets/audio_entry_tile.dart';
import '../widgets/create_collection_dialog.dart';
import '../widgets/sort_bottom_sheet.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({super.key, required this.collectionId});

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(collectionEntriesProvider(collectionId));
    final collectionsAsync = ref.watch(collectionsProvider);

    // Find the collection from the stream
    final collection = collectionsAsync.whenOrNull(
      data: (cols) => cols.where((c) => c.id == collectionId).firstOrNull,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Purple gradient background
          Container(
            height: 280,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, ref, collection),
                if (collection != null)
                  _buildCollectionHeader(context, ref, collection),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.listBackground,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: entriesAsync.when(
                      data:
                          (entries) => _buildEntryList(
                            context,
                            ref,
                            entries,
                            collection,
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AudioCollection? collection,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: AppIcons.asset(AppIcons.arrowLeft, width: 40, height: 40),
          ),
          const Expanded(
            child: Text(
              '合集',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B1F),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for the back button
        ],
      ),
    );
  }

  Widget _buildCollectionHeader(
    BuildContext context,
    WidgetRef ref,
    AudioCollection collection,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                collection.coverPath != null
                    ? Image.file(
                      File(collection.coverPath!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderCover(),
                    )
                    : _placeholderCover(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        collection.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showRenameDialog(context, ref, collection),
                      child: AppIcons.icon(
                        AppIcons.edit,
                        size: 18,
                        color: const Color(0xFF79747E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip('${collection.entryCount} 个'),
                    const SizedBox(width: 12),
                    _InfoChip(
                      '${(collection.totalDurationMs / 60000).round()} 分钟',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/figma/player/default_cover.png',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildEntryList(
    BuildContext context,
    WidgetRef ref,
    List<AudioEntry> entries,
    AudioCollection? collection,
  ) {
    final sortMode = ref.watch(sortModeNotifierProvider);
    final sorted = _sortEntries(entries, sortMode);

    return Column(
      children: [
        // Play all + sort + add
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Play all button + label
              Expanded(
                child: Opacity(
                  opacity: sorted.isEmpty ? 0.38 : 1.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap:
                          sorted.isEmpty
                              ? null
                              : () => _playCollection(
                                context,
                                ref,
                                sorted.first,
                                sorted,
                                collection?.title ?? '合集播放',
                              ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            AppIcons.asset(
                              AppIcons.play2,
                              width: 46,
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '播放全部',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: AppIcons.icon(
                  AppIcons.delete,
                  size: 22,
                  color: const Color(0xFF49454F),
                ),
                onPressed: () => _confirmDelete(context, ref),
              ),
              IconButton(
                icon: AppIcons.asset(AppIcons.add1, width: 19, height: 19),
                onPressed:
                    () => _navigateToAddAudio(
                      context,
                      sorted.map((e) => e.id).toList(),
                    ),
              ),
              IconButton(
                icon: AppIcons.icon(
                  AppIcons.sort,
                  size: 22,
                  color: const Color(0xFF49454F),
                ),
                onPressed: () => SortBottomSheet.show(context),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              sorted.isEmpty
                  ? const Center(
                    child: Text(
                      '暂无音频',
                      style: TextStyle(color: Color(0xFF79747E)),
                    ),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        for (final entry in sorted)
                          AudioEntryTile(
                            entry: entry,
                            onTap:
                                () => _playAndOpenCollectionPlayer(
                                  context,
                                  ref,
                                  entry,
                                  sorted,
                                  collection?.title ?? '合集播放',
                                ),
                            onMoreTap: () {
                              AudioEntryActionSheet.show(
                                context,
                                entry: entry,
                                collectionId: collectionId,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  List<AudioEntry> _sortEntries(List<AudioEntry> entries, SortMode mode) {
    final sorted = List<AudioEntry>.of(entries);
    switch (mode) {
      case SortMode.alphabeticalAsc:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case SortMode.alphabeticalDesc:
        sorted.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
      case SortMode.timeAsc:
        sorted.sort(
          (a, b) => (a.createdAt ?? DateTime(0)).compareTo(
            b.createdAt ?? DateTime(0),
          ),
        );
      case SortMode.timeDesc:
        sorted.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
    }
    return sorted;
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final service = ref.read(collectionServiceProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('删除合集'),
            content: const Text('确定要删除该合集吗？音频文件不会被删除。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await service.deleteCollection(collectionId);
        ref.invalidate(collectionsProvider);
      } catch (e) {
        if (context.mounted) {
          OmaoToast.show(context, '删除失败: $e', isSuccess: false);
        }
        return;
      }
      if (context.mounted) context.pop();
    }
  }

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    AudioCollection collection,
  ) async {
    final newTitle = await CreateCollectionDialog.show(
      context,
      initialValue: collection.title,
      title: '修改合集名称',
      hintText: '请输入合集名称',
    );
    if (newTitle == null || newTitle.isEmpty || newTitle == collection.title) {
      return;
    }

    final service = ref.read(collectionServiceProvider);
    final uniqueTitle = await service.uniqueCollectionTitle(
      newTitle,
      excludeTitle: collection.title,
    );
    await service.updateCollection(collection.copyWith(title: uniqueTitle));
    ref.invalidate(collectionsProvider);
  }

  void _navigateToAddAudio(BuildContext context, List<int> existingIds) {
    context.pushNamed(
      RouteNames.addToCollection,
      pathParameters: {'id': collectionId.toString()},
      extra: existingIds,
    );
  }
}

Future<void> _playAndOpenCollectionPlayer(
  BuildContext context,
  WidgetRef ref,
  AudioEntry entry,
  List<AudioEntry> entries,
  String playlistTitle,
) async {
  final errorMessage = await _playCollectionEntry(
    ref,
    entry,
    entries,
    playlistTitle,
  );

  if (!context.mounted) return;
  context.pushNamed(RouteNames.resonancePlayer);

  final message = errorMessage;
  if (message != null) {
    OmaoToast.show(
      context,
      message.isEmpty ? '当前音频无法播放' : message,
      isSuccess: false,
    );
  }
}

Future<void> _playCollection(
  BuildContext context,
  WidgetRef ref,
  AudioEntry entry,
  List<AudioEntry> entries,
  String playlistTitle,
) async {
  final errorMessage = await _playCollectionEntry(
    ref,
    entry,
    entries,
    playlistTitle,
  );

  if (!context.mounted) return;
  final message = errorMessage;
  if (message != null) {
    OmaoToast.show(
      context,
      message.isEmpty ? '当前音频无法播放' : message,
      isSuccess: false,
    );
  }
}

Future<String?> _playCollectionEntry(
  WidgetRef ref,
  AudioEntry entry,
  List<AudioEntry> entries,
  String playlistTitle,
) async {
  String? errorMessage;
  try {
    await ref
        .read(playerStateNotifierProvider.notifier)
        .playCollectionEntry(
          entry,
          context: entries,
          playlistTitle: playlistTitle,
        );
  } catch (error) {
    errorMessage = '$error'.replaceFirst('Exception: ', '').trim();
  }

  return errorMessage;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Color(0xFF79747E)),
    );
  }
}
