import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    bottom: MediaQuery.of(context).viewPadding.bottom + 140,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HomeHeader(
                        avatarUrl: profile?.avatarUrl,
                        onAvatarTap:
                            () => context.pushNamed(RouteNames.profileEdit),
                      ),
                      const SizedBox(height: 82),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            _FeatureCard(
                              artwork: _FeatureArtworkKind.player,
                              title: '沉浸播放',
                              subtitle: 'Play music',
                              onTap:
                                  () => context.pushNamed(RouteNames.resonance),
                            ),
                            const SizedBox(height: 14),
                            _FeatureCard(
                              artwork: _FeatureArtworkKind.controller,
                              title: '自由控制',
                              subtitle: 'Controller',
                              onTap:
                                  () => _handleProtectedFeature(
                                    context,
                                    ref,
                                    RouteNames.controller,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            _FeatureCard(
                              artwork: _FeatureArtworkKind.story,
                              title: '剧情体验',
                              subtitle: 'Watch plot',
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

  void _handleProtectedFeature(
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
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'OMAO WITH YOU',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.3),
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
            color: Colors.white.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child:
              imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackAvatar(),
                  )
                  : _fallbackAvatar(),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE2C0), Color(0xFF7E5E5C)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 20,
          color: Colors.white.withValues(alpha: 0.86),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.artwork,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final _FeatureArtworkKind artwork;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 100,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xE6FFFFFF), Color(0x8ACDCDF0)],
                  stops: [0.38, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.04),
                              Colors.white.withValues(alpha: 0.16),
                            ],
                            stops: const [0, 0.44, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _FeatureArtwork(kind: artwork),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.92),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.3,
                                height: 1,
                                color: const Color(
                                  0xFF7F6BC2,
                                ).withValues(alpha: 0.34),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const _ArrowButton(),
                    ],
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

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC9C2EA), Color(0xFFA79CD5)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.18),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

enum _FeatureArtworkKind { player, controller, story }

class _FeatureArtwork extends StatelessWidget {
  const _FeatureArtwork({required this.kind});

  final _FeatureArtworkKind kind;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: _FeatureArtworkPainter(kind)),
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(color: Color(0xFFEAEAEA))),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x5C28307C),
                Color(0x332B367E),
                Color(0x14C8CFEA),
                Color(0x5CE7EAFF),
              ],
              stops: [0.04, 0.3, 0.6, 1],
            ),
          ),
        ),
        _BlurOrb(
          alignment: Alignment.topCenter,
          width: 220,
          height: 170,
          color: Colors.white.withValues(alpha: 0.34),
          blur: 78,
        ),
        _BlurOrb(
          alignment: const Alignment(0, -0.16),
          width: 124,
          height: 360,
          color: Colors.white.withValues(alpha: 0.26),
          blur: 72,
        ),
        _BlurOrb(
          alignment: const Alignment(-0.92, 0.68),
          width: 220,
          height: 120,
          color: Colors.white.withValues(alpha: 0.24),
          blur: 72,
        ),
        _BlurOrb(
          alignment: const Alignment(0.92, 0.7),
          width: 220,
          height: 120,
          color: Colors.white.withValues(alpha: 0.2),
          blur: 72,
        ),
        _BlurOrb(
          alignment: const Alignment(0.12, 0.46),
          width: 300,
          height: 300,
          color: const Color(0xFFC6C0E3).withValues(alpha: 0.2),
          blur: 86,
        ),
        Positioned(
          left: -20,
          right: -20,
          bottom: 98,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              height: 206,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(220),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
                  width: 14,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 74,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.38),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.12),
                  radius: 0.95,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0.05, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _DustPainter())),
        ),
      ],
    );
  }
}

class _FeatureArtworkPainter extends CustomPainter {
  const _FeatureArtworkPainter(this.kind);

