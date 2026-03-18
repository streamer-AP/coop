import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/bluetooth/models/ble_device.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/controller_providers.dart';
import '../../domain/models/device_binding.dart';
import '../../domain/models/favorite_slot.dart';
import '../../domain/models/waveform.dart';
import '../widgets/device_card.dart';
import '../widgets/intensity_slider.dart';
import '../widgets/waveform_grid.dart';

class ControllerScreen extends ConsumerStatefulWidget {
  const ControllerScreen({super.key});

  @override
  ConsumerState<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends ConsumerState<ControllerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(controllerStateNotifierProvider.notifier)
            .selectPage(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final uiState = ref.watch(controllerStateNotifierProvider);
    final favoriteSlotsAsync = ref.watch(favoriteSlotsProvider);
    final waveformsAsync = ref.watch(waveformsProvider);
    final connectedDevice =
        ref.watch(bleConnectionManagerProvider).connectedDevice;

    return Scaffold(
      appBar: AppBar(title: const Text('控制器')),
      body: Column(
        children: [
          DeviceCard(
            device: connectedDevice,
            connectionState: connectionState.valueOrNull,
            onConnect: () => _showScanDialog(context),
            onDisconnect: () =>
                ref.read(bleConnectionManagerProvider).disconnect(),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '标签 1'),
              Tab(text: '标签 2'),
              Tab(text: '标签 3'),
            ],
          ),
          Expanded(
            child: favoriteSlotsAsync.when(
              data: (slots) => waveformsAsync.when(
                data: (allWaveforms) => _buildPageContent(
                  slots,
                  allWaveforms,
                  uiState,
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载波形失败: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载配置失败: $e')),
            ),
          ),
          _buildIntensityControls(uiState, connectionState.valueOrNull),
        ],
      ),
    );
  }

  Widget _buildPageContent(
    List<FavoriteSlot> allSlots,
    List<Waveform> allWaveforms,
    ControllerUiState uiState,
  ) {
    return TabBarView(
      controller: _tabController,
      children: List.generate(3, (page) {
        final swingSlots = allSlots
            .where((s) => s.channel == 'swing' && s.page == page)
            .toList();
        final vibrationSlots = allSlots
            .where((s) => s.channel == 'vibration' && s.page == page)
            .toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  '摇摆',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              WaveformGrid(
                page: page,
                channel: 'swing',
                slots: swingSlots,
                allWaveforms: allWaveforms,
                selectedWaveformId: uiState.selectedSwingWaveform?.id,
                onSelect: (waveform) {
                  ref
                      .read(controllerStateNotifierProvider.notifier)
                      .selectSwingWaveform(waveform);
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  '震动',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              WaveformGrid(
                page: page,
                channel: 'vibration',
                slots: vibrationSlots,
                allWaveforms: allWaveforms,
                selectedWaveformId: uiState.selectedVibrationWaveform?.id,
                onSelect: (waveform) {
                  ref
                      .read(controllerStateNotifierProvider.notifier)
                      .selectVibrationWaveform(waveform);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIntensityControls(
    ControllerUiState uiState,
    BleConnectionState? connState,
  ) {
    final isConnected = connState == BleConnectionState.connected;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntensitySlider(
            label: '摇摆',
            value: uiState.swingIntensity,
            enabled: isConnected,
            onChanged: (v) => ref
                .read(controllerStateNotifierProvider.notifier)
                .setSwingIntensity(v),
          ),
          const SizedBox(height: 12),
          IntensitySlider(
            label: '震动',
            value: uiState.vibrationIntensity,
            enabled: isConnected,
            onChanged: (v) => ref
                .read(controllerStateNotifierProvider.notifier)
                .setVibrationIntensity(v),
          ),
        ],
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _ScanSheet(),
    );
  }
}

class _ScanSheet extends ConsumerStatefulWidget {
  const _ScanSheet();

  @override
  ConsumerState<_ScanSheet> createState() => _ScanSheetState();
}

class _ScanSheetState extends ConsumerState<_ScanSheet> {
  bool _autoConnectPending = false;
  Timer? _autoConnectTimer;
  List<BleDevice> _devices = [];
  StreamSubscription? _scanSub;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _autoConnectTimer?.cancel();
    _scanSub?.cancel();
    ref.read(bleConnectionManagerProvider).stopScan();
    super.dispose();
  }

  void _startScan() {
    final manager = ref.read(bleConnectionManagerProvider);
    _autoConnectPending = false;
    _autoConnectTimer?.cancel();

    _scanSub = manager
        .scanDevices(timeout: const Duration(seconds: 10))
        .listen((devices) {
      if (!mounted) return;
      setState(() => _devices = devices);

      if (devices.length == 1 && !_autoConnectPending) {
        _autoConnectPending = true;
        _autoConnectTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          if (_devices.length == 1) {
            _connectDevice(_devices.first);
          }
        });
      }

      if (devices.length > 1) {
        _autoConnectTimer?.cancel();
        _autoConnectPending = false;
      }
    });
  }

  Future<void> _connectDevice(BleDevice device) async {
    if (_isConnecting) return;
    setState(() => _isConnecting = true);

    final manager = ref.read(bleConnectionManagerProvider);
    _scanSub?.cancel();
    await manager.stopScan();

    try {
      await manager.connect(device);

      final repo = ref.read(controllerRepositoryProvider);
      await repo.saveDeviceBinding(
        DeviceBinding(
          deviceId: device.id,
          deviceName: device.name,
          boundAt: DateTime.now(),
        ),
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('连接失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '搜索设备',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          if (_isConnecting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('正在连接...'),
                  ],
                ),
              ),
            )
          else if (_devices.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('正在搜索设备...'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.name),
                    subtitle: Text('信号: ${device.rssi} dBm'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _connectDevice(device),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
