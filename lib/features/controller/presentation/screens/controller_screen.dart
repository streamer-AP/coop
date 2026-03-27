import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/controller_connection_flow.dart';
import '../../application/providers/controller_providers.dart';
import '../../application/providers/controller_ui_providers.dart'
    show DeviceConnectionStatus;
import '../../controller_assets.dart';
import '../../domain/models/favorite_slot.dart';
import '../../domain/models/waveform.dart';
import '../widgets/controller_device_connect_item.dart';
import '../widgets/controller_device_status_card.dart';
import '../widgets/controller_setting_card.dart';

class ControllerScreen extends ConsumerStatefulWidget {
  const ControllerScreen({super.key});

  @override
  ConsumerState<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends ConsumerState<ControllerScreen> {
  static const _backgroundAsset = ControllerAssets.blueConnectionBackground;
  static const _gradientAsset = ControllerAssets.gradientSliding;
  static const List<int> _strengthValues = [0, 33, 66, 100];

  bool _isDeviceSheetOpen = false;

  @override
  void initState() {
    super.initState();

    ref.listenManual<ControllerConnectionFlowState>(
      controllerConnectionFlowProvider,
          (previous, next) {
        final errorMessage = next.errorMessage;
        if (errorMessage != null &&
            errorMessage != previous?.errorMessage &&
            mounted) {
          TopBannerToast.show(context, message: errorMessage);
          ref.read(controllerConnectionFlowProvider.notifier).clearError();
        }

        final infoMessage = next.infoMessage;
        if (infoMessage != null &&
            infoMessage != previous?.infoMessage &&
            mounted) {
          TopBannerToast.show(context, message: infoMessage, isError: false);
          ref.read(controllerConnectionFlowProvider.notifier).clearInfo();
        }

        if (previous?.connectionStatus == DeviceConnectionStatus.connected &&
            next.connectionStatus == DeviceConnectionStatus.disconnected &&
            mounted) {
          TopBannerToast.show(context, message: '蓝牙已断开', isError: false);
        }

        if (next.deviceSheetRequestToken != previous?.deviceSheetRequestToken &&
            next.deviceSheetRequestToken > 0 &&
            mounted) {
          unawaited(_showDeviceSheet());
        }
      },
    );

    unawaited(_requestDefaultWaveformConfigs());
  }

  Future<void> _requestDefaultWaveformConfigs() async {
    final apiClient = ref.read(apiClientProvider);

    try {
      await Future.wait([
        apiClient.get(ApiEndpoints.querySwing),
        apiClient.get(ApiEndpoints.queryVibration),
      ]);
    } catch (error, stackTrace) {
      AppLogger().warning(
        'ControllerScreen: preload default waveform configs failed',
      );
      AppLogger().error(
        'ControllerScreen: preload default waveform configs error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionFlow = ref.watch(controllerConnectionFlowProvider);
    final uiState = ref.watch(controllerStateNotifierProvider);
    final favoriteSlotsAsync = ref.watch(favoriteSlotsProvider);
    final waveformsAsync = ref.watch(waveformsProvider);

    return Scaffold(
      backgroundColor: ControllerAssets.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                _backgroundAsset,
                height: 360,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: ControllerDeviceStatusCard(
                    deviceName: connectionFlow.deviceName,
                    batteryLevel: connectionFlow.batteryLevel,
                    connectionStatus: connectionFlow.connectionStatus,
                    onConnectionTap: () => _handleConnectionTap(connectionFlow),
                    onEditTap: () {},
                  ),
                ),
                Expanded(
                  child: favoriteSlotsAsync.when(
                    data:
                        (slots) => waveformsAsync.when(
                      data:
                          (waveforms) => _buildControlContent(
                        slots,
                        waveforms,
                        uiState,
                      ),
                      loading:
                          () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error:
                          (error, _) =>
                          Center(child: Text('波形加载失败：$error')),
                    ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('配置加载失败：$error')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlContent(
      List<FavoriteSlot> slots,
      List<Waveform> waveforms,
      ControllerUiState uiState,
      ) {
    final swingPages = _buildWaveformPages(
      WaveformChannel.swing,
      slots,
      waveforms,
    );
    final vibrationPages = _buildWaveformPages(
      WaveformChannel.vibration,
      slots,
      waveforms,
    );
    final swingSelection = _resolveSelection(
      channel: WaveformChannel.swing,
      selectedWaveform: uiState.selectedSwingWaveform,
      slots: slots,
    );
    final vibrationSelection = _resolveSelection(
      channel: WaveformChannel.vibration,
      selectedWaveform: uiState.selectedVibrationWaveform,
      slots: slots,
    );

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              ControllerSettingCard(
                title: '摆摇设置',
                headerIconAsset: ControllerAssets.swingTag,
                waveformIconAsset: ControllerAssets.swingItemTag,
                waveformPages: swingPages,
                selectedPageIndex: swingSelection.pageIndex,
                selectedItemIndex: swingSelection.itemIndex,
                strengthIndex: _strengthIndexFromValue(uiState.swingIntensity),
                onWaveformSelected:
                    (pageIndex, itemIndex) => _selectWaveform(
                  channel: WaveformChannel.swing,
                  pageIndex: pageIndex,
                  itemIndex: itemIndex,
                  slots: slots,
                  waveforms: waveforms,
                ),
                onStrengthChanged:
                    (index) => ref
                    .read(controllerStateNotifierProvider.notifier)
                    .setSwingIntensity(_strengthValues[index]),
                onSettingsTap: () {},
              ),
              const SizedBox(height: 18),
              ControllerSettingCard(
                title: '震动设置',
                headerIconAsset: ControllerAssets.vibratingTag,
                waveformIconAsset: ControllerAssets.vibratingItemTag,
                waveformPages: vibrationPages,
                selectedPageIndex: vibrationSelection.pageIndex,
                selectedItemIndex: vibrationSelection.itemIndex,
                strengthIndex: _strengthIndexFromValue(
                  uiState.vibrationIntensity,
                ),
                onWaveformSelected:
                    (pageIndex, itemIndex) => _selectWaveform(
                  channel: WaveformChannel.vibration,
                  pageIndex: pageIndex,
                  itemIndex: itemIndex,
                  slots: slots,
                  waveforms: waveforms,
                ),
                onStrengthChanged:
                    (index) => ref
                    .read(controllerStateNotifierProvider.notifier)
                    .setVibrationIntensity(_strengthValues[index]),
                onSettingsTap: () {},
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Image.asset(_gradientAsset, height: 40, fit: BoxFit.fill),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const Text(
              '控制',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConnectionTap(
      ControllerConnectionFlowState connectionFlow,
      ) async {
    final notifier = ref.read(controllerConnectionFlowProvider.notifier);

    if (connectionFlow.isConnected) {
      await notifier.disconnect();
      return;
    }

    if (connectionFlow.isConnecting) {
      return;
    }

    await notifier.startScan();
  }

  Future<void> _showDeviceSheet() async {
    if (_isDeviceSheetOpen || !mounted) {
      return;
    }

    _isDeviceSheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ControllerDeviceSheet(),
    );
    _isDeviceSheetOpen = false;

    final notifier = ref.read(controllerConnectionFlowProvider.notifier);
    final latestState = ref.read(controllerConnectionFlowProvider);
    if (!latestState.isConnected && latestState.isAwaitingDeviceSelection) {
      await notifier.cancelDeviceSelection();
    }
  }

  void _selectWaveform({
    required WaveformChannel channel,
    required int pageIndex,
    required int itemIndex,
    required List<FavoriteSlot> slots,
    required List<Waveform> waveforms,
  }) {
    final selectedSlot = _findSlot(
      channel: channel,
      pageIndex: pageIndex,
      itemIndex: itemIndex,
      slots: slots,
    );
    AppLogger().debug(
      'channel=${channel.name}, pageIndex=$pageIndex, itemIndex=$itemIndex, '
      'slots=${slots[0].toString()}, waveforms=${waveforms[0].keyframes}',
    );
    if (selectedSlot == null) {
      return;
    }

    final waveform = _findWaveform(selectedSlot.waveformId, waveforms);
    if (waveform == null) {
      return;
    }

    final notifier = ref.read(controllerStateNotifierProvider.notifier);
    if (channel == WaveformChannel.swing) {
      notifier.selectSwingWaveform(waveform);
      return;
    }
    notifier.selectVibrationWaveform(waveform);
  }

  List<List<ControllerWaveformItemData>> _buildWaveformPages(
      WaveformChannel channel,
      List<FavoriteSlot> slots,
      List<Waveform> waveforms,
      ) {
    return List.generate(3, (pageIndex) {
      final pageSlots =
      slots
          .where(
            (slot) => slot.channel == channel && slot.page == pageIndex,
      )
          .toList()
        ..sort((a, b) => a.index.compareTo(b.index));

      return pageSlots.map((slot) {
        final waveform = _findWaveform(slot.waveformId, waveforms);
        return ControllerWaveformItemData(name: waveform?.name ?? '未命名波形');
      }).toList();
    });
  }

  _WaveformSelection _resolveSelection({
    required WaveformChannel channel,
    required Waveform? selectedWaveform,
    required List<FavoriteSlot> slots,
  }) {
    if (selectedWaveform == null) {
      return const _WaveformSelection(pageIndex: 0, itemIndex: 0);
    }

    for (final slot in slots) {
      if (slot.channel == channel && slot.waveformId == selectedWaveform.id) {
        return _WaveformSelection(pageIndex: slot.page, itemIndex: slot.index);
      }
    }

    return const _WaveformSelection(pageIndex: 0, itemIndex: 0);
  }

  FavoriteSlot? _findSlot({
    required WaveformChannel channel,
    required int pageIndex,
    required int itemIndex,
    required List<FavoriteSlot> slots,
  }) {
    for (final slot in slots) {
      if (slot.channel == channel &&
          slot.page == pageIndex &&
          slot.index == itemIndex) {
        return slot;
      }
    }
    return null;
  }

  Waveform? _findWaveform(int waveformId, List<Waveform> waveforms) {
    for (final waveform in waveforms) {
      if (waveform.id == waveformId) {
        return waveform;
      }
    }
    return null;
  }

  int _strengthIndexFromValue(int value) {
    if (value <= 0) {
      return 0;
    }
    if (value <= 33) {
      return 1;
    }
    if (value <= 66) {
      return 2;
    }
    return 3;
  }
}

class _ControllerDeviceSheet extends ConsumerWidget {
  const _ControllerDeviceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionFlow = ref.watch(controllerConnectionFlowProvider);

    if (connectionFlow.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '发现其他设备',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      color: ControllerAssets.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (!connectionFlow.hasMultipleDevices &&
                !connectionFlow.isConnecting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        '正在搜索设备...',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: connectionFlow.devices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final device = connectionFlow.devices[index];
                    return ControllerDeviceConnectItem(
                      device: device,
                      isConnecting:
                      connectionFlow.connectingDeviceId == device.id,
                      onConnect:
                          () => ref
                          .read(controllerConnectionFlowProvider.notifier)
                          .connectDevice(device),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _WaveformSelection {
  const _WaveformSelection({required this.pageIndex, required this.itemIndex});

  final int pageIndex;
  final int itemIndex;
}
