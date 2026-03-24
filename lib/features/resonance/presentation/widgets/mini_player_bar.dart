import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../application/providers/player_providers.dart';

class MiniPlayerBar extends ConsumerStatefulWidget {
  const MiniPlayerBar({super.key, this.onTap, this.onPlaylistTap});

  final VoidCallback? onTap;
  final VoidCallback? onPlaylistTap;

  @override
  ConsumerState<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends ConsumerState<MiniPlayerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final currentEntry = playerState.currentEntry;
    final hasEntry = currentEntry != null;
    final isPlaying = playerState.isPlaying;

    if (hasEntry && isPlaying) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      _rotationController.stop();
      if (!hasEntry && _rotationController.value != 0) {
        _rotationController.value = 0;
      }
    }

    // 计算播放进度 0.0 ~ 1.0
    final progress =
        playerState.duration.inMilliseconds > 0
            ? playerState.position.inMilliseconds /
                playerState.duration.inMilliseconds
            : 0.0;

    return GestureDetector(
      onTap: hasEntry ? widget.onTap : null,
      onHorizontalDragEnd:
          hasEntry
              ? (details) {
                final notifier = ref.read(playerStateNotifierProvider.notifier);
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
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              // 背景层 — 左#605591→右#C5B8FF
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: hasEntry ? null : const Color(0xB3C0C0C0),
                    gradient:
                        hasEntry
                            ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF605591), Color(0xFFC5B8FF)],
                            )
                            : null,
                  ),
                ),
              ),
              // 内容层
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 14, 0),
                child: Row(
                  children: [
                    _buildCover(currentEntry?.coverPath, hasEntry),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hasEntry ? currentEntry.title : '无播放',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasEntry
                                ? (currentEntry.artist ?? 'Unknown Artist')
                                : 'nobody',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: -0.32,
                              color:
                                  hasEntry
                                      ? Colors.white.withValues(alpha: 0.30)
                                      : Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPlayButton(ref, hasEntry, isPlaying, progress),
                    const SizedBox(width: 6),
                    _buildPlaylistButton(hasEntry),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(String? coverPath, bool hasEntry) {
    Widget coverImage;
    if (coverPath != null) {
      coverImage = ClipOval(
        child: Image.file(
          File(coverPath),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(hasEntry),
        ),
      );
    } else {
      coverImage = _placeholderCover(hasEntry);
    }

    return RotationTransition(turns: _rotationController, child: coverImage);
  }

  Widget _placeholderCover(bool hasEntry) {
    return ClipOval(
      child: Image.asset(
        'assets/figma/player/default_cover.png',
        width: 52,
        height: 52,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPlayButton(
    WidgetRef ref,
    bool hasEntry,
    bool isPlaying,
    double progress,
  ) {
    if (!hasEntry) {
      return _buildInactiveCircleButton(icon: AppIcons.play, onTap: null);
    }

    return GestureDetector(
      onTap: () {
        final notifier = ref.read(playerStateNotifierProvider.notifier);
        isPlaying ? notifier.pause() : notifier.play();
      },
      child: SizedBox(
        width: 36,
        height: 36,
        child: CustomPaint(
          painter: _ProgressRingPainter(
            progress: progress,
            trackColor: Colors.white.withValues(alpha: 0.25),
            progressColor: Colors.white,
            strokeWidth: 2.0,
          ),
          child: Center(
            child: AppIcons.icon(
              isPlaying ? AppIcons.pause : AppIcons.play,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistButton(bool hasEntry) {
    if (!hasEntry) {
      return _buildInactiveCircleButton(icon: AppIcons.playlist, onTap: null);
    }

    return GestureDetector(
      onTap: widget.onPlaylistTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Center(
              child: AppIcons.icon(
                AppIcons.playlist,
                size: 19,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveCircleButton({
    required String icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 38,
        height: 38,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.24),
          ),
          child: Center(
            child: AppIcons.icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// 播放进度环
class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // 底圈轨道
    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // 进度弧
    if (progress > 0) {
      final progressPaint =
          Paint()
            ..color = progressColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // 从顶部开始
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
