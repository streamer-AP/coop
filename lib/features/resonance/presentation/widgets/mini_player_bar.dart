import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Stack(
            children: [
              // 背景层 — 左#605591→右#C5B8FF
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: hasEntry ? null : const Color(0xAFC5C5C8),
                    gradient:
                        hasEntry
                            ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xE05B5288), Color(0xD9B9AEF1)],
                            )
                            : null,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    boxShadow: AppShadows.soft(),
                  ),
                ),
              ),
              // 内容层
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                child: Row(
                  children: [
                    _buildCover(currentEntry?.coverPath, hasEntry),
                    const SizedBox(width: 10),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            hasEntry
                                ? (currentEntry.artist ?? 'Unknown Artist')
                                : 'nobody',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: -0.1,
                              color:
                                  hasEntry
                                      ? Colors.white.withValues(alpha: 0.58)
                                      : Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPlayButton(ref, hasEntry, isPlaying, progress),
                    const SizedBox(width: 4),
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
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xFFF0ECE6)),
          child: Image.file(
            File(coverPath),
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _placeholderCover(hasEntry),
          ),
        ),
      );
    } else {
      coverImage = _placeholderCover(hasEntry);
    }

    return RotationTransition(
      turns: _rotationController,
      child: SizedBox(width: 52, height: 52, child: coverImage),
    );
  }

  Widget _placeholderCover(bool hasEntry) {
    return ClipOval(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hasEntry ? null : const Color(0xFFD5D5D7),
        ),
        child: Image.asset(
          'assets/figma/player/default_cover.png',
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          color: hasEntry ? null : Colors.grey.shade500,
          colorBlendMode: hasEntry ? null : BlendMode.modulate,
        ),
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
        width: 34,
        height: 34,
        child: CustomPaint(
          painter: _ProgressRingPainter(
            progress: progress,
            trackColor: Colors.white.withValues(alpha: 0.22),
            progressColor: Colors.white,
            strokeWidth: 1.8,
          ),
          child: Center(
            child: AppIcons.icon(
              isPlaying ? AppIcons.pause : AppIcons.play,
              size: 18,
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
        width: 34,
        height: 34,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.14),
            ),
            child: Center(
              child: AppIcons.icon(
                AppIcons.playlist,
                size: 17,
                color: Colors.white.withValues(alpha: 0.82),
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
        width: 34,
        height: 34,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          child: Center(
            child: AppIcons.icon(icon, size: 18, color: Colors.white),
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
