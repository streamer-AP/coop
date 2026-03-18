import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/application/services/verification_guard.dart';
import '../../../profile/application/providers/profile_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _HomeBackdrop(),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 393),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewPadding.bottom + 136,
                  ),
                  child: Column(
                    children: [
                      _HomeHeader(
                        avatarUrl: profile?.avatarUrl,
                        onAvatarTap:
                            () => context.pushNamed(RouteNames.profileEdit),
                      ),
                      const SizedBox(height: 98),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            _FeatureCard(
                              iconAsset: _HomeAssets.stickerPlayer,
                              title: '沉浸播放',
                              subtitleAsset: _HomeAssets.subtitlePlayMusic,
                              onTap:
                                  () => context.pushNamed(RouteNames.resonance),
                            ),
                            const SizedBox(height: 14),
                            _FeatureCard(
                              iconAsset: _HomeAssets.stickerController,
                              title: '自由控制',
                              subtitleAsset: _HomeAssets.subtitleController,
                              onTap:
                                  () => _handleProtectedFeature(
                                    context,
                                    ref,
                                    RouteNames.controller,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            _FeatureCard(
                              iconAsset: _HomeAssets.stickerStory,
                              title: '剧情体验',
                              subtitleAsset: _HomeAssets.subtitleWatchPlot,
                              onTap:
                                  () => _handleProtectedFeature(
                                    context,
                                    ref,
                                    RouteNames.story,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleProtectedFeature(
    BuildContext context,
    WidgetRef ref,
    String routeName,
  ) async {
    final passed = await VerificationGuard.check(context, ref);
    if (passed && context.mounted) {
      context.pushNamed(routeName);
    }
  }
}

class _HomeAssets {
  const _HomeAssets._();

  static const background = 'assets/figma/home/home_bg.png';
  static const avatarFallback = 'assets/figma/home/avatar_fallback.png';
  static const arrow = 'assets/figma/home/home_arrow.svg';
  static const stickerPlayer = 'assets/figma/home/sticker_player.svg';
  static const stickerController = 'assets/figma/home/sticker_controller.svg';
  static const stickerStory = 'assets/figma/home/sticker_story.svg';
  static const titleOmaoWithYou = 'assets/figma/home/title_omao_with_you.png';
  static const subtitlePlayMusic = 'assets/figma/home/subtitle_play_music.png';
  static const subtitleController = 'assets/figma/home/subtitle_controller.png';
  static const subtitleWatchPlot = 'assets/figma/home/subtitle_watch_plot.png';
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: Image(
            image: AssetImage(_HomeAssets.background),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF28307C).withValues(alpha: 0.18),
                  const Color(0xFFAEB4DF).withValues(alpha: 0.05),
                  const Color(0xFFE7EAFF).withValues(alpha: 0.24),
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.avatarUrl, required this.onAvatarTap});

  final String? avatarUrl;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(35, 16, 30, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  _HomeAssets.titleOmaoWithYou,
                  width: 160,
                  height: 22,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          _AvatarButton(imageUrl: avatarUrl, onTap: onAvatarTap),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.imageUrl, required this.onTap});

  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.78),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(child: _buildAvatarImage()),
      ),
    );
  }

  Widget _buildAvatarImage() {
    final value = imageUrl?.trim();
    if (value == null || value.isEmpty) return _fallbackAvatar();

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
      if (uri == null) return null;
      return uri.toFilePath();
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.iconAsset,
    required this.title,
    required this.subtitleAsset,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitleAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 100,
          padding: const EdgeInsets.fromLTRB(20, 10, 18, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                const Color(0xFFCFCDEB).withValues(alpha: 0.56),
                Colors.white.withValues(alpha: 0.92),
              ],
              stops: const [0.0, 0.62],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Image.asset(
                      subtitleAsset,
                      width: 125,
                      height: 22,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const _ArrowButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi,
      child: SvgPicture.asset(_HomeAssets.arrow, width: 32, height: 32),
    );
  }
}
