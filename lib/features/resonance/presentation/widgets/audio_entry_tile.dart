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
    final effectiveSelected = selectionMode && selected;
    final textColor =
        effectiveSelected || isCurrent
            ? AppColors.primary
            : const Color(0xFF1C1B1F);
    final subColor =
        effectiveSelected || isCurrent
            ? AppColors.primary.withValues(alpha: 0.72)
            : const Color(0xFF79747E);
    final selectionDecoration =
        effectiveSelected
            ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            )
            : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
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
            SizedBox(
              width: 56,
              height: 56,
              child: _buildCover(
                isCurrent,
                selectionMode: selectionMode,
                selected: effectiveSelected,
              ),
            ),
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
                padding: const EdgeInsets.only(left: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color:
                        effectiveSelected
                            ? AppColors.primary.withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          effectiveSelected
                              ? AppColors.primary
                              : const Color(0xFFD2CBDD),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppIcons.icon(
                      effectiveSelected
                          ? AppIcons.circleCheck
                          : AppIcons.circleUnchecked,
                      size: 14,
                      color:
                          effectiveSelected
                              ? Colors.white
                              : const Color(0xFFB8B2BE),
                    ),
                  ),
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

  Widget _buildCover(
    bool isCurrent, {
    required bool selectionMode,
    required bool selected,
  }) {
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

    if (!selectionMode) {
      return cover;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: selected ? 1 : 0.76,
          child: cover,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected
                      ? AppColors.primary.withValues(alpha: 0.24)
                      : Colors.white.withValues(alpha: 0.0),
              width: 2,
            ),
          ),
        ),
      ],
    );
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
