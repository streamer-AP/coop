import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../controller_assets.dart';

class NewWaveformEditorCard extends StatelessWidget {
  const NewWaveformEditorCard({
    required this.pageIndex,
    required this.isEnabled,
    required this.values,
    required this.onToggleEnabled,
    required this.onReset,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onValueChanged,
    super.key,
  });

  final int pageIndex;
  final bool isEnabled;
  final List<int> values;
  final VoidCallback onToggleEnabled;
  final VoidCallback onReset;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final void Function(int index, int value) onValueChanged;

  bool get _showToggleButton => pageIndex > 0;
  bool get _canGoNext => pageIndex < 3 && isEnabled;
  bool get _canGoPrevious => pageIndex > 0;

  void _updateValueFromLocalY(
    int index,
    double localY,
    double height,
  ) {
    const plotTop = 16.0;
    const plotBottomPadding = 18.0;
    final plotHeight = math.max(1.0, height - plotTop - plotBottomPadding);
    final normalized = 1 - ((localY - plotTop) / plotHeight).clamp(0.0, 1.0);
    final nextValue = (normalized * 100).round().clamp(0, 100);
    onValueChanged(index, nextValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 425,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 6),
              child: SizedBox(
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 74,
                        child: _showToggleButton
                            ? _ToggleButton(
                                enabled: isEnabled,
                                onTap: onToggleEnabled,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const Text(
                      '波形编辑',
                      style: TextStyle(
                        color: Color(0xFF797979),
                        fontSize: 16,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _ResetButton(onTap: onReset),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 14),
              child: SizedBox(
                height: 300,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const labelHeight = 28.0;
                    const plotTop = 16.0;
                    const plotBottomPadding = 18.0;
                    const chartHorizontalInset = 25.0;
                    const markerSize = 28.0;
                    const markerRadius = markerSize / 2;

                    final chartHeight = constraints.maxHeight - labelHeight;
                    final axisY = chartHeight - plotBottomPadding;
                    final plotHeight = math.max(1.0, axisY - plotTop);
                    final chartWidth = math.max(
                      1.0,
                      constraints.maxWidth - chartHorizontalInset * 2,
                    );
                    final segmentWidth = values.length > 1
                        ? chartWidth / (values.length - 1)
                        : chartWidth;
                    final majorXs = List<double>.generate(values.length, (index) {
                      return values.length > 1
                          ? chartHorizontalInset + segmentWidth * index
                          : constraints.maxWidth / 2;
                    });
                    final points = List<Offset>.generate(values.length, (index) {
                      final x = majorXs[index];
                      final normalized = values[index].clamp(0, 100) / 100.0;
                      final y = plotTop + (1 - normalized) * plotHeight;
                      return Offset(x, y);
                    });

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          bottom: labelHeight,
                          child: CustomPaint(
                            painter: _NewWaveformChartPainter(
                              points: points,
                              majorXs: majorXs,
                              axisY: axisY,
                              plotTop: plotTop,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          bottom: labelHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(values.length, (index) {
                              return Expanded(
                                child: LayoutBuilder(
                                  builder: (context, segmentConstraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTapDown: isEnabled
                                          ? (details) => _updateValueFromLocalY(
                                                index,
                                                details.localPosition.dy,
                                                segmentConstraints.maxHeight,
                                              )
                                          : null,
                                      onVerticalDragStart: isEnabled
                                          ? (details) => _updateValueFromLocalY(
                                                index,
                                                details.localPosition.dy,
                                                segmentConstraints.maxHeight,
                                              )
                                          : null,
                                      onVerticalDragUpdate: isEnabled
                                          ? (details) => _updateValueFromLocalY(
                                                index,
                                                details.localPosition.dy,
                                                segmentConstraints.maxHeight,
                                              )
                                          : null,
                                      child: const SizedBox.expand(),
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                        ...List.generate(values.length, (index) {
                          final x = majorXs[index];
                          final normalized = values[index].clamp(0, 100) / 100.0;
                          final y = plotTop + (1 - normalized) * plotHeight;
                          return Positioned(
                            left: x - markerRadius,
                            top: y - markerRadius,
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 160),
                                opacity: isEnabled ? 1 : 0.42,
                                child: Image.asset(
                                  ControllerAssets.waveformSlider,
                                  width: markerSize,
                                  height: markerSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: labelHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: List.generate(values.length, (index) {
                              final x = majorXs[index];
                              return Positioned(
                                left: x - 18,
                                top: 0,
                                width: 36,
                                height: labelHeight,
                                child: Center(
                                  child: Text(
                                    '${pageIndex * values.length + index + 1}s',
                                    style: TextStyle(
                                      color: isEnabled
                                          ? const Color(0xFF9A9A9A)
                                          : const Color(0xFFAFAFB7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        if (!isEnabled)
                          Positioned.fill(
                            bottom: labelHeight,
                            child: Container(
                              color: const Color(0x66C9BDE5),
                              child: Center(
                                child: _EnableButton(onTap: onToggleEnabled),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                children: [
                  _ArrowButton(
                    icon: Icons.chevron_left_rounded,
                    enabled: _canGoPrevious,
                    onTap: onPreviousPage,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE8FD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${pageIndex * 8 + 1}s~${pageIndex * 8 + 8}s',
                      style: const TextStyle(
                        color: Color(0xFF8B77C8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _ArrowButton(
                    icon: Icons.chevron_right_rounded,
                    enabled: _canGoNext,
                    onTap: onNextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewWaveformChartPainter extends CustomPainter {
  const _NewWaveformChartPainter({
    required this.points,
    required this.majorXs,
    required this.axisY,
    required this.plotTop,
  });

  final List<Offset> points;
  final List<double> majorXs;
  final double axisY;
  final double plotTop;

  static const _gridColor = Color(0xFFD9D9D9);
  static const _lineColor = Color(0xFF8C7ABF);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final yAxisPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _gridColor.withValues(alpha: 0.3);

    final xAxisPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _gridColor.withValues(alpha: 0.15);

    final smallDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _gridColor.withValues(alpha: 0.3);

    final largeDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _gridColor.withValues(alpha: 0.3);

    final horizontalLeft = majorXs.isNotEmpty ? majorXs.first : 0.0;
    final horizontalRight = majorXs.isNotEmpty ? majorXs.last : size.width;
    final horizontalWidth = math.max(1.0, horizontalRight - horizontalLeft);

    // 5 条均匀分布的横向实线，底部基线单独绘制。
    for (var index = 0; index < 5; index++) {
      final y = plotTop + (axisY - plotTop) * index / 5;
      canvas.drawRect(
        Rect.fromLTWH(horizontalLeft, y - 0.5, horizontalWidth, 1),
        xAxisPaint,
      );
    }

    for (final x in majorXs) {
      canvas.drawRect(
        Rect.fromLTWH(x - 2, plotTop, 4, axisY - plotTop),
        yAxisPaint,
      );
    }

    final dotStep = majorXs.length > 1 ? (majorXs[1] - majorXs[0]) / 4 : size.width / 4;
    final firstDotX = majorXs.isNotEmpty ? majorXs.first + dotStep / 2 : dotStep / 2;
    final lastDotX = majorXs.isNotEmpty ? majorXs.last : size.width;
    for (double x = firstDotX; x <= lastDotX; x += dotStep) {
      final isMajor = majorXs.any(
        (majorX) => (majorX - x).abs() < dotStep * 0.45,
      );
      if (!isMajor) {
        canvas.drawCircle(Offset(x, axisY), 2, smallDotPaint);
      }
    }

    for (final x in majorXs) {
      canvas.drawCircle(Offset(x, axisY), 4, largeDotPaint);
    }

    canvas.drawRect(
      Rect.fromLTWH(horizontalLeft, axisY - 0.5, horizontalWidth, 1),
      xAxisPaint,
    );

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 0; index < points.length - 1; index++) {
      final current = points[index];
      final next = points[index + 1];

      if ((current.dy - next.dy).abs() < 0.5) {
        path.lineTo(next.dx, next.dy);
        continue;
      }

      final dx = next.dx - current.dx;
      final dy = next.dy - current.dy;
      final radius = math.min(10.0, math.min(dx / 4, dy.abs() / 2));
      final midX = (current.dx + next.dx) / 2;
      final direction = dy > 0 ? 1.0 : -1.0;

      path.lineTo(midX - radius, current.dy);
      path.quadraticBezierTo(
        midX,
        current.dy,
        midX,
        current.dy + direction * radius,
      );
      path.lineTo(midX, next.dy - direction * radius);
      path.quadraticBezierTo(
        midX,
        next.dy,
        midX + radius,
        next.dy,
      );
      path.lineTo(next.dx, next.dy);
    }

    final linePaint = Paint()
      ..color = _lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _NewWaveformChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.axisY != axisY ||
        oldDelegate.plotTop != plotTop;
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF8B77C8);
    final inactiveColor = AppColors.textHint;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_circle_outline_rounded,
            size: 16,
            color: enabled ? activeColor : const Color(0xFFBFBFC7),
          ),
          const SizedBox(width: 4),
          Text(
            '停用',
            style: TextStyle(
              color: enabled ? activeColor : inactiveColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restart_alt_rounded,
            size: 18,
            color: Color(0xFF8B77C8),
          ),
          SizedBox(width: 4),
          Text(
            '重置',
            style: TextStyle(
              color: Color(0xFF8B77C8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnableButton extends StatelessWidget {
  const _EnableButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE7DDFB)),
          ),
          child: const Text(
            '启用',
            style: TextStyle(
              color: Color(0xFF8B77C8),
              fontSize: 15,
              
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF8B77C8) : const Color(0xFFD1CFE3);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: 30,
        color: color,
      ),
    );
  }
}