  final _FeatureArtworkKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case _FeatureArtworkKind.player:
        _paintPlayer(canvas, size);
      case _FeatureArtworkKind.controller:
        _paintController(canvas, size);
      case _FeatureArtworkKind.story:
        _paintStory(canvas, size);
    }
  }

  void _paintPlayer(Canvas canvas, Size size) {
    const bodyColor = Color(0xFF4A405A);
    const shadowColor = Color(0xFF625973);
    const accentColor = Color(0xFFE8DAFF);

    final bodyPaint = Paint()..color = bodyColor;
    final rimPaint =
        Paint()
          ..color = shadowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
    final accentPaint = Paint()..color = accentColor;

    canvas.save();
    _rotateAroundCenter(canvas, size, -0.68);

    final center = Offset(size.width * 0.48, size.height * 0.56);
    final outerRing =
        Path()..addOval(Rect.fromCenter(center: center, width: 58, height: 42));
    final innerRing =
        Path()..addOval(Rect.fromCenter(center: center, width: 34, height: 24));
    final ring = Path.combine(PathOperation.difference, outerRing, innerRing);
    canvas.drawPath(ring, bodyPaint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 18, height: 12),
      Paint()..color = shadowColor,
    );
    canvas.drawArc(
      Rect.fromCenter(center: center.translate(-1, -1), width: 50, height: 34),
      -1.1,
      2.45,
      false,
      rimPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + 7, center.dy - 4)
        ..lineTo(center.dx + 18, center.dy + 2)
        ..lineTo(center.dx + 7, center.dy + 10)
        ..close(),
      accentPaint,
    );

    canvas.restore();

    final noteStem =
        Paint()
          ..color = accentColor
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(16, 22), 3.2, accentPaint);
    canvas.drawCircle(const Offset(22, 20), 2.6, accentPaint);
    canvas.drawLine(const Offset(18.6, 20.5), const Offset(18.6, 10), noteStem);
    canvas.drawLine(const Offset(18.6, 10), const Offset(26.8, 12.6), noteStem);
    canvas.drawLine(
      const Offset(24.8, 12.1),
      const Offset(24.8, 18.2),
      noteStem,
    );
    canvas.drawArc(
      const Rect.fromLTWH(10, 8, 14, 10),
      0.35,
      1.1,
      false,
      Paint()
        ..color = accentColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _paintController(Canvas canvas, Size size) {
    const bodyColor = Color(0xFF4A405A);
    const accentColor = Color(0xFFE7DAFF);
    const detailColor = Color(0xFF655B78);

    final bodyPaint = Paint()..color = bodyColor;
    final detailPaint = Paint()..color = detailColor;
    final accentPaint = Paint()..color = accentColor;

    canvas.save();
    _rotateAroundCenter(canvas, size, -0.08);

    final body =
        Path()
          ..moveTo(8, 44)
          ..cubicTo(10, 31, 22, 28, 30, 33)
          ..lineTo(50, 33)
          ..cubicTo(58, 28, 70, 31, 72, 44)
          ..cubicTo(73.2, 55, 66, 60, 59, 58)
          ..cubicTo(54, 56.5, 51.5, 50.5, 46.5, 50.5)
          ..lineTo(33.5, 50.5)
          ..cubicTo(28.5, 50.5, 26, 56.5, 21, 58)
          ..cubicTo(14, 60, 6.8, 55, 8, 44)
          ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawCircle(const Offset(28, 43), 3.2, detailPaint);
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(21, 43), width: 10, height: 3),
      detailPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(21, 43), width: 3, height: 10),
      detailPaint,
    );
    canvas.drawCircle(const Offset(56.5, 40.5), 2.8, accentPaint);
    canvas.drawCircle(
      const Offset(62, 46),
      2.4,
      Paint()..color = accentColor.withValues(alpha: 0.78),
    );
    canvas.drawCircle(
      const Offset(52, 47),
      2.2,
      Paint()..color = accentColor.withValues(alpha: 0.62),
    );

    canvas.restore();

    final wavePaint =
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(13, 10, 12, 10),
      -0.3,
      1.2,
      false,
      wavePaint,
    );
    canvas.drawArc(
      const Rect.fromLTWH(10, 7, 18, 15),
      -0.35,
      1.15,
      false,
      wavePaint..strokeWidth = 1.3,
    );
  }

  void _paintStory(Canvas canvas, Size size) {
    const bodyColor = Color(0xFF4A405A);
    const accentColor = Color(0xFFE9DDFF);
    const cutoutColor = Color(0xFFF4F1FB);

    final bodyPaint = Paint()..color = bodyColor;
    final cutoutPaint = Paint()..color = cutoutColor;
    final accentPaint = Paint()..color = accentColor;

    canvas.save();
    _rotateAroundCenter(canvas, size, -0.18);

    final filmFrame = RRect.fromRectAndRadius(
      const Rect.fromLTWH(15, 25, 48, 34),
      const Radius.circular(5),
    );
    canvas.drawRRect(filmFrame, bodyPaint);

    for (final dy in [30.0, 39.0, 48.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(18, dy, 4, 4),
          const Radius.circular(1.4),
        ),
        cutoutPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(56, dy, 4, 4),
          const Radius.circular(1.4),
        ),
        cutoutPaint,
      );
    }

    canvas.drawPath(
      Path()
        ..moveTo(33, 33)
        ..lineTo(46, 41.5)
        ..lineTo(33, 50)
        ..close(),
      accentPaint,
    );
    canvas.drawLine(
      const Offset(26, 28),
      const Offset(52, 56),
      Paint()
        ..color = accentColor.withValues(alpha: 0.28)
        ..strokeWidth = 1.4,
    );
    canvas.restore();

    _drawSparkle(canvas, const Offset(14, 18), 4.8);
  }

  void _rotateAroundCenter(Canvas canvas, Size size, double angle) {
    final center = size.center(Offset.zero);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius) {
    final sparklePaint =
        Paint()
          ..color = const Color(0xFFE8DAFF)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.alignment,
    required this.width,
    required this.height,
    required this.color,
    required this.blur,
  });

  final Alignment alignment;
  final double width;
  final double height;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width),
          ),
        ),
      ),
    );
  }
}

