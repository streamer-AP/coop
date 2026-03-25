import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../application/providers/player_providers.dart';
import '../../domain/models/audio_entry.dart';
import 'audio_wave_animation.dart';

class AudioEntryTile extends ConsumerWidget {
  const AudioEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
    this.onMoreTap,
    this.trailing,
    this.showMoreButton = true,
    this.selectionMode = false,
    this.selected = false,
  });

  final AudioEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMoreTap;
  final Widget? trailing;
  final bool showMoreButton;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEntryId = ref.watch(
      playerStateNotifierProvider.select((state) => state.currentEntry?.id),
    );
    final isCurrent = currentEntryId == entry.id;
    final textColor = isCurrent ? AppColors.primary : const Color(0xFF1C1B1F);
    final subColor =
        isCurrent
            ? AppColors.primary.withValues(alpha: 0.72)
            : const Color(0xFF79747E);
    final selectionDecoration =
        selected
            ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            )
            : null;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration:
            selectionDecoration ??
            (isCurrent
                ? BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                )
                : null),
        child: Row(
          children: [
            SizedBox(width: 56, height: 56, child: _buildCover(isCurrent)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: subColor),
                  ),
                ],
              ),
            ),
            if (selectionMode)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: AppIcons.icon(
                  selected ? AppIcons.circleCheck : AppIcons.circleUnchecked,
                  size: 24,
                  color: selected ? AppColors.primary : const Color(0xFFB8B2BE),
                ),
              ),
            if (trailing != null) trailing!,
            if (!selectionMode && trailing == null && showMoreButton)
              IconButton(
                icon: AppIcons.icon(
                  AppIcons.more1,
                  size: 20,
                  color: const Color(0xFF79747E),
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

  Widget _buildCover(bool isCurrent) {
    Widget cover;
    if (entry.coverPath != null) {
      cover = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(entry.coverPath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(),
        ),
      );
    } else {
      cover = _placeholderCover();
    }

    if (isCurrent) {
      return _CurrentOverlay(cover: cover, entry: entry);
    }

    return cover;
  }

  Widget _placeholderCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/figma/player/default_cover.png',
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// 当前播放条目的封面叠加层，根据播放状态控制动画。
class _CurrentOverlay extends ConsumerWidget {
  const _CurrentOverlay({required this.cover, required this.entry});

  final Widget cover;
  final AudioEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(
      playerStateNotifierProvider.select((s) => s.isPlaying),
    );

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          cover,
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child:
                  isPlaying
                      ? const AudioWaveAnimation(color: Colors.white, size: 24)
                      : AppIcons.icon(
                        AppIcons.pause,
                        size: 20,
                        color: Colors.white,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
