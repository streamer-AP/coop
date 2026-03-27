import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../../../core/bluetooth/models/ble_signal.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../../controller/application/providers/controller_providers.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/signal_providers.dart';
import '../../application/providers/subtitle_providers.dart';
import '../../domain/models/player_state.dart';
import '../../domain/models/subtitle.dart';
import '../widgets/player_controls.dart';
import '../widgets/script_view.dart';
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
    with TickerProviderStateMixin {
  static String get _collapsedTitleFontFamily =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'PingFang SC'
          : 'SourceHanSansCN';

  /// 0=cover/disc, 1=subtitle, 2=script
  int _displayMode = 0;
  double _swingLevel = 0;
  double _vibrationLevel = 0;
  double? _devicePanelHeight;
  bool _isDraggingDevicePanel = false;
  late final AnimationController _discRotationController;
  late final AnimationController _tonearmController;
  late final ProviderSubscription<PlayerState> _playerStateSubscription;
  late final ProviderSubscription<AsyncValue<ParsedSubtitle?>>
  _translatedSubtitleSubscription;
  String? _lastTranslationErrorMessage;

  // The exported arm asset already matches the playing posture. Rotate it a
  // little further left when paused so it visibly lifts away from the disc.
  // Tonearm angles: positive = needle swings right (onto disc)
  static const _tonearmRestAngle = -0.12;
  static const _tonearmPlayAngle = 0.22;

  @override
  void initState() {
    super.initState();
    _discRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    _tonearmController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final initialPlayerState = ref.read(playerStateNotifierProvider);
    if (initialPlayerState.currentEntry != null &&
        initialPlayerState.isPlaying) {
      _tonearmController.value = 1.0;
      _discRotationController.repeat();
    }
    _playerStateSubscription = ref.listenManual<PlayerState>(
      playerStateNotifierProvider,
      (_, next) => _syncPlaybackAnimations(next),
    );
    _translatedSubtitleSubscription = ref
        .listenManual<AsyncValue<ParsedSubtitle?>>(translatedSubtitleProvider, (
          _,
          next,
        ) {
          final error = next.error;
          if (error == null) {
            _lastTranslationErrorMessage = null;
            return;
          }

          final message = '$error'.replaceFirst('Exception: ', '').trim();
          if (message.isEmpty || message == _lastTranslationErrorMessage) {
            return;
          }
          _lastTranslationErrorMessage = message;

          if (!mounted) {
            return;
          }
          TopBannerToast.show(context, message: message);
        });
  }

  @override
  void dispose() {
    _translatedSubtitleSubscription.close();
    _playerStateSubscription.close();
    _discRotationController.dispose();
    _tonearmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = ref.watch(
      playerStateNotifierProvider.select((state) => state.currentEntry),
    );
    final playlistTitle = ref.watch(
      playerStateNotifierProvider.select((state) => state.playlistTitle),
    );
    final hasEntry = currentEntry != null;
    final signalMode = ref.watch(signalModeNotifierProvider);
    final connectionState =
        ref.watch(connectionStateProvider).valueOrNull ??
        BleConnectionState.disconnected;
    final connectedDevice =
        ref.watch(bleConnectionManagerProvider).connectedDevice;
    final isDeviceConnected =
        connectionState == BleConnectionState.connected &&
        connectedDevice != null;
    final showSubtitleStage = hasEntry && _displayMode == 1;
    final showScriptStage = hasEntry && _displayMode == 2;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final collapsedPanelHeight = _collapsedPanelHeight(bottomInset);
    final previewPanelHeight = _previewPanelHeight(bottomInset);
    final expandedPanelHeight = _expandedPanelHeight(bottomInset);
    final devicePanelHeight = _resolvedDevicePanelHeight(
      collapsedPanelHeight: collapsedPanelHeight,
      expandedPanelHeight: expandedPanelHeight,
    );
    final panelProgress = _devicePanelProgress(
      panelHeight: devicePanelHeight,
      collapsedHeight: collapsedPanelHeight,
      expandedHeight: expandedPanelHeight,
    );
    final showPanelScrim = panelProgress > 0.18;
    final contentBottomPadding = collapsedPanelHeight + 12;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: contentBottomPadding),
              child: Column(
                children: [
                  // Top bar — only back button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: AppIcons.asset(
                            AppIcons.arrowLeft,
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  // Song title + author (or playlist title on cover page)
                  _buildSongMeta(
                    title:
                        _displayMode == 0
                            ? playlistTitle
                            : (currentEntry?.title ?? '无播放'),
                    artist:
                        _displayMode == 0
                            ? (currentEntry?.title ?? '')
                            : (currentEntry?.artist?.trim().isNotEmpty ?? false)
                            ? currentEntry!.artist!
                            : 'Unknown Artist',
                  ),
                  const SizedBox(height: 8),
                  // Main content area
                  Expanded(
                    child:
                        showSubtitleStage
                            ? _buildSubtitleStage()
                            : showScriptStage
                            ? const ScriptView()
                            : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _buildDiscStage(
                                coverPath: currentEntry?.coverPath,
                                onTap: hasEntry ? _cycleDisplayMode : null,
                              ),
                            ),
                  ),
                  // More + Translate buttons (below lyrics)
                  if (hasEntry)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 4, 35, 8),
                      child: Consumer(
                        builder: (context, cRef, _) {
                          final translationEnabled = cRef.watch(
                            subtitleTranslationEnabledProvider,
                          );
                          return Row(
                            children: [
                              _SmallIconButton(
                                icon: Icons.more_horiz,
                                onTap: _showSubtitleOptions,
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap:
                                    () => _setSubtitleTranslationEnabled(
                                      cRef,
                                      !translationEnabled,
                                    ),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          translationEnabled
                                              ? const Color(0xFF6A53A7)
                                              : const Color(
                                                0xFF797979,
                                              ).withValues(alpha: 0.7),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    color:
                                        translationEnabled
                                            ? const Color(
                                              0xFF6A53A7,
                                            ).withValues(alpha: 0.1)
                                            : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '译',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            translationEnabled
                                                ? const Color(0xFF6A53A7)
                                                : const Color(
                                                  0xFF797979,
                                                ).withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Display mode toggle
                              _SmallIconButton(
                                icon:
                                    _displayMode == 0
                                        ? Icons.lyrics_outlined
                                        : _displayMode == 1
                                        ? Icons.description_outlined
                                        : Icons.album_outlined,
                                onTap: _cycleDisplayMode,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  // Seek bar
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 37),
                    child: SeekBar(),
                  ),
                  const SizedBox(height: 8),
                  // Player controls
                  PlayerControls(onPlaylistTap: _showPlaylist),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !showPanelScrim,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: showPanelScrim ? panelProgress * 0.52 : 0,
                child: GestureDetector(
                  onTap: _closeControlPanel,
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildDevicePanel(
              hasEntry: hasEntry,
              signalMode: signalMode,
              panelHeight: devicePanelHeight,
              collapsedHeight: collapsedPanelHeight,
              previewHeight: previewPanelHeight,
              expandedHeight: expandedPanelHeight,
              isDeviceConnected: isDeviceConnected,
              deviceName: connectedDevice?.name,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFEAEAEA)),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 596,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xB3634E83), Color(0xB3EAEAEA)],
                  stops: [0.0, 0.79328],
                ),
              ),
            ),
          ),
          // Radial light glow overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  'assets/figma/player/radial_light.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Noise texture overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/figma/player/noise_texture.png',
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.overlay,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Iridescent light overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/figma/player/iridescent_light.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscStage({String? coverPath, VoidCallback? onTap}) {
    // 有封面时显示圆角矩形大封面，无封面时显示唱片台
    if (coverPath != null) {
      return _buildCoverStage(coverPath: coverPath, onTap: onTap);
    }
    return _buildVinylStage(onTap: onTap);
  }

  /// 有封面 — 圆角矩形封面图
  Widget _buildCoverStage({required String coverPath, VoidCallback? onTap}) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFFF0ECE6)),
                Image.file(
                  File(coverPath),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => _buildVinylStage(onTap: null),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 无封面 — 唱片台（disc + tonearm）
  Widget _buildVinylStage({VoidCallback? onTap}) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 280,
          height: 300,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 20,
                right: 5,
                child: RotationTransition(
                  turns: _discRotationController,
                  child: Image.asset(
                    'assets/figma/player/disc.png',
                    width: 250,
                    height: 250,
                  ),
                ),
              ),
              Positioned(
                left: 5,
                top: 120,
                child: IgnorePointer(child: _buildTonearm()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTonearm() {
    return AnimatedBuilder(
      animation: _tonearmController,
      builder: (context, child) {
        final angle =
            lerpDouble(
              _tonearmRestAngle,
              _tonearmPlayAngle,
              Curves.easeInOut.transform(_tonearmController.value),
            )!;
        return Transform.rotate(
          angle: angle,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: Image.asset(
        'assets/figma/player/tonearm.png',
        width: 74,
        height: 184,
      ),
    );
  }

  Widget _buildSubtitleStage() {
    return const SubtitleView();
  }

  void _syncPlaybackAnimations(PlayerState playerState) {
    final shouldRotate =
        playerState.currentEntry != null && playerState.isPlaying;

    if (shouldRotate) {
      if (!_discRotationController.isAnimating) {
        _discRotationController.repeat();
      }
      if (_tonearmController.value < 1.0 &&
          _tonearmController.status != AnimationStatus.forward) {
        _tonearmController.forward();
      }
      return;
    }

    if (_discRotationController.isAnimating) {
      _discRotationController.stop();
    }
    if (_tonearmController.value > 0.0 &&
        _tonearmController.status != AnimationStatus.reverse) {
      _tonearmController.reverse();
    }
  }

  void _cycleDisplayMode() {
    setState(() => _displayMode = (_displayMode + 1) % 3);
  }

  void _setSubtitleTranslationEnabled(WidgetRef ref, bool enabled) {
    if (!enabled) {
      ref.read(subtitleTranslationEnabledProvider.notifier).state = false;
      return;
    }

    final currentSubtitle = ref.read(currentSubtitleNotifierProvider);
    if (currentSubtitle != null) {
      final detectedLanguage = _detectSubtitleLanguage(currentSubtitle);
      final translationLanguageNotifier = ref.read(
        subtitleTranslationLanguageProvider.notifier,
      );
      if (detectedLanguage != null &&
          translationLanguageNotifier.state == detectedLanguage) {
        final nextLanguage =
            detectedLanguage == SubtitleTranslationLanguage.zh
                ? SubtitleTranslationLanguage.ja
                : SubtitleTranslationLanguage.zh;
        translationLanguageNotifier.state = nextLanguage;
        if (mounted) {
          TopBannerToast.show(
            context,
            message: '已切换为翻译成${nextLanguage.label}',
            isError: false,
          );
        }
      }
    }

    ref.read(subtitleTranslationEnabledProvider.notifier).state = true;
  }

  SubtitleTranslationLanguage? _detectSubtitleLanguage(
    ParsedSubtitle subtitle,
  ) {
    final sample = subtitle.cues
        .take(12)
        .map((cue) => cue.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');
    if (sample.isEmpty) {
      return null;
    }

    for (final rune in sample.runes) {
      final isKana =
          (rune >= 0x3040 && rune <= 0x309F) ||
          (rune >= 0x30A0 && rune <= 0x30FF) ||
          (rune >= 0x31F0 && rune <= 0x31FF);
      if (isKana) {
        return SubtitleTranslationLanguage.ja;
      }
    }

    final hasCjk = sample.runes.any(
      (rune) =>
          (rune >= 0x4E00 && rune <= 0x9FFF) ||
          (rune >= 0x3400 && rune <= 0x4DBF) ||
          (rune >= 0xF900 && rune <= 0xFAFF),
    );
    if (hasCjk) {
      return SubtitleTranslationLanguage.zh;
    }

    return null;
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
              fontSize: 18,
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicePanel({
    required bool hasEntry,
    required SignalMode signalMode,
    required double panelHeight,
    required double collapsedHeight,
    required double previewHeight,
    required double expandedHeight,
    required bool isDeviceConnected,
    required String? deviceName,
  }) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final showPreview = panelHeight >= previewHeight - 8;
    final showExpanded = panelHeight > previewHeight + 36;
    final actionEnabled = hasEntry;
    final actionLabel =
        isDeviceConnected
            ? '打开控制'
            : actionEnabled
            ? '连接设备'
            : '暂无设备';

    return AnimatedContainer(
      duration:
          _isDraggingDevicePanel
              ? Duration.zero
              : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: panelHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:
                  () => _snapDevicePanel(
                    showExpanded
                        ? _DevicePanelSnap.preview
                        : showPreview
                        ? _DevicePanelSnap.expanded
                        : _DevicePanelSnap.preview,
                    bottomInset: bottomInset,
                  ),
              onVerticalDragUpdate:
                  (details) => _handleDevicePanelDragUpdate(
                    details,
                    bottomInset: bottomInset,
                  ),
              onVerticalDragEnd:
                  (details) => _handleDevicePanelDragEnd(
                    details,
                    bottomInset: bottomInset,
                  ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      child:
                          showExpanded
                              ? Padding(
                                key: const ValueKey('expanded-header'),
                                padding: const EdgeInsets.only(top: 14),
                                child: Row(
                                  children: [
                                    Text(
                                      deviceName?.trim().isNotEmpty == true
                                          ? deviceName!
                                          : '控制面板',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1C1B1F),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      isDeviceConnected ? '设备已连接' : '未连接设备',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            isDeviceConnected
                                                ? const Color(0xFF6A53A7)
                                                : const Color(0xFF979797),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _closeControlPanel,
                                      icon: const Icon(
                                        Icons.expand_more_rounded,
                                        color: Color(0xFF8A8A8A),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : showPreview
                              ? Padding(
                                key: const ValueKey('preview-button'),
                                padding: const EdgeInsets.only(top: 21),
                                child: _buildDevicePanelButton(
                                  label: actionLabel,
                                  enabled: actionEnabled,
                                  onTap:
                                      actionEnabled
                                          ? () {
                                            if (isDeviceConnected) {
                                              _openControlPanel();
                                              return;
                                            }
                                            context.pushNamed(
                                              RouteNames.controller,
                                            );
                                          }
                                          : null,
                                ),
                              )
                              : Padding(
                                key: const ValueKey('collapsed-title'),
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'OMAO WITH YOU',
                                  style: TextStyle(
                                    fontFamily: _collapsedTitleFontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(
                                      0xFF6A53A7,
                                    ).withValues(alpha: 0.20),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
            if (showExpanded)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: _buildControlPanelContent(signalMode),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicePanelButton({
    required String label,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    final contentColor =
        enabled ? const Color(0xFF6A53A7) : const Color(0xFF9E9E9E);
    final iconBackground =
        enabled ? const Color(0xFFECE5FF) : const Color(0xFFE8E8E8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          gradient:
              enabled
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
              ).withValues(alpha: enabled ? 0.18 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: AppIcons.icon(
                  AppIcons.deviceLink,
                  size: 18,
                  color: contentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: contentColor,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: const Offset(6, 0),
                  child: AppIcons.icon(
                    AppIcons.arrowRight,
                    size: 16,
                    color: contentColor.withValues(alpha: enabled ? 0.55 : 0.7),
                  ),
                ),
                AppIcons.icon(
                  AppIcons.arrowRight,
                  size: 16,
                  color: contentColor.withValues(alpha: enabled ? 0.85 : 0.9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanelContent(SignalMode signalMode) {
    final isResonanceMode = signalMode == SignalMode.resonance;
    final isPresetMode = signalMode == SignalMode.preset;

    return LayoutBuilder(
      builder: (context, constraints) {
        const fixedHeaderHeight = 68.0;
        final cardMinHeight = math.max(
          0.0,
          constraints.maxHeight - fixedHeaderHeight,
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
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
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: cardMinHeight),
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
                          svgPath: AppIcons.swing,
                          value: _swingLevel,
                          enabled: isPresetMode,
                          onChanged: (value) {
                            setState(() => _swingLevel = value);
                            _sendPresetSignal();
                          },
                        ),
                        const SizedBox(height: 26),
                        _buildPresetSection(
                          title: '震动',
                          svgPath: AppIcons.vibration,
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
          ),
        );
      },
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
        const Text('使用预设', style: TextStyle(fontSize: 16, color: Colors.black)),
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
    required String svgPath,
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
                  child: Center(
                    child: AppIcons.icon(
                      svgPath,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
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
    _snapDevicePanel(
      _DevicePanelSnap.expanded,
      bottomInset: MediaQuery.of(context).padding.bottom,
    );
  }

  void _closeControlPanel() {
    _snapDevicePanel(
      _DevicePanelSnap.preview,
      bottomInset: MediaQuery.of(context).padding.bottom,
    );
  }

  double _collapsedPanelHeight(double bottomInset) => 63 + bottomInset;

  double _previewPanelHeight(double bottomInset) => 130 + bottomInset;

  double _expandedPanelHeight(double bottomInset) =>
      math.min(MediaQuery.of(context).size.height * 0.66, 541).toDouble() +
      bottomInset;

  double _resolvedDevicePanelHeight({
    required double collapsedPanelHeight,
    required double expandedPanelHeight,
  }) {
    final current = _devicePanelHeight ?? collapsedPanelHeight;
    return current.clamp(collapsedPanelHeight, expandedPanelHeight).toDouble();
  }

  double _devicePanelProgress({
    required double panelHeight,
    required double collapsedHeight,
    required double expandedHeight,
  }) {
    if (expandedHeight <= collapsedHeight) return 0;
    return ((panelHeight - collapsedHeight) /
            (expandedHeight - collapsedHeight))
        .clamp(0.0, 1.0);
  }

  void _snapDevicePanel(_DevicePanelSnap snap, {required double bottomInset}) {
    final target = switch (snap) {
      _DevicePanelSnap.collapsed => _collapsedPanelHeight(bottomInset),
      _DevicePanelSnap.preview => _previewPanelHeight(bottomInset),
      _DevicePanelSnap.expanded => _expandedPanelHeight(bottomInset),
    };

    setState(() {
      _isDraggingDevicePanel = false;
      _devicePanelHeight = target;
    });
  }

  void _handleDevicePanelDragUpdate(
    DragUpdateDetails details, {
    required double bottomInset,
  }) {
    final minHeight = _collapsedPanelHeight(bottomInset);
    final maxHeight = _expandedPanelHeight(bottomInset);
    final current = _resolvedDevicePanelHeight(
      collapsedPanelHeight: minHeight,
      expandedPanelHeight: maxHeight,
    );

    setState(() {
      _isDraggingDevicePanel = true;
      _devicePanelHeight = (current - details.delta.dy).clamp(
        minHeight,
        maxHeight,
      );
    });
  }

  void _handleDevicePanelDragEnd(
    DragEndDetails details, {
    required double bottomInset,
  }) {
    final collapsedHeight = _collapsedPanelHeight(bottomInset);
    final previewHeight = _previewPanelHeight(bottomInset);
    final expandedHeight = _expandedPanelHeight(bottomInset);
    final current = _resolvedDevicePanelHeight(
      collapsedPanelHeight: collapsedHeight,
      expandedPanelHeight: expandedHeight,
    );
    final velocity = details.primaryVelocity ?? 0;

    if (velocity <= -650) {
      if (current < previewHeight - 8) {
        _snapDevicePanel(_DevicePanelSnap.preview, bottomInset: bottomInset);
      } else {
        _snapDevicePanel(_DevicePanelSnap.expanded, bottomInset: bottomInset);
      }
      return;
    }

    if (velocity >= 650) {
      if (current > previewHeight + 32) {
        _snapDevicePanel(_DevicePanelSnap.preview, bottomInset: bottomInset);
      } else {
        _snapDevicePanel(_DevicePanelSnap.collapsed, bottomInset: bottomInset);
      }
      return;
    }

    final candidates = <_DevicePanelSnap, double>{
      _DevicePanelSnap.collapsed: collapsedHeight,
      _DevicePanelSnap.preview: previewHeight,
      _DevicePanelSnap.expanded: expandedHeight,
    };

    final nearest = candidates.entries.reduce(
      (best, candidate) =>
          (candidate.value - current).abs() < (best.value - current).abs()
              ? candidate
              : best,
    );
    _snapDevicePanel(nearest.key, bottomInset: bottomInset);
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
                      subtitle: const Text('支持中日互译'),
                      value: translationEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged:
                          (value) =>
                              _setSubtitleTranslationEnabled(sheetRef, value),
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
                        leading: AppIcons.icon(
                          AppIcons.importIcon,
                          size: 24,
                          color: const Color(0xFF49454F),
                        ),
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

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({this.icon, required this.onTap});

  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF797979).withValues(alpha: 0.7),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF797979).withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

enum _DevicePanelSnap { collapsed, preview, expanded }
