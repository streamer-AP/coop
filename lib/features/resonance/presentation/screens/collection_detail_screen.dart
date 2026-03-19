import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/providers/player_providers.dart';
import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../widgets/audio_entry_action_sheet.dart';
import '../widgets/audio_entry_tile.dart';
import '../widgets/sort_bottom_sheet.dart';
import 'add_to_collection_screen.dart';

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
                if (collection != null) _buildCollectionHeader(collection),
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
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: () => context.pop(),
              color: const Color(0xFF49454F),
            ),
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

  Widget _buildCollectionHeader(AudioCollection collection) {
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
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF79747E),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip('${collection.entryCount} 个'),
                    const SizedBox(width: 12),
                    _InfoChip('${(collection.entryCount * 3.5).toInt()} 分钟'),
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
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.library_music,
        size: 40,
        color: Color(0xFF79747E),
      ),
    );
  }

  Widget _buildEntryList(
    BuildContext context,
    WidgetRef ref,
    List<AudioEntry> entries,
    AudioCollection? collection,
  ) {
    return Column(
      children: [
        // Play all + sort + add
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Play all button
              _PlayAllButton(
                onTap:
                    entries.isEmpty
                        ? null
                        : () => _playAndOpenCollectionPlayer(
                          context,
                          ref,
                          entries.first,
                          entries,
                          collection?.title ?? '合集播放',
                        ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '播放全部',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF49454F),
                  size: 22,
                ),
                onPressed: () => _confirmDelete(context, ref),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_box_outlined,
                  color: Color(0xFF49454F),
                  size: 22,
                ),
                onPressed:
                    () => _navigateToAddAudio(
                      context,
                      entries.map((e) => e.id).toList(),
                    ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.sort,
                  color: Color(0xFF49454F),
                  size: 22,
                ),
                onPressed: () => SortBottomSheet.show(context),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              entries.isEmpty
                  ? const Center(
                    child: Text(
                      '暂无音频',
                      style: TextStyle(color: Color(0xFF79747E)),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return AudioEntryTile(
                        entry: entry,
                        onTap:
                            () => _playAndOpenCollectionPlayer(
                              context,
                              ref,
                              entry,
                              entries,
                              collection?.title ?? '合集播放',
                            ),
                        onMoreTap: () {
                          AudioEntryActionSheet.show(
                            context,
                            entry: entry,
                            collectionId: collectionId,
                          );
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
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
      await ref.read(collectionServiceProvider).deleteCollection(collectionId);
      if (context.mounted) context.pop();
    }
  }

  void _navigateToAddAudio(BuildContext context, List<int> existingIds) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => AddToCollectionScreen(
              collectionId: collectionId,
              existingEntryIds: existingIds,
            ),
      ),
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
  String? errorMessage;
  try {
    await ref
        .read(playerStateNotifierProvider.notifier)
        .playEntryWithTitle(
          entry,
          context: entries,
          playlistTitle: playlistTitle,
        );
  } catch (error) {
    errorMessage = '$error'.replaceFirst('Exception: ', '').trim();
  }

  if (!context.mounted) return;
  context.pushNamed(RouteNames.resonancePlayer);

  final message = errorMessage;
  if (message != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.isEmpty ? '当前音频无法播放' : message)),
    );
  }
}

class _PlayAllButton extends StatelessWidget {
  const _PlayAllButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
      ),
    );
  }
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
