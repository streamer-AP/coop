import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/omao_toast.dart';
import '../../../../core/theme/app_icons.dart';
import '../../application/providers/player_providers.dart';
import '../../domain/models/playlist.dart';
import '../widgets/audio_wave_animation.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist =
        ref.watch(playlistStateProvider).valueOrNull ??
        ref.read(playlistServiceProvider).currentPlaylist;
    final notifier = ref.read(playerStateNotifierProvider.notifier);

    Future<void> playItem(String uid) async {
      try {
        await notifier.playPlaylistItem(uid);
      } catch (error) {
        if (!context.mounted) return;
        final message = '$error'.replaceFirst('Exception: ', '').trim();
        OmaoToast.show(
          context,
          message.isEmpty ? '当前音频无法播放' : message,
          isSuccess: false,
        );
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.32,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHandle(),
              const SizedBox(height: 12),
              _buildHeader(context, ref, playlist),
              Expanded(
                child:
                    playlist.isEmpty
                        ? const Center(
                          child: Text(
                            '播放列表为空',
                            style: TextStyle(
                              color: Color(0xFF797979),
                              fontSize: 14,
                            ),
                          ),
                        )
                        : Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          radius: const Radius.circular(20),
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: playlist.items.length,
                            itemBuilder: (context, index) {
                              final item = playlist.items[index];
                              final isCurrent = index == playlist.currentIndex;

                              return _PlaylistItem(
                                title: item.entry.title,
                                artist: item.entry.artist ?? '',
                                isCurrent: isCurrent,
                                onTap: () => playItem(item.uid),
                                onRemove:
                                    () => notifier.removeFromPlaylist(item.uid),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFDBD4EE),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Playlist playlist) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
      child: Row(
        children: [
          IconButton(
            icon: _repeatModeIcon(playlist.repeatMode),
            color: const Color(0xFF797979),
            onPressed: () {
              ref.read(playerStateNotifierProvider.notifier).cycleRepeatMode();
            },
          ),
          Expanded(
            child: Text(
              '当前播放 (${playlist.length})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF797979),
                letterSpacing: 1.6,
              ),
            ),
          ),
          IconButton(
            icon: AppIcons.icon(AppIcons.delete, size: 24),
            color: const Color(0xFF797979),
            onPressed: () => _showClearDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _repeatModeIcon(RepeatMode mode) {
    return switch (mode) {
      RepeatMode.sequential => AppIcons.icon(
        AppIcons.refresh2,
        size: 24,
        color: AppColors.primary,
      ),
      RepeatMode.single => AppIcons.icon(
        AppIcons.refresh1,
        size: 24,
        color: AppColors.primary,
      ),
      RepeatMode.shuffle => AppIcons.icon(
        AppIcons.shuffle,
        size: 24,
        color: AppColors.primary,
      ),
    };
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                    '清空播放列表',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '确定要删除当前播放队列吗？',
                    style: TextStyle(fontSize: 15, color: Color(0xFF1C1B1F)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label: '取消',
                          onTap: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogButton(
                          label: '清空',
                          isPrimary: true,
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
    final primaryColor =
        isCurrent ? AppColors.primary : const Color(0xFF000000);
    final secondaryColor =
        isCurrent
            ? AppColors.primary.withValues(alpha: 0.72)
            : const Color(0xFFC0C0C0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration:
              isCurrent
                  ? BoxDecoration(color: Colors.black.withValues(alpha: 0.06))
                  : null,
          child: Row(
            children: [
              if (isCurrent) ...[
                const AudioWaveAnimation(color: AppColors.primary, size: 12),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: primaryColor,
                        ),
                      ),
                      if (artist.isNotEmpty) ...[
                        TextSpan(
                          text: ' • ',
                          style: TextStyle(fontSize: 14, color: secondaryColor),
                        ),
                        TextSpan(
                          text: artist,
                          style: TextStyle(fontSize: 14, color: secondaryColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: AppIcons.icon(
                  AppIcons.close2,
                  size: 18,
                  color: const Color(0xFFC0C0C0),
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? null : const Color(0xFFF0F0F0),
          gradient: isPrimary ? AppColors.purpleButtonGradient : null,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
            color: isPrimary ? Colors.white : const Color(0xFF1C1B1F),
          ),
        ),
      ),
    );
  }
}
