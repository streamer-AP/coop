import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/platform/native_bridge.dart';
import '../../../../core/router/route_names.dart';
import '../../application/providers/auth_providers.dart';

enum _StartupPhase {
  intro,
  startup,
  resourcePrompt,
  resourceDownloading,
  loading,
}

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen>
    with SingleTickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 900);
  static const _showLoadingLabelAfter = Duration(milliseconds: 650);
  static const _finalHoldDuration = Duration(milliseconds: 420);

  // Placeholder until real resource-detection logic is wired in.
  static const _needsResourceDownload = false;

  late final AnimationController _ambientController;
  final NativeBridge _nativeBridge = NativeBridge();

  ProviderSubscription<AsyncValue<dynamic>>? _authSubscription;
  Timer? _introTimer;
  Timer? _loadingLabelTimer;

  _StartupPhase _phase = _StartupPhase.intro;
  double _progress = 0;
  double _resourceProgress = 0.75;
  bool _authReady = false;
  bool _unityReady = false;
  bool _introPassed = false;
  bool _initializationComplete = false;
  bool _isFinalizing = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final authState = ref.read(authNotifierProvider);
    _authReady = !authState.isLoading;
    _authSubscription = ref.listenManual<AsyncValue<dynamic>>(
      authNotifierProvider,
      (_, next) {
        if (!next.isLoading) {
          _authReady = true;
          unawaited(_checkInitializationCompletion());
        }
      },
    );

    _introTimer = Timer(_introDuration, () {
      if (!mounted) return;
      _introPassed = true;
      if (_phase == _StartupPhase.intro) {
        setState(() {
          _phase = _StartupPhase.startup;
          _progress = 0.26;
        });
      }
      _scheduleLoadingLabel();
      unawaited(_maybeAdvanceFlow());
    });

    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _loadingLabelTimer?.cancel();
    _authSubscription?.close();
    _ambientController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _prepareUnity();
    _unityReady = true;
    await _checkInitializationCompletion();
  }

  Future<void> _prepareUnity() async {
    try {
      await _nativeBridge.initUnityEngine();
    } catch (error, stackTrace) {
      AppLogger().warning('Unity init failed during app startup.');
      AppLogger().error(
        'Unity init exception',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _checkInitializationCompletion() async {
    if (!mounted || _initializationComplete || !_authReady || !_unityReady) {
      return;
    }

    _initializationComplete = true;
    await _maybeAdvanceFlow();
  }

  void _scheduleLoadingLabel() {
    _loadingLabelTimer?.cancel();
    _loadingLabelTimer = Timer(_showLoadingLabelAfter, () {
      if (!mounted ||
          _initializationComplete ||
          _phase != _StartupPhase.startup) {
        return;
      }
      setState(() {
        _phase = _StartupPhase.loading;
        _progress = math.max(_progress, 0.38);
      });
    });
  }

  Future<void> _maybeAdvanceFlow() async {
    if (!_introPassed || _hasNavigated || _isFinalizing || !mounted) {
      return;
    }

    if (_needsResourceDownload &&
        _phase != _StartupPhase.resourcePrompt &&
        _phase != _StartupPhase.resourceDownloading) {
      setState(() {
        _phase = _StartupPhase.resourcePrompt;
      });
      return;
    }

    if (!_initializationComplete) {
      return;
    }

    _isFinalizing = true;
    if (_phase != _StartupPhase.loading) {
      setState(() {
        _phase = _StartupPhase.loading;
      });
    }
    setState(() {
      _progress = 1;
    });

    await Future<void>.delayed(_finalHoldDuration);
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    final isLoggedIn = ref.read(authNotifierProvider).valueOrNull != null;
    context.goNamed(isLoggedIn ? RouteNames.home : RouteNames.login);
  }

  Future<void> _startMockResourceDownload() async {
    setState(() {
      _phase = _StartupPhase.resourceDownloading;
      _resourceProgress = 0.75;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    await _maybeAdvanceFlow();
  }

  @override
  Widget build(BuildContext context) {
    final showBar =
        _phase == _StartupPhase.startup ||
        _phase == _StartupPhase.resourceDownloading ||
        _phase == _StartupPhase.loading;
    final showBottomButton =
        _phase == _StartupPhase.resourcePrompt ||
        _phase == _StartupPhase.resourceDownloading ||
        _phase == _StartupPhase.loading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                return _StartupBackdrop(t: _ambientController.value);
              },
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final height = constraints.maxHeight;
                  final topGap = (height * 0.28).clamp(188.0, 248.0);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
                    child: Column(
                      children: [
                        SizedBox(height: topGap),
                        const _OmaoLogo(),
                        SizedBox(
                          height: _phase == _StartupPhase.intro ? 0 : 34,
                        ),
                        if (_phase == _StartupPhase.intro) ...[
                          const Spacer(),
                          const _UnitySignature(),
                          const SizedBox(height: 188),
                        ] else ...[
                          SizedBox(
                            height: 32,
                            child: Center(
                              child: _PhaseLabel(
                                phase: _phase,
                                resourceProgress: _resourceProgress,
                              ),
                            ),
                          ),
                          if (showBar) ...[
                            const SizedBox(height: 12),
                            _StartupProgressBar(
                              progress:
                                  _phase == _StartupPhase.resourceDownloading
                                      ? _resourceProgress
                                      : _progress,
                            ),
                          ],
                          const Spacer(),
                          if (showBottomButton) ...[
                            if (_phase == _StartupPhase.resourcePrompt) ...[
                              _StartupActionButton(
                                label: '下载（1.5G）',
                                filled: true,
                                onTap: _startMockResourceDownload,
                              ),
                              const SizedBox(height: 20),
                              _StartupActionButton(
                                label: '取消',
                                filled: false,
                                onTap: _maybeAdvanceFlow,
                              ),
                            ] else ...[
                              _StartupActionButton(
                                label: '取消',
                                filled: false,
                                onTap: _maybeAdvanceFlow,
                              ),
                            ],
                          ],
                          const SizedBox(height: 28),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupBackdrop extends StatelessWidget {
  const _StartupBackdrop({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF98A2D8),
            Color(0xFFBEC3EA),
            Color(0xFFD8D8F2),
            Color(0xFFE2E4F8),
          ],
          stops: [0, 0.28, 0.68, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(painter: _StartupAtmospherePainter(t: t)),
          ),
          Positioned(
            top: -30,
            left: -80 + (t * 18),
            child: _BlurOrb(
              size: 260,
              color: const Color(0xFFE7C0E4).withValues(alpha: 0.34),
            ),
          ),
          Positioned(
            top: 180 + (math.sin(t * math.pi * 2) * 8),
            right: -22,
            child: _BlurOrb(
              size: 180,
              color: const Color(0xFFC5D1FF).withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -36,
            child: _BlurOrb(
              size: 168,
              color: const Color(0xFFF4E4F6).withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -34,
            child: _BlurOrb(
              size: 220,
              color: const Color(0xFFF6D8E8).withValues(alpha: 0.26),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _OmaoLogo extends StatelessWidget {
  const _OmaoLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 17,
            left: 22,
            right: 22,
            child: Row(
              children: [
                Expanded(child: _LogoSlash(leftTilt: true)),
                SizedBox(width: 12),
                Expanded(child: _LogoSlash(leftTilt: false)),
              ],
            ),
          ),
          Text(
            'OMAO',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 48,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: -1.2,
              color: Colors.white.withValues(alpha: 0.98),
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.18),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoSlash extends StatelessWidget {
  const _LogoSlash({required this.leftTilt});

  final bool leftTilt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(2, (index) {
          return Positioned(
            left: 8 + (index * 18),
            top: index == 0 ? 0 : 3,
            child: Transform.rotate(
              angle: leftTilt ? -0.48 : 0.48,
              child: Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.34),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _UnitySignature extends StatelessWidget {
  const _UnitySignature();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'MADE\nWITH',
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.1,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.6,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          Icons.view_in_ar_outlined,
          size: 42,
          color: Colors.white.withValues(alpha: 0.62),
        ),
        const SizedBox(width: 10),
        Text(
          'Unity',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}

class _PhaseLabel extends StatelessWidget {
  const _PhaseLabel({required this.phase, required this.resourceProgress});

  final _StartupPhase phase;
  final double resourceProgress;

  @override
  Widget build(BuildContext context) {
    if (phase == _StartupPhase.startup) {
      return const SizedBox.shrink();
    }

    String text;
    switch (phase) {
      case _StartupPhase.resourcePrompt:
        text = '首次使用需要下载资源文件';
        break;
      case _StartupPhase.resourceDownloading:
        final percentage = (resourceProgress * 100).round();
        text = '资源文件下载中    $percentage%';
        break;
      case _StartupPhase.loading:
        text = '加载中';
        break;
      case _StartupPhase.intro:
      case _StartupPhase.startup:
        text = '';
        break;
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: Colors.white.withValues(alpha: 0.92),
      ),
    );
  }
}

class _StartupProgressBar extends StatelessWidget {
  const _StartupProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.06, 1.0);

    return SizedBox(
      width: 250,
      height: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final knobX = (width * clamped).clamp(18.0, width - 2);

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        Color(0xFFC8B6FF),
                        Color(0xFFB58CF2),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                child: Container(
                  width: knobX,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.34),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: knobX - 10,
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.96),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StartupActionButton extends StatelessWidget {
  const _StartupActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 281,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: filled ? null : Colors.white.withValues(alpha: 0.96),
          gradient:
              filled
                  ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFEFEAFD),
                      Color(0xFF8061D0),
                      Color(0xFF5A3FAD),
                    ],
                    stops: [0, 0.58, 1],
                  )
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 1.6,
            color: filled ? Colors.white : const Color(0xFF7C7C7C),
          ),
        ),
      ),
    );
  }
}

class _StartupAtmospherePainter extends CustomPainter {
  const _StartupAtmospherePainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final gold =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            colors: [Color(0x00FFFFFF), Color(0x90FFE7C4), Color(0x00FFFFFF)],
          ).createShader(Offset.zero & size)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (var i = 0; i < 3; i++) {
      gold.strokeWidth = 1.2 + i * 0.6;
      final pathTop =
          Path()
            ..moveTo(-20, 42 + (i * 10))
            ..cubicTo(
              40,
              28 - (i * 2),
              96,
              46 + (i * 10),
              156,
              10 + (i * 12) + (math.sin(t * math.pi * 2) * 6),
            );
      final pathBottom =
          Path()
            ..moveTo(size.width - 6, size.height - 46 - (i * 7))
            ..cubicTo(
              size.width - 90,
              size.height - 20 - (i * 6),
              size.width - 138,
              size.height - 70 - (i * 10),
              size.width - 206,
              size.height - 42 - (i * 8) - (math.sin(t * math.pi * 2) * 5),
            );
      canvas.drawPath(pathTop, gold);
      canvas.drawPath(pathBottom, gold);
    }

    final speck = Paint()..color = Colors.white.withValues(alpha: 0.65);
    final brightSpots = <Offset>[
      Offset(size.width * 0.07, size.height * 0.36),
      Offset(size.width * 0.18, size.height * 0.72),
      Offset(size.width * 0.8, size.height * 0.78),
      Offset(size.width * 0.7, size.height * 0.12),
      Offset(size.width * 0.83, size.height * 0.67),
    ];
    for (final point in brightSpots) {
      canvas.drawCircle(point, 3.2, speck);
    }

    final shardPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.18);
    final shards = <Offset>[
      Offset(size.width * 0.87, size.height * 0.12),
      Offset(size.width * 0.78, size.height * 0.2),
      Offset(size.width * 0.12, size.height * 0.78),
      Offset(size.width * 0.18, size.height * 0.9),
    ];
    for (final center in shards) {
      final path =
          Path()
            ..moveTo(center.dx, center.dy - 13)
            ..lineTo(center.dx + 9, center.dy - 2)
            ..lineTo(center.dx + 3, center.dy + 11)
            ..lineTo(center.dx - 9, center.dy + 2)
            ..close();
      canvas.drawPath(path, shardPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StartupAtmospherePainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
