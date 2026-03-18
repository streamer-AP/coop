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

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '系统消息',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(messageNotifierProvider.notifier)
                          .markAllAsRead();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.26),
                        ),
                      ),
                      child: const Text(
                        '全部已读',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE9E3F3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: RefreshIndicator(
                  color: AppColors.primary,
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
                        padding: const EdgeInsets.only(top: 10, bottom: 100),
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
                          Center(child: Text('加载失败: $error')),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(24),
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
          padding: const EdgeInsets.only(bottom: 100),
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
