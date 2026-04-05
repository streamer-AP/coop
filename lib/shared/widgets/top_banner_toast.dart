import 'package:flutter/material.dart';

class TopBannerToast {
  static const Duration defaultDuration = Duration(milliseconds: 1600);

  static void show(
    BuildContext context, {
    required String message,
    bool isError = true,
    Duration duration = defaultDuration,
  }) {
    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    showOnOverlay(
      overlay,
      message: message,
      isError: isError,
      duration: duration,
      topPadding: topPadding,
    );
  }

  static void showOnOverlay(
    OverlayState overlay, {
    required String message,
    bool isError = true,
    Duration duration = defaultDuration,
    double topPadding = 0,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder:
          (context) => _TopBanner(
            message: message,
            isError: isError,
            onDismiss: () => entry.remove(),
            duration: duration,
            topPadding: topPadding,
          ),
    );
    overlay.insert(entry);
  }
}

class _TopBanner extends StatefulWidget {
  const _TopBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
    required this.duration,
    required this.topPadding,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;
  final Duration duration;
  final double topPadding;

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPadding + 8,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(200),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isError)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Color(0xFFDD4040),
                      size: 20,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6A53A7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                Flexible(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      inherit: false,
                      fontSize: 14,
                      color:
                          widget.isError
                              ? const Color(0xFFDD4040)
                              : Colors.white,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    textAlign: TextAlign.center,
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
