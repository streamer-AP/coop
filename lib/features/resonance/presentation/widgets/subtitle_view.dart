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
  static const _itemHeight = 56.0;
  int _lastAutoFollowIndex = -1;

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
    final followEnabled = ref.watch(subtitleFollowEnabledProvider);
    final translationEnabled = ref.watch(subtitleTranslationEnabledProvider);
    final language = ref.watch(subtitleTranslationLanguageProvider);

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

    final shouldAutoFollow = followEnabled && followMode;

    if (shouldAutoFollow && activeCueIndex >= 0) {
      if (_lastAutoFollowIndex != activeCueIndex) {
        _lastAutoFollowIndex = activeCueIndex;
        _jumpToCue(activeCueIndex, animate: true);
      }
    } else {
      _lastAutoFollowIndex = -1;
    }

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is UserScrollNotification && followEnabled) {
              ref
                  .read(followModeNotifierProvider.notifier)
                  .disableTemporarily();
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: subtitle.cues.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) {
              final cue = subtitle.cues[index];
              final isActive = index == activeCueIndex;
              final translatedText =
                  translationEnabled ? _translateCue(cue.text, language) : null;

              return InkWell(
                onTap: () {
                  ref
                      .read(playerStateNotifierProvider.notifier)
                      .seekTo(cue.start);
                  if (followEnabled) {
                    ref.read(followModeNotifierProvider.notifier).enable();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Text(
                        cue.text,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isActive ? 18 : 15,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      if (translatedText != null &&
                          translatedText.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          translatedText,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            color:
                                isActive
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap:
                    activeCueIndex >= 0
                        ? () {
                          final cue = subtitle.cues[activeCueIndex];
                          ref
                              .read(playerStateNotifierProvider.notifier)
                              .seekTo(cue.start);
                          _jumpToCue(activeCueIndex, animate: true);
                        }
                        : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _jumpToCue(int index, {required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final targetOffset =
          index * _itemHeight -
          (_scrollController.position.viewportDimension / 2) +
          (_itemHeight / 2);
      final clampedOffset =
          targetOffset
              .clamp(0, _scrollController.position.maxScrollExtent)
              .toDouble();
      if (animate) {
        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(clampedOffset);
      }
    });
  }

  String _translateCue(String text, SubtitleTranslationLanguage language) {
    const dictionary = {
      'Brother John, Brother John': {
        SubtitleTranslationLanguage.zh: '约翰哥哥，约翰哥哥',
        SubtitleTranslationLanguage.ja: 'ジョン兄さん、ジョン兄さん',
        SubtitleTranslationLanguage.ko: '존 형제여, 존 형제여',
      },
      'Are you sleeping, are you sleeping': {
        SubtitleTranslationLanguage.zh: '你睡着了吗，你睡着了吗',
        SubtitleTranslationLanguage.ja: '眠っているの？眠っているの？',
        SubtitleTranslationLanguage.ko: '자고 있나요, 자고 있나요',
      },
      'Morning bells are ringing': {
        SubtitleTranslationLanguage.zh: '清晨的钟声正在响起',
        SubtitleTranslationLanguage.ja: '朝の鐘が鳴っている',
        SubtitleTranslationLanguage.ko: '아침 종이 울리고 있어요',
      },
      'Ding ding dong, Ding ding dong': {
        SubtitleTranslationLanguage.zh: '叮叮当，叮叮当',
        SubtitleTranslationLanguage.ja: 'ディンドン、ディンドン',
        SubtitleTranslationLanguage.ko: '딩딩동, 딩딩동',
      },
    };

    final cleaned = text.trim();
    final translated = dictionary[cleaned]?[language];
    if (translated != null) return translated;

    final hasChinese = RegExp(r'[\u4e00-\u9fff]').hasMatch(cleaned);
    final hasJapanese = RegExp(r'[\u3040-\u30ff]').hasMatch(cleaned);
    final hasKorean = RegExp(r'[\uac00-\ud7af]').hasMatch(cleaned);

    if (language == SubtitleTranslationLanguage.zh && hasChinese) {
      return cleaned;
    }
    if (language == SubtitleTranslationLanguage.ja && hasJapanese) {
      return cleaned;
    }
    if (language == SubtitleTranslationLanguage.ko && hasKorean) return cleaned;
    if (language == SubtitleTranslationLanguage.en &&
        !hasChinese &&
        !hasJapanese &&
        !hasKorean) {
      return cleaned;
    }

    return '[${language.label}] $cleaned';
  }
}