class _DustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.26);

    final glowDots = <Offset>[
      Offset(size.width * 0.14, size.height * 0.09),
      Offset(size.width * 0.68, size.height * 0.12),
      Offset(size.width * 0.88, size.height * 0.36),
      Offset(size.width * 0.20, size.height * 0.52),
      Offset(size.width * 0.74, size.height * 0.60),
    ];

    for (final dot in glowDots) {
      canvas.drawCircle(dot, 2.2, glowPaint);
    }

    final dots = <Offset>[
      Offset(size.width * 0.12, size.height * 0.18),
      Offset(size.width * 0.24, size.height * 0.08),
      Offset(size.width * 0.42, size.height * 0.06),
      Offset(size.width * 0.56, size.height * 0.17),
      Offset(size.width * 0.78, size.height * 0.08),
      Offset(size.width * 0.87, size.height * 0.15),
      Offset(size.width * 0.91, size.height * 0.27),
      Offset(size.width * 0.07, size.height * 0.35),
      Offset(size.width * 0.16, size.height * 0.42),
      Offset(size.width * 0.70, size.height * 0.39),
      Offset(size.width * 0.84, size.height * 0.45),
      Offset(size.width * 0.08, size.height * 0.64),
      Offset(size.width * 0.24, size.height * 0.58),
      Offset(size.width * 0.52, size.height * 0.68),
      Offset(size.width * 0.75, size.height * 0.74),
      Offset(size.width * 0.90, size.height * 0.66),
      Offset(size.width * 0.17, size.height * 0.82),
      Offset(size.width * 0.46, size.height * 0.88),
      Offset(size.width * 0.64, size.height * 0.90),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, 1.1, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
