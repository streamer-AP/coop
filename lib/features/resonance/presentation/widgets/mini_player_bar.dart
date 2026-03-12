import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/player_providers.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({
    super.key,
    this.onTap,
    this.onPlaylistTap,
  });

  final VoidCallback? onTap;
  final VoidCallback? onPlaylistTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final currentEntry = playerState.currentEntry;
    final hasEntry = currentEntry != null;
    final isPlaying = playerState.isPlaying;

    return GestureDetector(
      onTap: hasEntry ? onTap : null,
      onHorizontalDragEnd: hasEntry
          ? (details) {
              final notifier =
                  ref.read(playerStateNotifierProvider.notifier);
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -200) {
                  notifier.next();
                } else if (details.primaryVelocity! > 200) {
                  notifier.previous();
                }
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: hasEntry
              ? AppColors.miniPlayerGradient
              : const LinearGradient(
                  colors: [Color(0xFFD0D0D0), Color(0xFFC0C0C0)],
                ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            _buildCover(currentEntry?.coverPath, hasEntry),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasEntry ? currentEntry.title : '无播放',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasEntry ? Colors.white : const Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    hasEntry ? (currentEntry.artist ?? '') : 'nobody',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasEntry
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
            _buildPlayButton(ref, hasEntry, isPlaying),
            const SizedBox(width: 4),
            _buildPlaylistButton(hasEntry),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(String? coverPath, bool hasEntry) {
    if (coverPath != null) {
      return ClipOval(
        child: Image.file(
          File(coverPath),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(hasEntry),
        ),
      );
    }
    return _placeholderCover(hasEntry);
  }

  Widget _placeholderCover(bool hasEntry) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasEntry
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFFE0E0E0),
      ),
      child: Icon(
        Icons.music_note,
        size: 22,
        color: hasEntry ? Colors.white : const Color(0xFFBDBDBD),
      ),
    );
  }

  Widget _buildPlayButton(WidgetRef ref, bool hasEntry, bool isPlaying) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasEntry
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFFE0E0E0),
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: hasEntry ? Colors.white : const Color(0xFFBDBDBD),
          size: 22,
        ),
        padding: EdgeInsets.zero,
        onPressed: hasEntry
            ? () {
                final notifier =
                    ref.read(playerStateNotifierProvider.notifier);
                isPlaying ? notifier.pause() : notifier.play();
              }
            : null,
      ),
    );
  }

  Widget _buildPlaylistButton(bool hasEntry) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasEntry
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFFE0E0E0),
      ),
      child: IconButton(
        icon: Icon(
          Icons.queue_music,
          color: hasEntry ? Colors.white : const Color(0xFFBDBDBD),
          size: 22,
        ),
        padding: EdgeInsets.zero,
        onPressed: hasEntry ? onPlaylistTap : null,
      ),
    );
  }
}
