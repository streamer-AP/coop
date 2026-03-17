import 'dart:math' as math;

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

  static const _tabAssets = <String>[
    'assets/figma/home/tab_home_selected.png',
    'assets/figma/home/tab_message_selected.png',
    'assets/figma/home/tab_profile_selected.png',
  ];

  @override
  Widget build(BuildContext context) {
    final width = math.min(237.0, MediaQuery.sizeOf(context).width - 64);
    final height = width * 124 / 474;
    final bottomOffset = MediaQuery.of(context).viewPadding.bottom + 18;
    final selectedIndex =
        currentIndex < 0 ? 0 : (currentIndex > 2 ? 2 : currentIndex);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomOffset),
      child: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _tabAssets[selectedIndex],
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
                Row(
                  children: [
                    _HitZone(onTap: () => onTap(0)),
                    _HitZone(onTap: () => onTap(1)),
                    _HitZone(onTap: () => onTap(2)),
                  ],
                ),
                if (unreadCount > 0)
                  Positioned(
                    left: width * 0.53,
                    top: height * 0.2,
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
          ),
        ),
      ),
    );
  }
}

class _HitZone extends StatelessWidget {
  const _HitZone({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
    );
  }
}
