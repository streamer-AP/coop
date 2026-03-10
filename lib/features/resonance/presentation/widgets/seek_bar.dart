import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final theme = Theme.of(context);

    final maxSeconds = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;
    final currentValue = _dragValue ?? position.inMilliseconds.toDouble();

    return Column(
      children: [
        Slider(
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
                style: theme.textTheme.bodySmall,
              ),
              Text(
                _formatDuration(duration),
                style: theme.textTheme.bodySmall,
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
