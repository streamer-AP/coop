import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
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
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(
                  title: playerState.playlistTitle,
                  hasSubtitle: hasSubtitle,
                  hasEntry: hasEntry,
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 340,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:
                              _showSubtitle && hasSubtitle
                                  ? _buildSubtitleStage()
                                  : _buildDiscStage(
                                    coverPath: currentEntry?.coverPath,
                                    hasEntry: hasEntry,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSongMeta(
                        title: currentEntry?.title ?? '无播放',
                        artist:
                            (currentEntry?.artist?.trim().isNotEmpty ?? false)
                                ? currentEntry!.artist!
                                : 'Unknown Artist',
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 37),
                        child: SeekBar(),
                      ),
                      const SizedBox(height: 14),
                      PlayerControls(onPlaylistTap: _showPlaylist),
                      const Spacer(),
                    ],
                  ),
                ),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildControlPanel(signalMode),
            ),
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
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Image.file(
                File(coverPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.expand(),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC634E83),
                  Color(0x99B4AAC8),
                  Color(0xFFEAEAEA),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.95),
                radius: 1.3,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar({
    required String title,
    required bool hasSubtitle,
    required bool hasEntry,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          _GlassCircleButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ),
          const SizedBox(width: 14),
          if (hasSubtitle)
            _GlassCircleButton(
              icon:
                  _showSubtitle
                      ? Icons.album_outlined
                      : Icons.subtitles_rounded,
              onTap: () => setState(() => _showSubtitle = !_showSubtitle),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 8),
          _GlassCircleButton(
            icon: Icons.more_horiz_rounded,
            onTap: hasEntry ? _showSubtitleOptions : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscStage({required String? coverPath, required bool hasEntry}) {
    return Center(
      child: SizedBox(
        width: 330,
        height: 330,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(left: 6, top: 44, child: _buildTonearm()),
            Positioned(
              top: 0,
              child: Container(
                width: 293,
                height: 293,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFF4F4F4), Color(0xFFD6D6D6)],
                    stops: [0.0, 1.0],
                  ),
                  border: Border.all(
                    color: const Color(0xFF7E6AAE).withValues(alpha: 0.32),
                    width: 8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                    ),
                  ],
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
                            color: const Color(
                              0xFF7F7F7F,
                            ).withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    Container(
                      width: 146,
                      height: 146,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF3A3A3A), Color(0xFF161616)],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.2,
                        ),
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
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF9E9E9E), Color(0xFF5F5F5F)],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFBEBEBE),
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

  Widget _buildTonearm() {
    return Transform.rotate(
      angle: -0.58,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 90,
        height: 172,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFE6E6E6), Color(0xFFBDBDBD)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              child: Container(
                width: 10,
                height: 108,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFD9D9D9), Color(0xFF8C8C8C)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 116,
              child: Container(
                width: 34,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5F5F5), Color(0xFFCFCFCF)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 147,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  borderRadius: BorderRadius.circular(5),
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
          colors: [Color(0xFF7A7A7A), Color(0xFFB9B9B9)],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: 42,
        color:
            hasEntry
                ? Colors.white.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _buildSubtitleStage() {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        const Positioned.fill(child: SubtitleView()),
        Positioned.fill(
          child: IgnorePointer(
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0.96),
                        AppColors.background.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0.0),
                        AppColors.background.withValues(alpha: 0.98),
                      ],
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

  Widget _buildSongMeta({required String title, required String artist}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
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
          const SizedBox(height: 5),
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

  Widget _buildDeviceDock(bool hasEntry) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(0, 12, 0, math.max(12, bottomInset)),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFDBD4EE),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: hasEntry ? _openControlPanel : null,
            child: Container(
              width: 320,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient:
                    hasEntry
                        ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFECE5FF),
                            Color(0xFFFBF9FF),
                            Colors.white,
                          ],
                          stops: [0.0, 0.53, 0.98],
                        )
                        : const LinearGradient(
                          colors: [Color(0xFFE3E3E3), Color(0xFFD8D8D8)],
                        ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFB8AEDA,
                    ).withValues(alpha: hasEntry ? 0.18 : 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color:
                          hasEntry
                              ? const Color(0xFF6A53A7)
                              : const Color(0xFFAFAFAF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hasEntry ? '打开控制' : '选择音频后可控制',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          hasEntry
                              ? const Color(0xFF6A53A7)
                              : const Color(0xFF9E9E9E),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color:
                        hasEntry
                            ? const Color(0xFF6A53A7)
                            : const Color(0xFF9E9E9E),
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final panelHeight =
        math.min(MediaQuery.of(context).size.height * 0.66, 541).toDouble();
    final isResonanceMode = signalMode == SignalMode.resonance;
    final isPresetMode = signalMode == SignalMode.preset;

    return Container(
      height: panelHeight + bottomInset,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 14, 20, 12 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
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
              const Text(
                '收起控制',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
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
          const SizedBox(height: 4),
          _buildSignalToggleCard(
            label: '同步共鸣',
            selected: isResonanceMode,
            onChanged: (enabled) async {
              if (enabled) {
                await ref
                    .read(signalModeNotifierProvider.notifier)
                    .setMode(SignalMode.resonance);
                ref
                    .read(bleSignalArbitratorProvider)
                    .releaseSource(SignalSource.preset);
              } else {
                await ref
                    .read(signalModeNotifierProvider.notifier)
                    .setMode(SignalMode.off);
              }
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 18),
              child: Column(
                children: [
                  _buildPresetModeHeader(
                    selected: isPresetMode,
                    onChanged: (enabled) async {
                      if (enabled) {
                        await ref
                            .read(signalModeNotifierProvider.notifier)
                            .setMode(SignalMode.preset);
                        _sendPresetSignal();
                      } else {
                        await ref
                            .read(signalModeNotifierProvider.notifier)
                            .setMode(SignalMode.off);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildPresetSection(
                    title: '摇摆',
                    icon: Icons.sync_alt_rounded,
                    value: _swingLevel,
                    enabled: isPresetMode,
                    onChanged: (value) {
                      setState(() => _swingLevel = value);
                      _sendPresetSignal();
                    },
                  ),
                  const SizedBox(height: 26),
                  _buildPresetModeHeader(
                    selected: isPresetMode,
                    onChanged: (enabled) async {
                      if (enabled) {
                        await ref
                            .read(signalModeNotifierProvider.notifier)
                            .setMode(SignalMode.preset);
                        _sendPresetSignal();
                      } else {
                        await ref
                            .read(signalModeNotifierProvider.notifier)
                            .setMode(SignalMode.off);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildPresetSection(
                    title: '震动',
                    icon: Icons.vibration_rounded,
                    value: _vibrationLevel,
                    enabled: isPresetMode,
                    onChanged: (value) {
                      setState(() => _vibrationLevel = value);
                      _sendPresetSignal();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalToggleCard({
    required String label,
    required bool selected,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Switch.adaptive(
            value: selected,
            activeThumbColor: const Color(0xFF6A53A7),
            activeTrackColor: const Color(0xFFBBAFE1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetModeHeader({
    required bool selected,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        const Text('预设名1', style: TextStyle(fontSize: 16, color: Colors.black)),
        const Spacer(),
        Switch.adaptive(
          value: selected,
          activeThumbColor: const Color(0xFF6A53A7),
          activeTrackColor: const Color(0xFFBBAFE1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPresetSection({
    required String title,
    required IconData icon,
    required double value,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: Column(
          children: [
            Row(
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF797979),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStrengthControl(value: value, onChanged: onChanged),
          ],
        ),
      ),
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
    setState(() => _showControlPanel = true);
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
                            this.context,
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

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.16),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                icon,
                size: 24,
                color:
                    onTap != null
                        ? Colors.white.withValues(alpha: 0.84)
                        : Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
