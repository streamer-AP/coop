import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class OmaoPageBackground extends StatelessWidget {
  const OmaoPageBackground({super.key, required this.child});

  static const _designWidth = 393.0;
  static const _backgroundAsset = 'assets/figma/home/home_bg.png';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        fit: StackFit.expand,
        children: [const _OmaoBackdrop(), child],
      ),
    );
  }
}

class _OmaoBackdrop extends StatelessWidget {
  const _OmaoBackdrop();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.min(
          OmaoPageBackground._designWidth,
          constraints.maxWidth,
        );
        final scale = contentWidth / OmaoPageBackground._designWidth;
        final backgroundHeight = math.max(
          874 * scale,
          constraints.maxHeight + 24 * scale,
        );
        final overlayHeight = math.max(
          857 * scale,
          constraints.maxHeight + 2 * scale,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.background),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -48 * scale,
                      top: -10 * scale,
                      width: 490 * scale,
                      height: backgroundHeight,
                      child: Image.asset(
                        OmaoPageBackground._backgroundAsset,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: -1 * scale,
                      width: OmaoPageBackground._designWidth * scale,
                      height: overlayHeight,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: 0.5 * scale,
                            sigmaY: 0.5 * scale,
                          ),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x5C28307C), Color(0x5CE7EAFF)],
                                stops: [0.10659, 0.69387],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Figma Rectangle 9292: white translucent overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFCCCCF0).withValues(alpha: 0.2),
                              const Color(0xFFFFFFFF),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
