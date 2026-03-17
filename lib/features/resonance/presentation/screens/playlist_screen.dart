import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/player_providers.dart';
import '../../domain/models/playlist.dart';
import '../widgets/audio_wave_animation.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistSvc = ref.watch(playlistServiceProvider);
    final playlist = playlistSvc.currentPlaylist;
    final notifier = ref.read(playerStateNotifierProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.74,
      minChildSize: 0.32,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context, ref, playlist),
              const Divider(height: 1),
              Expanded(
                child:
                    playlist.isEmpty
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
                              onTap: () => notifier.playPlaylistItem(item.uid),
                              onRemove:
                                  () => notifier.removeFromPlaylist(item.uid),
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
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFFDBD4EE),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Playlist playlist) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
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
                fontWeight: FontWeight.w500,
                color: Color(0xFF797979),
                letterSpacing: 1.6,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF797979)),
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
        color: Color(0xFF797979),
      ),
      RepeatMode.single => const Icon(
        Icons.repeat_one,
        color: Color(0xFF797979),
      ),
      RepeatMode.shuffle => const Icon(Icons.shuffle, color: Color(0xFF797979)),
    };
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '提示',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '确定要清空播放列表吗？',
                    style: TextStyle(fontSize: 15, color: Color(0xFF1C1B1F)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1C1B1F),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await ref
                                .read(playerStateNotifierProvider.notifier)
                                .clearPlaylist();
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                            if (context.mounted) {
                              Navigator.of(context).maybePop();
                            }
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.purpleButtonGradient,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '清空',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration:
            isCurrent
                ? BoxDecoration(
                  color: const Color(0xFF000000).withValues(alpha: 0.06),
                )
                : null,
        child: Row(
          children: [
            if (isCurrent) ...[
              const AudioWaveAnimation(color: AppColors.primary, size: 12),
              const SizedBox(width: 6),
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
                        fontSize: 32 / 2,
                        fontWeight: FontWeight.w400,
                        color:
                            isCurrent
                                ? AppColors.primary
                                : const Color(0xFF000000),
                      ),
                    ),
                    if (artist.isNotEmpty) ...[
                      TextSpan(
                        text: ' · ',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isCurrent
                                  ? AppColors.primary.withValues(alpha: 0.7)
                                  : const Color(0xFFC0C0C0),
                        ),
                      ),
                      TextSpan(
                        text: artist,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isCurrent
                                  ? AppColors.primary.withValues(alpha: 0.7)
                                  : const Color(0xFFC0C0C0),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFFC0C0C0)),
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
