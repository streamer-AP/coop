import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/player_providers.dart';

class SeekBar extends ConsumerStatefulWidget {
  const SeekBar({super.key});

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  double? _dragFraction;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final position = playerState.position;
    final duration = playerState.duration;
    final totalMs = duration.inMilliseconds;
    final progress =
        totalMs > 0 ? (position.inMilliseconds / totalMs).clamp(0.0, 1.0) : 0.0;
    final effectiveProgress = (_dragFraction ?? progress).clamp(0.0, 1.0);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final knobOffset = width * effectiveProgress;

            void updateFraction(Offset localPosition) {
              if (width <= 0) return;
              setState(() {
                _dragFraction = (localPosition.dx / width).clamp(0.0, 1.0);
              });
            }

            Future<void> commitFraction([double? fraction]) async {
              final targetFraction = (fraction ?? _dragFraction ?? progress)
                  .clamp(0.0, 1.0);
              setState(() => _dragFraction = null);
              await ref
                  .read(playerStateNotifierProvider.notifier)
                  .seekTo(
                    Duration(milliseconds: (totalMs * targetFraction).round()),
                  );
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown:
                  totalMs > 0
                      ? (details) {
                        updateFraction(details.localPosition);
                        commitFraction(details.localPosition.dx / width);
                      }
                      : null,
              onHorizontalDragStart:
                  totalMs > 0
                      ? (details) => updateFraction(details.localPosition)
                      : null,
              onHorizontalDragUpdate:
                  totalMs > 0
                      ? (details) => updateFraction(details.localPosition)
                      : null,
              onHorizontalDragEnd: totalMs > 0 ? (_) => commitFraction() : null,
              onHorizontalDragCancel:
                  () => setState(() => _dragFraction = null),
              child: SizedBox(
                height: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: effectiveProgress,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF605591), Color(0xFFC5B8FF)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (knobOffset - 5).clamp(0.0, width - 10),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFE5DFFF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFBCAAF1,
                              ).withValues(alpha: 0.42),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(
                _dragFraction == null
                    ? position
                    : Duration(
                      milliseconds:
                          (totalMs * _dragFraction!.clamp(0.0, 1.0)).round(),
                    ),
              ),
              style: const TextStyle(fontSize: 12, color: Color(0xFFC0C0C0)),
            ),
            Text(
              _formatDuration(duration),
              style: const TextStyle(fontSize: 12, color: Color(0xFFC0C0C0)),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
