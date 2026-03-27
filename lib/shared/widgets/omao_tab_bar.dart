import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

class OmaoTabBar extends StatelessWidget {
  const OmaoTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  static const _designWidth = 237.0;
  static const _designHeight = 58.0;
  static const _designItemWidth = 75.0;
  static const _designItemHeight = 46.0;
  static const _designBottomOffset = 52.0;
  static const _designSafeGap = 18.0;
  static const _selectedColor = Color(0xFF6A53A7);

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final availableWidth = math.max(0.0, MediaQuery.sizeOf(context).width - 32);
    final width = math.max(0.0, math.min(_designWidth, availableWidth));
    if (width == 0) {
      return const SizedBox.shrink();
    }
    final scale = width / _designWidth;
    final height = _designHeight * scale;
    final bottomOffset = math.max(
      _designBottomOffset * scale,
      MediaQuery.of(context).viewPadding.bottom + _designSafeGap * scale,
    );
    final selectedIndex =
        currentIndex < 0 ? 0 : (currentIndex > 2 ? 2 : currentIndex);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomOffset),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34 * scale),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 8.5 * scale,
              sigmaY: 8.5 * scale,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x82000000),
                borderRadius: BorderRadius.circular(34 * scale),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: SizedBox(
                width: width,
                height: height,
                child: Padding(
                  padding: EdgeInsets.all(5 * scale),
                  child: Row(
                    children: List.generate(3, (index) {
                      return _TabItem(
                        scale: scale,
                        index: index,
                        selected: index == selectedIndex,
                        showUnreadDot: index == 1 && unreadCount > 0,
                        onTap: () => onTap(index),
                      );
                    }),
                  ),
                ),
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
    required this.scale,
    required this.index,
    required this.selected,
    required this.showUnreadDot,
    required this.onTap,
  });

  final double scale;
  final int index;
  final bool selected;
  final bool showUnreadDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? OmaoTabBar._selectedColor : Colors.white;
    final label = switch (index) {
      1 => '消息',
      2 => '我的',
      _ => '主页',
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: OmaoTabBar._designItemWidth * scale,
        height: OmaoTabBar._designItemHeight * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      selected
                          ? Colors.white.withValues(alpha: 0.96)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(26 * scale),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TabIcon(index: index, selected: selected, color: color),
                  SizedBox(height: 2 * scale),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11.5 * scale,
                      height: 14 / 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showUnreadDot)
              Positioned(
                right: 18 * scale,
                top: 8 * scale,
                child: Container(
                  width: 8 * scale,
                  height: 8 * scale,
                  decoration: const BoxDecoration(
                    color: AppColors.unreadDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.index,
    required this.selected,
    required this.color,
  });

  final int index;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: switch (index) {
        1 => _MessageTabIcon(color: color),
        2 => _ProfileTabIcon(color: color),
        _ => _HomeTabIcon(color: color, selected: selected),
      },
    );
  }
}

class _HomeTabIcon extends StatelessWidget {
  const _HomeTabIcon({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (selected)
          Positioned(
            left: 5.8333,
            top: 5.8333,
            width: 12.5,
            height: 13.3333,
            child: SvgPicture.asset(
              _TabAssets.homeSelectedBase,
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        Positioned(
          left: 3,
          top: 3.0833,
          width: 15.1667,
          height: 15.6667,
          child: SvgPicture.asset(
            _TabAssets.homeSelectedOutline,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        Positioned(
          left: 6.6667,
          top: 6.8333,
          width: 7.63,
          height: 1.6667,
          child: SvgPicture.asset(
            _TabAssets.homeSelectedDot1,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        Positioned(
          left: 6.6667,
          top: 11,
          width: 3.3333,
          height: 1.6667,
          child: SvgPicture.asset(
            _TabAssets.homeSelectedDot2,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

class _MessageTabIcon extends StatelessWidget {
  const _MessageTabIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 2,
          top: 2,
          width: 15.0588,
          height: 15,
          child: SvgPicture.asset(
            _TabAssets.messageOutline,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        Positioned(
          left: 6,
          top: 7,
          width: 7,
          height: 1.6,
          child: SvgPicture.asset(
            _TabAssets.messageLine1,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        Positioned(
          left: 6,
          top: 10,
          width: 4,
          height: 1.6,
          child: SvgPicture.asset(
            _TabAssets.messageLine2,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

class _ProfileTabIcon extends StatelessWidget {
  const _ProfileTabIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 4.01,
          top: 1.67,
          width: 12.385,
          height: 15.292,
          child: SvgPicture.asset(
            _TabAssets.profileOutline,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        Positioned(
          left: 7.5,
          top: 5.08,
          width: 1.667,
          height: 1.667,
          child: SvgPicture.asset(
            _TabAssets.profileEye,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        Positioned(
          left: 10.83,
          top: 5.08,
          width: 1.667,
          height: 1.667,
          child: SvgPicture.asset(
            _TabAssets.profileEye,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

class _TabAssets {
  const _TabAssets._();

  static const homeSelectedBase =
      'assets/figma/components/tab_bar/home_selected_base.svg';
  static const homeSelectedDot1 =
      'assets/figma/components/tab_bar/home_selected_dot_1.svg';
  static const homeSelectedDot2 =
      'assets/figma/components/tab_bar/home_selected_dot_2.svg';
  static const homeSelectedOutline =
      'assets/figma/components/tab_bar/home_selected_outline.svg';
  static const messageLine1 =
      'assets/figma/components/tab_bar/message_line_1.svg';
  static const messageLine2 =
      'assets/figma/components/tab_bar/message_line_2.svg';
  static const messageOutline =
      'assets/figma/components/tab_bar/message_outline.svg';
  static const profileEye = 'assets/figma/components/tab_bar/profile_eye.svg';
  static const profileOutline =
      'assets/figma/components/tab_bar/profile_outline.svg';
}
