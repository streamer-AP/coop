import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../application/providers/player_providers.dart';
import '../../application/providers/subtitle_providers.dart';

class SubtitleView extends ConsumerStatefulWidget {
  const SubtitleView({super.key, this.onImportTap});

  final VoidCallback? onImportTap;

  @override
  ConsumerState<SubtitleView> createState() => _SubtitleViewState();
}

class _SubtitleViewState extends ConsumerState<SubtitleView> {
  final _scrollController = ScrollController();
  double _estimatedItemHeight = 56.0;
  int _lastScrolledCueIndex = -1;
  bool _wasFollowEnabled = true;
  bool _userScrolledAway = false;
  int? _seekTargetIndex;
  bool _isAutoScrolling = false;
  int _cueCount = 0;
  double _listVerticalPadding = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_userScrolledAway && !_isAutoScrolling && _cueCount > 0) {
      final idx = _findCenterCueIndex();
      if (idx != _seekTargetIndex) {
        setState(() => _seekTargetIndex = idx);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = ref.watch(currentSubtitleNotifierProvider);
    final translationEnabled = ref.watch(subtitleTranslationEnabledProvider);
    final translatedSubtitleAsync = ref.watch(translatedSubtitleProvider);
    final translatedSubtitle = translatedSubtitleAsync.valueOrNull;
    final translatedCueTextByTime =
        translatedSubtitle == null
            ? const <String, String>{}
            : {
                for (final cue in translatedSubtitle.cues)
                  _cueTimeKey(cue.start, cue.end): cue.text.trim(),
              };
    final activeCueIndex = ref.watch(activeCueNotifierProvider);
    final followMode = ref.watch(followModeNotifierProvider);
    final followEnabled = ref.watch(subtitleFollowEnabledProvider);

    if (subtitle == null || subtitle.cues.isEmpty) {
      _cueCount = 0;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Folder icon from Figma
              SvgPicture.asset(
                'assets/figma/icons/no-subtitle-folder.svg',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 16),
              Text(
                '抱歉，未找到字幕',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF4A4A4A).withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              // Import button — gradient from deep purple to light purple
              if (widget.onImportTap != null)
                GestureDetector(
                  onTap: widget.onImportTap,
                  child: Container(
                    height: 44,
                    width: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0xFFA89AE9), Color(0xFF543A99)],
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '导入',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    _cueCount = subtitle.cues.length;
    _estimatedItemHeight =
        translationEnabled && translatedSubtitle != null ? 78.0 : 42.0;

    if (_wasFollowEnabled && !followEnabled) {
      _scrollToTop();
    }
    _wasFollowEnabled = followEnabled;

    // When followMode timer restores (3s after user scroll), resume auto-follow
    final shouldAutoFollow = followEnabled && followMode;
    if (shouldAutoFollow && _userScrolledAway) {
      // Timer restored followMode → reset user scroll state
      _userScrolledAway = false;
      _seekTargetIndex = null;
      _lastScrolledCueIndex = -1;
    }

    if (shouldAutoFollow &&
        activeCueIndex >= 0 &&
        _lastScrolledCueIndex != activeCueIndex) {
      _lastScrolledCueIndex = activeCueIndex;
      _scrollToCue(activeCueIndex);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _listVerticalPadding = math.max(
          20,
          (constraints.maxHeight - _estimatedItemHeight) / 2,
        );

        return Column(
          children: [
            if (translationEnabled && translatedSubtitleAsync.isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '正在翻译字幕...',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6A53A7).withValues(alpha: 0.75),
                  ),
                ),
              ),
            if (translationEnabled && translatedSubtitleAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '翻译暂不可用，当前显示原字幕',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFB66A4D).withValues(alpha: 0.85),
                  ),
                ),
              ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (_isAutoScrolling) return false;

                  final isUserDragUpdate =
                      notification is ScrollUpdateNotification &&
                      notification.dragDetails != null;
                  final isUserScroll = notification is UserScrollNotification;

                  if (isUserDragUpdate || isUserScroll) {
                    if (followEnabled) {
                      ref
                          .read(followModeNotifierProvider.notifier)
                          .disableTemporarily();
                    }
                    if (!_userScrolledAway) {
                      setState(() {
                        _userScrolledAway = true;
                        _seekTargetIndex = _findCenterCueIndex();
                      });
                    }
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: subtitle.cues.length,
                  padding: EdgeInsets.symmetric(vertical: _listVerticalPadding),
                  itemBuilder: (context, index) {
                    final cue = subtitle.cues[index];
                    final translatedText = translatedCueTextByTime[_cueTimeKey(
                      cue.start,
                      cue.end,
                    )];
                    final isActive = index == activeCueIndex;
                    final isSeekTarget =
                        _userScrolledAway && index == _seekTargetIndex;

                    return GestureDetector(
                      onTap: () => _seekToCue(cue, index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child:
                                  isSeekTarget
                                      ? Text(
                                        _formatDuration(cue.start),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6A53A7),
                                        ),
                                      )
                                      : null,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cue.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                          isActive || isSeekTarget ? 16 : 14,
                                      height: 1.5,
                                      fontWeight:
                                          isActive || isSeekTarget
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          isActive
                                              ? const Color(0xFF4A4A4A)
                                              : isSeekTarget
                                              ? const Color(0xFF4A4A4A)
                                              : const Color(
                                                0xFF4A4A4A,
                                              ).withValues(alpha: 0.28),
                                    ),
                                  ),
                                  if (translationEnabled &&
                                      translatedText != null &&
                                      translatedText.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      translatedText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                            isActive || isSeekTarget ? 13 : 12,
                                        height: 1.4,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isActive || isSeekTarget
                                                ? const Color(
                                                  0xFF6A53A7,
                                                ).withValues(alpha: 0.88)
                                                : const Color(
                                                  0xFF6A53A7,
                                                ).withValues(alpha: 0.42),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child:
                                  isSeekTarget
                                      ? GestureDetector(
                                        onTap: () => _seekToCue(cue, index),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          size: 22,
                                          color: Color(0xFF6A53A7),
                                        ),
                                      )
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _seekToCue(dynamic cue, int index) {
    ref
        .read(playerStateNotifierProvider.notifier)
        .seekTo(cue.start as Duration);
    final followEnabled = ref.read(subtitleFollowEnabledProvider);
    if (followEnabled) {
      ref.read(followModeNotifierProvider.notifier).enable();
    }
    setState(() {
      _userScrolledAway = false;
      _seekTargetIndex = null;
      _lastScrolledCueIndex = index;
    });
  }

  int? _findCenterCueIndex() {
    if (!_scrollController.hasClients) return null;
    if (!_scrollController.position.hasContentDimensions) return null;
    if (_cueCount == 0) return null;
    final centerOffset =
        _scrollController.offset +
        _scrollController.position.viewportDimension / 2;
    return ((centerOffset - _listVerticalPadding - (_estimatedItemHeight / 2)) /
            _estimatedItemHeight)
        .round()
        .clamp(0, _cueCount - 1);
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _isAutoScrolling = true;
      _scrollController
          .animateTo(
            0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          )
          .then((_) => _isAutoScrolling = false);
    });
  }

  void _scrollToCue(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (!_scrollController.position.hasContentDimensions) return;
      final targetOffset =
          index * _estimatedItemHeight -
          (_scrollController.position.viewportDimension / 2) +
          _listVerticalPadding +
          (_estimatedItemHeight / 2);
      final clampedOffset =
          targetOffset
              .clamp(0.0, _scrollController.position.maxScrollExtent)
              .toDouble();
      _isAutoScrolling = true;
      _scrollController
          .animateTo(
            clampedOffset,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          )
          .then((_) => _isAutoScrolling = false);
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _cueTimeKey(Duration start, Duration end) {
    return '${start.inMilliseconds}:${end.inMilliseconds}';
  }
}
