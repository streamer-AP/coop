import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AudioWaveAnimation extends StatefulWidget {
  const AudioWaveAnimation({
    super.key,
    this.color = AppColors.primary,
    this.size = 20,
  });

  final Color color;
  final double size;

  @override
  State<AudioWaveAnimation> createState() => _AudioWaveAnimationState();
}

class _AudioWaveAnimationState extends State<AudioWaveAnimation>
    with TickerProviderStateMixin {
  static const _barCount = 3;
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 150),
      );
    });
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.25, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (final c in _controllers) {
      c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.size / (_barCount * 2.5);
    final gap = barWidth * 0.5;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_barCount, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) {
              return Container(
                width: barWidth,
                height: widget.size * _animations[i].value,
                margin: EdgeInsets.only(right: i < _barCount - 1 ? gap : 0),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
