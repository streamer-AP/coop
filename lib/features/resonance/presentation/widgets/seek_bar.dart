import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/player_providers.dart';

class SeekBar extends ConsumerStatefulWidget {
  const SeekBar({super.key});

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final position = playerState.position;
    final duration = playerState.duration;

    final maxSeconds =
        duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final currentValue = _dragValue ?? position.inMilliseconds.toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            activeTrackColor: const Color(0xFF6A53A7),
            inactiveTrackColor: const Color(0xFFD9D9D9),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
          ),
          child: Slider(
            value: currentValue.clamp(0, maxSeconds),
            max: maxSeconds,
            onChanged: (value) {
              setState(() => _dragValue = value);
            },
            onChangeEnd: (value) {
              ref
                  .read(playerStateNotifierProvider.notifier)
                  .seekTo(Duration(milliseconds: value.toInt()));
              setState(() => _dragValue = null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(
                  _dragValue != null
                      ? Duration(milliseconds: _dragValue!.toInt())
                      : position,
                ),
                style: const TextStyle(fontSize: 12, color: Color(0xFFC0C0C0)),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(fontSize: 12, color: Color(0xFFC0C0C0)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
