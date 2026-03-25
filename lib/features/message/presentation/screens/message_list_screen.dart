import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/message_providers.dart';
import '../widgets/message_card.dart';

class MessageListScreen extends ConsumerStatefulWidget {
  const MessageListScreen({super.key, required this.isActive});

  final bool isActive;

  @override
  ConsumerState<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends ConsumerState<MessageListScreen> {
  static const _designWidth = 393.0;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _triggerSync();
    }
  }

  @override
  void didUpdateWidget(covariant MessageListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _triggerSync();
    }
  }

  void _triggerSync() {
    Future.microtask(() {
      ref.read(messageNotifierProvider.notifier).syncMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(watchMessagesProvider);
    final syncState =
        widget.isActive
            ? ref.watch(messageNotifierProvider)
            : const AsyncData<void>(null);

    if (widget.isActive) {
      ref.listen<AsyncValue<void>>(messageNotifierProvider, (previous, next) {
        if (!next.hasError || previous?.error == next.error) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          TopBannerToast.show(context, message: _syncErrorMessage(next.error));
        });
      });
    }

    return Stack(
      children: [
        const _MessageBackdrop(),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref.read(messageNotifierProvider.notifier).markAllAsRead();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '全部已读',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  edgeOffset: 12,
                  onRefresh:
                      () =>
                          ref
                              .read(messageNotifierProvider.notifier)
                              .syncMessages(),
                  child: messagesAsync.when(
                    data: (messages) {
                      if (messages.isEmpty && syncState.isLoading) {
                        return _buildScrollableFill(
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (messages.isEmpty && syncState.hasError) {
                        return _buildScrollableFill(
                          _buildSyncErrorState(
                            _syncErrorMessage(syncState.error),
                            onRetry:
                                () =>
                                    ref
                                        .read(messageNotifierProvider.notifier)
                                        .syncMessages(),
                          ),
                        );
                      }

                      if (messages.isEmpty) {
                        return _buildScrollableFill(_buildEmptyState());
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 124),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return MessageCard(
                            message: message,
                            onTap: () {
                              ref
                                  .read(messageNotifierProvider.notifier)
                                  .markAsRead(message.id);
                              context.pushNamed(
                                RouteNames.messageDetail,
                                pathParameters: {'id': message.id.toString()},
                              );
                            },
                          );
                        },
                      );
                    },
                    loading:
                        () => _buildScrollableFill(
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    error:
                        (error, _) => _buildScrollableFill(
                          Center(
                            child: Text(
                              '加载失败: $error',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  const Color(0xFFD5D5EE).withValues(alpha: 0.56),
                ],
              ),
            ),
            child: const Icon(
              Icons.markunread_mailbox_outlined,
              size: 36,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '暂无系统消息',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncErrorState(String message, {required VoidCallback onRetry}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          size: 80,
          color: AppColors.textHint,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 14, color: AppColors.textHint),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: onRetry,
          child: const Text(
            '重新拉取',
            style: TextStyle(fontSize: 14, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableFill(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 124),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(child: child),
            ),
          ],
        );
      },
    );
  }

  String _syncErrorMessage(Object? error) {
    final text = '${error ?? ''}'.replaceFirst('Exception: ', '').trim();
    return text.isEmpty ? '系统消息拉取失败，请稍后重试' : text;
  }
}

class _MessageAssets {
  const _MessageAssets._();

  static const background = 'assets/figma/home/home_bg.png';
}

class _MessageBackdrop extends StatelessWidget {
  const _MessageBackdrop();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.min(
          _MessageListScreenState._designWidth,
          constraints.maxWidth,
        );
        final scale = contentWidth / _MessageListScreenState._designWidth;
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
                        _MessageAssets.background,
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
                                  const Color(0xFFE7EAFF).withValues(alpha: 0.36),
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
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.05),
                              Colors.white.withValues(alpha: 0.14),
                            ],
                            stops: const [0.0, 0.72, 1.0],
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
