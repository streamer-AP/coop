import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/message_providers.dart';

class MessageDetailScreen extends ConsumerWidget {
  static const _designWidth = 393.0;

  const MessageDetailScreen({
    super.key,
    required this.messageId,
  });

  final int messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(watchMessagesProvider);

    return Stack(
      children: [
        const _MessageDetailBackdrop(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            '消息',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.28),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: messagesAsync.when(
                    data: (messages) {
                      final message =
                          messages.where((m) => m.id == messageId).firstOrNull;
                      if (message == null) {
                        return const Center(
                          child: Text(
                            '消息不存在',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFFCDCDF0).withValues(alpha: 0.54),
                                Colors.white.withValues(alpha: 0.90),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFEFECFD),
                                          Color(0xFF543A99),
                                        ],
                                        stops: [0.64088, 0.89131],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      message.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 20 / 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: const Color(0xFFD8D8DE),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                message.body,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 26 / 14,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF797979),
                                  letterSpacing: -0.14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 1,
                                color: const Color(0xFFD8D8DE),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatDate(message.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 24 / 12,
                                  color: Color(0xFF979797),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (error, _) => Center(
                      child: Text(
                        '$error',
                        style: const TextStyle(color: AppColors.textSecondary),
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
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }
}

class _MessageDetailAssets {
  const _MessageDetailAssets._();

  static const background = 'assets/figma/home/home_bg.png';
}

class _MessageDetailBackdrop extends StatelessWidget {
  const _MessageDetailBackdrop();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.min(
          MessageDetailScreen._designWidth,
          constraints.maxWidth,
        );
        final scale = contentWidth / MessageDetailScreen._designWidth;
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
                        _MessageDetailAssets.background,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: -1 * scale,
                      width: contentWidth,
                      height: overlayHeight,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: 0.5 * scale,
                            sigmaY: 0.5 * scale,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF28307C).withValues(alpha: 0.36),
                                  const Color(0xFFE7EAFF).withValues(alpha: 0.0),
                                ],
                                stops: const [0.10659, 0.69387],
                              ),
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF7F80A4).withValues(alpha: 0.70),
                              const Color(0xFF8181A5).withValues(alpha: 0.70),
                            ],
                            stops: const [0.0, 0.79328],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFCDCDF0).withValues(alpha: 0.20),
                              Colors.white,
                            ],
                            stops: const [0.047054, 1.0],
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
