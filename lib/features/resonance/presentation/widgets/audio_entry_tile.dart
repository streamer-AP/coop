import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/player_providers.dart';
import '../../domain/models/audio_entry.dart';
import 'audio_wave_animation.dart';

class AudioEntryTile extends ConsumerWidget {
  const AudioEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onMoreTap,
    this.trailing,
    this.showMoreButton = true,
  });

  final AudioEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final Widget? trailing;
  final bool showMoreButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final isCurrent = playerState.currentEntry?.id == entry.id;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isCurrent
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            _buildCover(theme, isCurrent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isCurrent
                          ? AppColors.primary
                          : const Color(0xFF1C1B1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCurrent
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : const Color(0xFF79747E),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && showMoreButton)
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF79747E),
                  size: 20,
                ),
                onPressed: onMoreTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(ThemeData theme, bool isCurrent) {
    Widget cover;
    if (entry.coverPath != null) {
      cover = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(entry.coverPath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(theme),
        ),
      );
    } else {
      cover = _placeholderCover(theme);
    }

    if (isCurrent) {
      return Stack(
        children: [
          cover,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: AudioWaveAnimation(
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return cover;
  }

  Widget _placeholderCover(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4C4E8),
            Color(0xFFE8E0F0),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
