import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/player_providers.dart';
import '../../domain/models/playlist.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistSvc = ref.watch(playlistServiceProvider);
    final playlist = playlistSvc.currentPlaylist;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context, ref, playlist),
              const Divider(height: 1),
              Expanded(
                child: playlist.isEmpty
                    ? const Center(
                        child: Text(
                          '播放列表为空',
                          style: TextStyle(
                            color: Color(0xFF79747E),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: playlist.items.length,
                        itemBuilder: (context, index) {
                          final item = playlist.items[index];
                          final isCurrent = index == playlist.currentIndex;

                          return _PlaylistItem(
                            title: item.entry.title,
                            artist: item.entry.artist ?? '',
                            isCurrent: isCurrent,
                            onTap: () {
                              ref
                                  .read(playerStateNotifierProvider.notifier)
                                  .playEntry(item.entry);
                            },
                            onRemove: () {
                              ref
                                  .read(playlistServiceProvider)
                                  .removeItem(item.uid);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Repeat mode button
          IconButton(
            icon: _repeatModeIcon(playlist.repeatMode),
            onPressed: () {
              ref.read(playerStateNotifierProvider.notifier).cycleRepeatMode();
            },
          ),
          const Expanded(
            child: Text(
              '当前播放',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Clear button
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFF49454F),
            ),
            onPressed: () => _showClearDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Icon _repeatModeIcon(RepeatMode mode) {
    return switch (mode) {
      RepeatMode.sequential => const Icon(
          Icons.repeat,
          color: Color(0xFF49454F),
        ),
      RepeatMode.single => const Icon(
          Icons.repeat_one,
          color: AppColors.primary,
        ),
      RepeatMode.shuffle => const Icon(
          Icons.shuffle,
          color: AppColors.primary,
        ),
    };
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空列表'),
        content: const Text('确定要清空当前播放列表吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(playlistServiceProvider).clear();
              Navigator.of(ctx).pop();
            },
            child: const Text(
              '清空',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistItem extends StatelessWidget {
  const _PlaylistItem({
    required this.title,
    required this.artist,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
  });

  final String title;
  final String artist;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isCurrent
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
              )
            : null,
        child: Row(
          children: [
            if (isCurrent) ...[
              const Icon(
                Icons.equalizer,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent
                            ? AppColors.primary
                            : const Color(0xFF1C1B1F),
                      ),
                    ),
                    if (artist.isNotEmpty) ...[
                      TextSpan(
                        text: ' · ',
                        style: TextStyle(
                          fontSize: 13,
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.7)
                              : const Color(0xFF79747E),
                        ),
                      ),
                      TextSpan(
                        text: artist,
                        style: TextStyle(
                          fontSize: 13,
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.7)
                              : const Color(0xFF79747E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 18,
                color: Color(0xFF79747E),
              ),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
