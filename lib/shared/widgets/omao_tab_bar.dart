import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class OmaoTabBar extends StatelessWidget {
  const OmaoTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final width = math.min(237.0, MediaQuery.sizeOf(context).width - 48);
    final bottomOffset = MediaQuery.of(context).viewPadding.bottom + 18;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomOffset),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: width,
              height: 62,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _TabItem(
                    kind: _TabIconKind.home,
                    label: '主页',
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _TabItem(
                    kind: _TabIconKind.messages,
                    label: '消息',
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                    badgeCount: unreadCount,
                  ),
                  _TabItem(
                    kind: _TabIconKind.profile,
                    label: '我的',
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.kind,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final _TabIconKind kind;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF6A53A7);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _TabGlyph(
                      kind: kind,
                      color: isSelected ? activeColor : Colors.white,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -4,
                        top: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.unreadDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? activeColor : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _TabIconKind { home, messages, profile }

class _TabGlyph extends StatelessWidget {
  const _TabGlyph({required this.kind, required this.color});

  final _TabIconKind kind;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _TabGlyphPainter(kind, color)),
    );
  }
}

class _TabGlyphPainter extends CustomPainter {
  const _TabGlyphPainter(this.kind, this.color);

  final _TabIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (kind) {
      case _TabIconKind.home:
        _paintHome(canvas, stroke, fill);
      case _TabIconKind.messages:
        _paintMessages(canvas, stroke);
      case _TabIconKind.profile:
        _paintProfile(canvas, stroke);
    }
  }

  void _paintHome(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.2, 3.6, 11.6, 12.8),
        const Radius.circular(2.8),
      ),
      stroke,
    );
    canvas.drawLine(const Offset(7.2, 7.2), const Offset(12.8, 7.2), stroke);
    canvas.drawLine(const Offset(7.2, 10.1), const Offset(11.5, 10.1), stroke);
    canvas.drawLine(const Offset(7.2, 13), const Offset(9.9, 13), stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(11.9, 3.7, 3.4, 3.4),
        const Radius.circular(1.2),
      ),
      fill,
    );
  }

  void _paintMessages(Canvas canvas, Paint stroke) {
    canvas.drawOval(const Rect.fromLTWH(4.3, 4.6, 11.4, 10.5), stroke);
    canvas.drawLine(const Offset(7.2, 9.2), const Offset(12.8, 9.2), stroke);
    canvas.drawLine(const Offset(7.2, 11.8), const Offset(10.6, 11.8), stroke);
    canvas.drawLine(const Offset(8.4, 15), const Offset(6.6, 17), stroke);
  }

  void _paintProfile(Canvas canvas, Paint stroke) {
    canvas.drawOval(const Rect.fromLTWH(6.2, 4.1, 7.6, 7.2), stroke);
    canvas.drawArc(
      const Rect.fromLTWH(4.6, 9.6, 10.8, 6.4),
      3.3,
      2.8,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TabGlyphPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.color != color;
  }
}
