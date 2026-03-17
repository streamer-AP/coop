import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../../../core/bluetooth/models/ble_signal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/signal_providers.dart';
import '../../application/providers/subtitle_providers.dart';
import '../../domain/models/player_state.dart';
import '../widgets/player_controls.dart';
import '../widgets/seek_bar.dart';
import '../widgets/subtitle_cover_import_sheet.dart';
import '../widgets/subtitle_view.dart';
import 'playlist_screen.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  bool _showSubtitle = true;
  bool _showControlPanel = false;
  double _swingLevel = 0;
  double _vibrationLevel = 0;
  late final AnimationController _discRotationController;

  @override
  void initState() {
    super.initState();
    _discRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
  }

  @override
  void dispose() {
    _discRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final currentEntry = playerState.currentEntry;
    final hasEntry = currentEntry != null;
    final hasSubtitle = ref.watch(currentSubtitleNotifierProvider) != null;
    final signalMode = ref.watch(signalModeNotifierProvider);
    final shouldRotate = hasEntry && playerState.isPlaying;

    if (shouldRotate && !_discRotationController.isAnimating) {
      _discRotationController.repeat();
    } else if (!shouldRotate && _discRotationController.isAnimating) {
      _discRotationController.stop();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(currentEntry?.coverPath),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(hasSubtitle),
                const SizedBox(height: 6),
                _buildSongMeta(
                  title: currentEntry?.title ?? '无播放',
                  artist: currentEntry?.artist ?? 'nobody',
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child:
                        _showSubtitle && hasSubtitle
                            ? const SubtitleView()
                            : _buildDiscArea(
                              coverPath: currentEntry?.coverPath,
                              hasEntry: hasEntry,
                            ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SeekBar(),
                ),
                const SizedBox(height: 8),
                PlayerControls(onPlaylistTap: _showPlaylist),
                const SizedBox(height: 12),
                _buildDeviceDock(hasEntry),
              ],
            ),
          ),
          if (_showControlPanel) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeControlPanel,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
            _buildControlPanel(signalMode),
          ],
        ],
      ),
    );
  }

  Widget _buildBackground(String? coverPath) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverPath != null)
            Image.file(
              File(coverPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.expand(),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB3634E83),
                  Color(0xB3A89CBC),
                  Color(0xB3EAEAEA),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool hasSubtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildCircleIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          if (hasSubtitle)
            _buildCircleIconButton(
              icon:
                  _showSubtitle
                      ? Icons.album_outlined
                      : Icons.subtitles_outlined,
              onTap: () => setState(() => _showSubtitle = !_showSubtitle),
            ),
          const SizedBox(width: 8),
          _buildCircleIconButton(
            icon: Icons.more_horiz_rounded,
            onTap: hasSubtitle ? _showSubtitleOptions : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: const Color(0xFF6A6A6A),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSongMeta({required String title, required String artist}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF797979)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscArea({required String? coverPath, required bool hasEntry}) {
    return Center(
      child: SizedBox(
        width: 320,
        height: 308,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              top: 104,
              child: Transform.rotate(
                angle: -0.95,
                child: Container(
                  width: 70,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9B3C7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 293,
                height: 293,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x5E6A53A7), width: 8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final diameter in const [275.0, 239.0, 214.0, 191.0])
                      Container(
                        width: diameter,
                        height: diameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0x296A53A7),
                            width: 1,
                          ),
                        ),
                      ),
                    Container(
                      width: 146,
                      height: 146,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD6D6D6),
                      ),
                      child: ClipOval(
                        child: RotationTransition(
                          turns: _discRotationController,
                          child:
                              coverPath != null
                                  ? Image.file(
                                    File(coverPath),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            _buildDiscFallback(hasEntry),
                                  )
                                  : _buildDiscFallback(hasEntry),
                        ),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFC7C7C7),
                        border: Border.all(color: const Color(0xFF8D8D8D)),
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

  Widget _buildDiscFallback(bool hasEntry) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E8E8E), Color(0xFFBDBDBD)],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: 44,
        color:
            hasEntry
                ? Colors.white.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildDeviceDock(bool hasEntry) {
    return Container(
      height: 130,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFDBD4EE),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 21),
          GestureDetector(
            onTap: hasEntry ? _openControlPanel : null,
            child: Container(
              width: 320,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient:
                    hasEntry
                        ? const LinearGradient(
                          colors: [
                            Color(0xFFECE5FF),
                            Color(0xFFFBF9FF),
                            Colors.white,
                          ],
                          stops: [0.0, 0.53, 0.98],
                        )
                        : const LinearGradient(
                          colors: [Color(0xFFE0E0E0), Color(0xFFD2D2D2)],
                        ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color:
                          hasEntry
                              ? const Color(0xFF6A53A7)
                              : const Color(0xFFAAAAAA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hasEntry ? '打开控制' : '无播放，暂不可控制',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          hasEntry
                              ? const Color(0xFF6A53A7)
                              : const Color(0xFF9F9F9F),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color:
                        hasEntry
                            ? const Color(0xFF6A53A7)
                            : const Color(0xFF9F9F9F),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(SignalMode signalMode) {
    final panelHeight =
        math.min(MediaQuery.of(context).size.height * 0.7, 541).toDouble();
    final isPresetMode = signalMode == SignalMode.preset;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: panelHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFDBD4EE),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('收起控制', style: TextStyle(fontSize: 16)),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.expand_more_rounded,
                    color: Color(0xFF8A8A8A),
                  ),
                  onPressed: _closeControlPanel,
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildModeCard(signalMode),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  children: [
                    _buildPresetHeader(
                      title: '摇摆',
                      icon: Icons.sync_alt_rounded,
                    ),
                    IgnorePointer(
                      ignoring: !isPresetMode,
                      child: Opacity(
                        opacity: isPresetMode ? 1 : 0.45,
                        child: _buildStrengthControl(
                          value: _swingLevel,
                          onChanged: (value) {
                            setState(() => _swingLevel = value);
                            _sendPresetSignal();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildPresetHeader(
                      title: '震动',
                      icon: Icons.vibration_rounded,
                    ),
                    IgnorePointer(
                      ignoring: !isPresetMode,
                      child: Opacity(
                        opacity: isPresetMode ? 1 : 0.45,
                        child: _buildStrengthControl(
                          value: _vibrationLevel,
                          onChanged: (value) {
                            setState(() => _vibrationLevel = value);
                            _sendPresetSignal();
                          },
                        ),
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

  Widget _buildModeCard(SignalMode mode) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text('信号模式', style: TextStyle(fontSize: 16)),
          const Spacer(),
          _ModePill(
            label: '同步共鸣',
            selected: mode == SignalMode.resonance,
            onTap: () async {
              await ref
                  .read(signalModeNotifierProvider.notifier)
                  .setMode(SignalMode.resonance);
              ref
                  .read(bleSignalArbitratorProvider)
                  .releaseSource(SignalSource.preset);
            },
          ),
          const SizedBox(width: 8),
          _ModePill(
            label: '使用预设',
            selected: mode == SignalMode.preset,
            onTap: () async {
              await ref
                  .read(signalModeNotifierProvider.notifier)
                  .setMode(SignalMode.preset);
              _sendPresetSignal();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF6A53A7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Color(0xFF797979)),
        ),
        const Spacer(),
        const Text('预设名1', style: TextStyle(fontSize: 15)),
        const SizedBox(width: 6),
        const Icon(Icons.sync_alt_rounded, color: Color(0xFF8A8A8A), size: 20),
      ],
    );
  }

  Widget _buildStrengthControl({
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            activeTrackColor: const Color(0xFF6A53A7),
            inactiveTrackColor: const Color(0xFFF3F4F6),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.clamp(0, 3),
            min: 0,
            max: 3,
            divisions: 3,
            onChanged: onChanged,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '关',
                style: TextStyle(fontSize: 12, color: Color(0xFF797979)),
              ),
              Text(
                '弱',
                style: TextStyle(fontSize: 12, color: Color(0xFF797979)),
              ),
              Text(
                '中',
                style: TextStyle(fontSize: 12, color: Color(0xFF797979)),
              ),
              Text(
                '强',
                style: TextStyle(fontSize: 12, color: Color(0xFF797979)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openControlPanel() {
    if (ref.read(signalModeNotifierProvider) == SignalMode.off) {
      ref
          .read(signalModeNotifierProvider.notifier)
          .setMode(SignalMode.resonance);
    }
    setState(() {
      _showControlPanel = true;
      // 打开控制面板后默认回到电机关闭状态。
      _swingLevel = 0;
      _vibrationLevel = 0;
    });
    _sendPresetSignal();
  }

  void _closeControlPanel() {
    setState(() => _showControlPanel = false);
  }

  void _sendPresetSignal() {
    final mode = ref.read(signalModeNotifierProvider);
    final arbitrator = ref.read(bleSignalArbitratorProvider);
    if (mode != SignalMode.preset) {
      arbitrator.releaseSource(SignalSource.preset);
      return;
    }

    final swing = _swingLevel.round();
    final vibration = _vibrationLevel.round();
    if (swing <= 0 && vibration <= 0) {
      arbitrator.releaseSource(SignalSource.preset);
      return;
    }

    arbitrator.submitSignal(
      BleSignal(
        swing: swing,
        vibration: vibration,
        source: SignalSource.preset,
      ),
    );
  }

  Future<void> _showSubtitleOptions() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final followEnabled = sheetRef.watch(subtitleFollowEnabledProvider);
            final translationEnabled = sheetRef.watch(
              subtitleTranslationEnabledProvider,
            );
            final language = sheetRef.watch(
              subtitleTranslationLanguageProvider,
            );
            final currentEntry =
                sheetRef.watch(playerStateNotifierProvider).currentEntry;

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8D8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('字幕跟随'),
                      subtitle: const Text('滚动歌词后 3 秒自动恢复跟随'),
                      value: followEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        sheetRef
                            .read(subtitleFollowEnabledProvider.notifier)
                            .state = value;
                        if (value) {
                          sheetRef
                              .read(followModeNotifierProvider.notifier)
                              .enable();
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('翻译字幕'),
                      subtitle: const Text('支持中英日韩'),
                      value: translationEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        sheetRef
                            .read(subtitleTranslationEnabledProvider.notifier)
                            .state = value;
                      },
                    ),
                    if (translationEnabled) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('翻译语言', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                for (final option
                                    in SubtitleTranslationLanguage.values)
                                  ChoiceChip(
                                    label: Text(option.label),
                                    selected: language == option,
                                    onSelected: (_) {
                                      sheetRef
                                          .read(
                                            subtitleTranslationLanguageProvider
                                                .notifier,
                                          )
                                          .state = option;
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (currentEntry != null) ...[
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.download_outlined),
                        title: const Text('导入字幕/台本'),
                        subtitle: const Text('会覆盖当前条目的字幕或台本'),
                        onTap: () {
                          Navigator.of(context).pop();
                          SubtitleCoverImportSheet.show(
                            context,
                            entry: currentEntry,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPlaylist() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlaylistScreen(),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0xFFEDE7FF) : const Color(0xFFF5F5F5),
          border: Border.all(
            color: selected ? const Color(0xFF6A53A7) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? const Color(0xFF6A53A7) : const Color(0xFF7C7C7C),
          ),
        ),
      ),
    );
  }
}
