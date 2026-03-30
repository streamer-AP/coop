import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/omao_toast.dart';
import '../../../auth/application/services/verification_guard.dart';
import '../../../controller/application/providers/controller_providers.dart';
import '../../../profile/application/providers/profile_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _designWidth = 393.0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _HomeBackdrop(),
          LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = math.min(_designWidth, constraints.maxWidth);
              final scale = contentWidth / _designWidth;

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 35 * scale,
                        top: 85 * scale,
                        child: Image.asset(
                          _HomeAssets.title,
                          width: 148 * scale,
                          height: 21 * scale,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned(
                        left: 323 * scale,
                        top: 75 * scale,
                        child: _AvatarButton(
                          imageUrl: profile?.avatarUrl,
                          size: 40 * scale,
                          onTap:
                              () => context.pushNamed(RouteNames.profileEdit),
                        ),
                      ),
                      Positioned(
                        left: 30 * scale,
                        top: 198 * scale,
                        child: _HomeMenuCard(
                          scale: scale,
                          title: '沉浸播放',
                          subtitleAsset: _HomeAssets.subtitlePlayMusic,
                          subtitleWidth: 117,
                          sticker: _PlayerSticker(scale: scale),
                          onTap: () => context.pushNamed(RouteNames.resonance),
                        ),
                      ),
                      Positioned(
                        left: 30 * scale,
                        top: 311.8681640625 * scale,
                        child: _HomeMenuCard(
                          scale: scale,
                          title: '自由控制',
                          subtitleAsset: _HomeAssets.subtitleController,
                          subtitleWidth: 105,
                          sticker: _ControllerSticker(scale: scale),
                          onTap: () => context.pushNamed(RouteNames.controller),
                        ),
                      ),
                      Positioned(
                        left: 30 * scale,
                        top: 425.736328125 * scale,
                        child: _HomeMenuCard(
                          scale: scale,
                          title: '剧情体验',
                          subtitleAsset: _HomeAssets.subtitleWatchPlot,
                          subtitleWidth: 125,
                          sticker: _StorySticker(scale: scale),
                          onTap: () => _handleStoryFeature(context, ref),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleStoryFeature(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final binding = await ref.read(activeDeviceBindingProvider.future);
    if (!context.mounted) {
      return;
    }

    if (binding == null) {
      OmaoToast.show(context, '剧情体验请启用过设备后体验', isSuccess: false);
      return;
    }

    final passed = await VerificationGuard.check(context, ref);
    if (passed && context.mounted) {
      context.pushNamed(RouteNames.story);
    }
  }
}

class _HomeAssets {
  const _HomeAssets._();

  static const background = 'assets/figma/home/home_bg.png';
  static const title = 'assets/figma/home/title_omao_with_you_clean.png';
  static const avatarFallback = 'assets/figma/home/avatar_fallback.png';
  static const arrow = 'assets/figma/components/home_menu/arrow_button.svg';
  static const subtitlePlayMusic =
      'assets/figma/home/subtitle_play_music_clean.png';
  static const subtitleController =
      'assets/figma/home/subtitle_controller_clean.png';
  static const subtitleWatchPlot =
      'assets/figma/home/subtitle_watch_plot_clean.png';
  static const playerRing =
      'assets/figma/components/home_menu/player_vector_1.svg';
  static const playerMiddle =
      'assets/figma/components/home_menu/player_vector_2.svg';
  static const playerInner =
      'assets/figma/components/home_menu/player_vector_3.svg';
  static const playerNote =
      'assets/figma/components/home_menu/player_vector_4.svg';
  static const playerShine =
      'assets/figma/components/home_menu/player_note.svg';
  static const controllerBody =
      'assets/figma/components/home_menu/controller_body.svg';
  static const controllerSignal =
      'assets/figma/components/home_menu/controller_signal.svg';
  static const storyBody = 'assets/figma/components/home_menu/story_body.svg';
  static const storyStar = 'assets/figma/components/home_menu/story_star.svg';
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.min(
          HomePage._designWidth,
          constraints.maxWidth,
        );
        final scale = contentWidth / HomePage._designWidth;
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
                        _HomeAssets.background,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: -1 * scale,
                      width: HomePage._designWidth * scale,
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

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.imageUrl,
    required this.size,
    required this.onTap,
  });

  final String? imageUrl;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: ClipOval(child: _buildAvatarImage()),
      ),
    );
  }

  Widget _buildAvatarImage() {
    final value = imageUrl?.trim();
    if (value == null || value.isEmpty) {
      return _fallbackAvatar();
    }

    final localPath = _resolveLocalPath(value);
    if (localPath != null) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    }

    return Image.network(
      value,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => _fallbackAvatar(),
    );
  }

  String? _resolveLocalPath(String value) {
    if (value.startsWith('file://')) {
      final uri = Uri.tryParse(value);
      return uri?.toFilePath();
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return null;
    }

    final file = File(value);
    return file.existsSync() ? file.path : null;
  }

  Widget _fallbackAvatar() {
    return Image.asset(
      _HomeAssets.avatarFallback,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }
}

