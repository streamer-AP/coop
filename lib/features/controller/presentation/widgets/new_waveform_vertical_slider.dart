import 'package:flutter/material.dart';

import '../../controller_assets.dart';

class NewWaveformVerticalSlider extends StatelessWidget {
  const NewWaveformVerticalSlider({
    required this.index,
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final int index;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  static const _minValue = 0.0;
  static const _maxValue = 100.0;
  static const _thumbSize = 28.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: enabled
                    ? (details) => _updateFromLocalY(
                          details.localPosition.dy,
                          constraints.maxHeight,
                        )
                    : null,
                onVerticalDragStart: enabled
                    ? (details) => _updateFromLocalY(
                          details.localPosition.dy,
                          constraints.maxHeight,
                        )
                    : null,
                onVerticalDragUpdate: enabled
                    ? (details) => _updateFromLocalY(
                          details.localPosition.dy,
                          constraints.maxHeight,
                        )
                    : null,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: enabled
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.14),
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    width: 0.7,
                                  ),
                                  right: BorderSide(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    width: 0.7,
                                  ),
                                ),
                              ),
                              child: Stack(
                                children: List.generate(5, (gridIndex) {
                                  final top = gridIndex / 4 * constraints.maxHeight;
                                  return Positioned(
                                    top: top,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 1,
                                      color: Colors.black.withValues(alpha: 0.04),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${index + 1}s',
                            style: TextStyle(
                              color: enabled
                                  ? const Color(0xFF9A9A9A)
                                  : const Color(0xFFAFAFB7),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _thumbTop(constraints.maxHeight),
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: enabled ? 1 : 0.42,
                          child: Image.asset(
                            ControllerAssets.waveformSlider,
                            width: _thumbSize,
                            height: _thumbSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double _thumbTop(double maxHeight) {
    final usableHeight = (maxHeight - _thumbSize).clamp(0.0, double.infinity);
    final normalized = (value.clamp(0, 100)) / _maxValue;
    return (1 - normalized) * usableHeight;
  }

  void _updateFromLocalY(double localY, double height) {
    final usableHeight = (height - _thumbSize).clamp(1.0, double.infinity);
    final normalized = 1 - (localY / usableHeight).clamp(0.0, 1.0);
    final nextValue = ((_minValue + normalized * _maxValue).round())
        .clamp(0, 100);
    onChanged(nextValue);
  }
}
