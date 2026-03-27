import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controller_assets.dart';

class ControllerStrengthSlider extends StatefulWidget {
  const ControllerStrengthSlider({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  State<ControllerStrengthSlider> createState() =>
      _ControllerStrengthSliderState();
}

class _ControllerStrengthSliderState extends State<ControllerStrengthSlider> {
  static const _activeColor = ControllerAssets.accent;
  static const _trackColor = Colors.white;
  static const _dotColor = ControllerAssets.sliderDot;
  static const _labelColor = Colors.white;
  static const _trackHeight = 6.0;
  static const _knobWidth = 22.0;
  static const _knobHeight = 26.0;
  static const _trackTop = 10.0;

  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final maxIndex = widget.labels.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final knobOffset = _offsetForValue(
          _dragValue ?? widget.selectedIndex.toDouble(),
          maxWidth,
        );
        const trackY = _trackTop + (_knobHeight / 2) - (_trackHeight / 2);
        final fillWidth = knobOffset + (_knobWidth / 2);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart:
                  (details) => setState(
                    () =>
                        _dragValue = _valueFromOffset(
                          details.localPosition.dx,
                          maxWidth,
                        ),
                  ),
              onHorizontalDragUpdate:
                  (details) => setState(
                    () =>
                        _dragValue = _valueFromOffset(
                          details.localPosition.dx,
                          maxWidth,
                        ),
                  ),
              onHorizontalDragEnd: (_) => _commitDrag(maxIndex),
              onHorizontalDragCancel: () => _commitDrag(maxIndex),
              onTapDown: (details) {
                final nextValue = _valueFromOffset(
                  details.localPosition.dx,
                  maxWidth,
                );
                final nextIndex = nextValue.round().clamp(0, maxIndex);
                widget.onChanged(nextIndex);
              },
              child: SizedBox(
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: trackY,
                      child: Container(
                        height: _trackHeight,
                        decoration: BoxDecoration(
                          color: _trackColor,
                          borderRadius: BorderRadius.circular(_trackHeight / 2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      width: fillWidth,
                      top: trackY,
                      child: Container(
                        height: _trackHeight,
                        decoration: BoxDecoration(
                          color: _activeColor,
                          borderRadius: BorderRadius.circular(_trackHeight / 2),
                        ),
                      ),
                    ),
                    for (int index = 1; index < widget.labels.length; index++)
                      Positioned(
                        left: _centerForIndex(index, maxWidth) - 3,
                        top: _trackTop + (_knobHeight / 2) - 3,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Positioned(
                      left: knobOffset,
                      top: _trackTop,
                      child: Image.asset(
                        ControllerAssets.strengthButton,
                        width: _knobWidth,
                        height: _knobHeight,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(widget.labels.length, (index) {
                return Expanded(
                  child: Text(
                    widget.labels[index],
                    textAlign:
                        index == 0
                            ? TextAlign.left
                            : index == widget.labels.length - 1
                            ? TextAlign.right
                            : TextAlign.center,
                    style: const TextStyle(
                      color: _labelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  void _commitDrag(int maxIndex) {
    if (_dragValue == null) {
      return;
    }
    final nextIndex = _dragValue!.round().clamp(0, maxIndex);
    setState(() {
      _dragValue = null;
    });
    widget.onChanged(nextIndex);
  }

  double _centerForIndex(int index, double width) {
    if (widget.labels.length <= 1) {
      return width / 2;
    }
    final slot = (width - _knobWidth) / (widget.labels.length - 1);
    return (_knobWidth / 2) + (slot * index);
  }

  double _offsetForValue(double value, double width) {
    if (widget.labels.length <= 1) {
      return 0;
    }
    final clampedValue = value.clamp(0, widget.labels.length - 1);
    final slot = (width - _knobWidth) / (widget.labels.length - 1);
    return slot * clampedValue;
  }

  double _valueFromOffset(double dx, double width) {
    if (widget.labels.length <= 1) {
      return 0;
    }
    final clampedOffset = dx.clamp(_knobWidth / 2, width - (_knobWidth / 2));
    final normalized =
        (clampedOffset - (_knobWidth / 2)) / (width - _knobWidth);
    return math.max(
      0,
      math.min(
        widget.labels.length - 1,
        normalized * (widget.labels.length - 1),
      ),
    );
  }
}