class _HomeMenuCard extends StatelessWidget {
  const _HomeMenuCard({
    required this.scale,
    required this.title,
    required this.subtitleAsset,
    required this.subtitleWidth,
    required this.sticker,
    required this.onTap,
  });

  final double scale;
  final String title;
  final String subtitleAsset;
  final double subtitleWidth;
  final Widget sticker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 333 * scale,
        height: 100 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: Colors.white, width: 1),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0x8ACDCDF0), Color(0xE6FFFFFF)],
            stops: [0.29429, 0.61862],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: 20 * scale, top: 11 * scale, child: sticker),
            Positioned(
              left: 123 * scale,
              top: 27 * scale,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16 * scale,
                  height: 22 / 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              left: 122 * scale,
              top: 52 * scale,
              child: Image.asset(
                subtitleAsset,
                width: subtitleWidth * scale,
                height: 21 * scale,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              left: 278 * scale,
              top: 33 * scale,
              width: 32 * scale,
              height: 32 * scale,
              child: SvgPicture.asset(_HomeAssets.arrow, fit: BoxFit.fill),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerSticker extends StatelessWidget {
  const _PlayerSticker({required this.scale});

  static const _rotation = -39.3 * math.pi / 180;

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80 * scale,
      height: 80 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ring (outer) – rotated bounding box centered at (39.1, 41.4)
          Positioned(
            left: -4.4 * scale,
            top: -0.5 * scale,
            width: 87.0 * scale,
            height: 83.9 * scale,
            child: Transform.rotate(
              angle: _rotation,
              child: Center(
                child: SizedBox(
                  width: 71.6936 * scale,
                  height: 49.7466 * scale,
                  child: SvgPicture.asset(
                    _HomeAssets.playerRing,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          // Middle ring – same center
          Positioned(
            left: 3.8 * scale,
            top: 7.4 * scale,
            width: 70.6 * scale,
            height: 68.1 * scale,
            child: Transform.rotate(
              angle: _rotation,
              child: Center(
                child: SizedBox(
                  width: 58.1622 * scale,
                  height: 40.3575 * scale,
                  child: SvgPicture.asset(
                    _HomeAssets.playerMiddle,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          // Inner ring – same center
          Positioned(
            left: 12.9 * scale,
            top: 16.1 * scale,
            width: 52.4 * scale,
            height: 50.6 * scale,
            child: Transform.rotate(
              angle: _rotation,
              child: Center(
                child: SizedBox(
                  width: 43.2171 * scale,
                  height: 29.9913 * scale,
                  child: SvgPicture.asset(
                    _HomeAssets.playerInner,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          // Music note (not rotated)
          Positioned(
            left: 29.6 * scale,
            top: 14 * scale,
            width: 43.4582 * scale,
            height: 36.1349 * scale,
            child: SvgPicture.asset(_HomeAssets.playerNote, fit: BoxFit.fill),
          ),
          // Shine note icon (not rotated)
          Positioned(
            left: 9 * scale,
            top: 12 * scale,
            width: 15.2 * scale,
            height: 16.4 * scale,
            child: SvgPicture.asset(_HomeAssets.playerShine, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}

class _ControllerSticker extends StatelessWidget {
  const _ControllerSticker({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80 * scale,
      height: 80 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 3.33 * scale,
            top: 15.57 * scale,
            width: 74 * scale,
            height: 47.9693 * scale,
            child: SvgPicture.asset(
              _HomeAssets.controllerBody,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 13 * scale,
            top: 13 * scale,
            width: 12 * scale,
            height: 8 * scale,
            child: SvgPicture.asset(
              _HomeAssets.controllerSignal,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}

class _StorySticker extends StatelessWidget {
  const _StorySticker({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80 * scale,
      height: 80 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 3.33 * scale,
            top: 15.57 * scale,
            width: 74 * scale,
            height: 47.9693 * scale,
            child: SvgPicture.asset(_HomeAssets.storyBody, fit: BoxFit.fill),
          ),
          Positioned(
            left: 7 * scale,
            top: 8 * scale,
            width: 9 * scale,
            height: 10 * scale,
            child: SvgPicture.asset(_HomeAssets.storyStar, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
