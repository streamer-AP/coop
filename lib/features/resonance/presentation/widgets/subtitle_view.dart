import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/player_providers.dart';
import '../../application/providers/subtitle_providers.dart';

class SubtitleView extends ConsumerStatefulWidget {
  const SubtitleView({super.key});

  @override
  ConsumerState<SubtitleView> createState() => _SubtitleViewState();
}

class _SubtitleViewState extends ConsumerState<SubtitleView> {
  final _scrollController = ScrollController();
  static const _itemHeight = 48.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = ref.watch(currentSubtitleNotifierProvider);
    final activeCueIndex = ref.watch(activeCueNotifierProvider);
    final followMode = ref.watch(followModeNotifierProvider);

    if (subtitle == null || subtitle.cues.isEmpty) {
      return Center(
        child: Text(
          '暂无字幕',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    // Auto-scroll to active cue when in follow mode
    if (followMode && activeCueIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final targetOffset = activeCueIndex * _itemHeight -
              (_scrollController.position.viewportDimension / 2) +
              (_itemHeight / 2);
          _scrollController.animateTo(
            targetOffset.clamp(
              0,
              _scrollController.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          ref.read(followModeNotifierProvider.notifier).disableTemporarily();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: subtitle.cues.length,
        itemExtent: _itemHeight,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final cue = subtitle.cues[index];
          final isActive = index == activeCueIndex;

          return InkWell(
            onTap: () {
              ref
                  .read(playerStateNotifierProvider.notifier)
                  .seekTo(cue.start);
              ref.read(followModeNotifierProvider.notifier).enable();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                cue.text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isActive ? 18 : 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
