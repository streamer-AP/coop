import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/bluetooth/models/ble_device.dart';
import '../../domain/models/device_binding.dart';
import 'controller_providers.dart';
import 'controller_ui_providers.dart';

class ControllerConnectionFlowState {
  const ControllerConnectionFlowState({
    this.devices = const [],
    this.deviceName = 'OMAO',
    this.batteryLevel = 0,
    this.connectionStatus = DeviceConnectionStatus.disconnected,
    this.isSearching = false,
    this.didTimeout = false,
    this.errorMessage,
    this.infoMessage,
    this.connectedDevice,
    this.pendingSingleDevice,
    this.connectingDeviceId,
    this.deviceSheetRequestToken = 0,
    this.isAwaitingDeviceSelection = false,
  });

  final List<BleDevice> devices;
  final String deviceName;
  final int batteryLevel;
  final DeviceConnectionStatus connectionStatus;
  final bool isSearching;
  final bool didTimeout;
  final String? errorMessage;
  final String? infoMessage;
  final BleDevice? connectedDevice;
  final BleDevice? pendingSingleDevice;
  final String? connectingDeviceId;
  final int deviceSheetRequestToken;
  final bool isAwaitingDeviceSelection;

  bool get hasMultipleDevices => devices.length > 1;

  bool get hasDevices => devices.isNotEmpty;

  bool get isConnected => connectionStatus == DeviceConnectionStatus.connected;

  bool get isConnecting =>
      connectionStatus == DeviceConnectionStatus.connecting;

  bool get hasPendingSingleDevice => pendingSingleDevice != null;

  bool get shouldKeepSearchContent =>
      isSearching ||
      hasDevices ||
      hasPendingSingleDevice ||
      isAwaitingDeviceSelection;

  ControllerConnectionFlowState copyWith({
    List<BleDevice>? devices,
    String? deviceName,
    int? batteryLevel,
    DeviceConnectionStatus? connectionStatus,
    bool? isSearching,
    bool? didTimeout,
    Object? errorMessage = _sentinel,
    Object? infoMessage = _sentinel,
    Object? connectedDevice = _sentinel,
    Object? pendingSingleDevice = _sentinel,
    Object? connectingDeviceId = _sentinel,
    int? deviceSheetRequestToken,
    bool? isAwaitingDeviceSelection,
  }) {
    return ControllerConnectionFlowState(
      devices: devices ?? this.devices,
      deviceName: deviceName ?? this.deviceName,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isSearching: isSearching ?? this.isSearching,
      didTimeout: didTimeout ?? this.didTimeout,
      errorMessage:
          identical(errorMessage, _sentinel)
              ? this.errorMessage
              : errorMessage as String?,
      infoMessage:
          identical(infoMessage, _sentinel)
              ? this.infoMessage
              : infoMessage as String?,
      connectedDevice:
          identical(connectedDevice, _sentinel)
              ? this.connectedDevice
              : connectedDevice as BleDevice?,
      pendingSingleDevice:
          identical(pendingSingleDevice, _sentinel)
              ? this.pendingSingleDevice
              : pendingSingleDevice as BleDevice?,
      connectingDeviceId:
          identical(connectingDeviceId, _sentinel)
              ? this.connectingDeviceId
              : connectingDeviceId as String?,
      deviceSheetRequestToken:
          deviceSheetRequestToken ?? this.deviceSheetRequestToken,
      isAwaitingDeviceSelection:
          isAwaitingDeviceSelection ?? this.isAwaitingDeviceSelection,
    );
  }
}

const _sentinel = Object();

final controllerConnectionFlowProvider = NotifierProvider<
  ControllerConnectionFlowController,
  ControllerConnectionFlowState
>(ControllerConnectionFlowController.new);

class ControllerConnectionFlowController
    extends Notifier<ControllerConnectionFlowState> {
  StreamSubscription<List<BleDevice>>? _scanSub;
  StreamSubscription<BleConnectionState>? _connectionSub;
  StreamSubscription<Map<String, dynamic>>? _deviceInfoSub;
  Timer? _firstDeviceWindowTimer;
  Timer? _timeoutTimer;

  @override
  ControllerConnectionFlowState build() {
    final manager = ref.read(bleConnectionManagerProvider);
    final cachedInfo = manager.lastDeviceInfo;
    final initialConnectedDevice =
        manager.isConnected ? manager.connectedDevice : null;

    _connectionSub?.cancel();
    _deviceInfoSub?.cancel();

    _connectionSub = manager.connectionStateStream.listen(
      _handleConnectionState,
    );
    _deviceInfoSub = manager.deviceInfoStream.listen(_handleDeviceInfo);

    ref.onDispose(() {
      _scanSub?.cancel();
      _connectionSub?.cancel();
      _deviceInfoSub?.cancel();
      _firstDeviceWindowTimer?.cancel();
      _timeoutTimer?.cancel();
    });

    Future<void>.microtask(_loadActiveBinding);

    return ControllerConnectionFlowState(
      deviceName:
          (cachedInfo['deviceName'] as String?) ??
          initialConnectedDevice?.name ??
          'OMAO',
      batteryLevel: (cachedInfo['batteryLevel'] as int?) ?? 0,
      connectionStatus:
          manager.isConnected
              ? DeviceConnectionStatus.connected
              : DeviceConnectionStatus.disconnected,
      connectedDevice: initialConnectedDevice,
    );
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final manager = ref.read(bleConnectionManagerProvider);

    await _stopScanInternal(
      clearDevices: true,
      stopManagerScan: true,
      clearPendingSingleDevice: true,
      nextStatus: DeviceConnectionStatus.connecting,
    );

    state = state.copyWith(
      isSearching: true,
      didTimeout: false,
      errorMessage: null,
      infoMessage: null,
      devices: const [],
      pendingSingleDevice: null,
      connectingDeviceId: null,
      isAwaitingDeviceSelection: false,
      connectionStatus: DeviceConnectionStatus.connecting,
    );

    _timeoutTimer = Timer(timeout, () {
      if (!state.isSearching ||
          state.hasDevices ||
          state.isConnecting == false) {
        return;
      }
      state = state.copyWith(
        isSearching: false,
        didTimeout: true,
        connectionStatus: DeviceConnectionStatus.disconnected,
      );
    });

    _scanSub = manager
        .scanDevices(timeout: timeout)
        .listen(
          _handleDiscoveredDevices,
          onError: (Object error, StackTrace stackTrace) {
            state = state.copyWith(
              isSearching: false,
              connectionStatus: DeviceConnectionStatus.disconnected,
              errorMessage: '扫描失败，请重试',
            );
          },
        );
  }

  Future<void> connectPendingSingleDevice() async {
    final device = state.pendingSingleDevice;
    if (device == null) {
      return;
    }
    await connectDevice(device);
  }

  Future<void> stopScan({bool clearDevices = true}) {
    return _stopScanInternal(
      clearDevices: clearDevices,
      stopManagerScan: true,
      clearPendingSingleDevice: true,
      nextStatus:
          state.isConnected
              ? DeviceConnectionStatus.connected
              : DeviceConnectionStatus.disconnected,
    );
  }

  Future<void> cancelDeviceSelection() {
    return _stopScanInternal(
      clearDevices: true,
      stopManagerScan: true,
      clearPendingSingleDevice: true,
      nextStatus:
          state.isConnected
              ? DeviceConnectionStatus.connected
              : DeviceConnectionStatus.disconnected,
    ).then((_) {
      state = state.copyWith(isAwaitingDeviceSelection: false);
    });
  }

  Future<void> connectDevice(BleDevice device) async {
    if (state.isConnecting && state.connectingDeviceId == device.id) {
      return;
    }

    final manager = ref.read(bleConnectionManagerProvider);
    await _stopScanInternal(
      clearDevices: false,
      stopManagerScan: true,
      clearPendingSingleDevice: true,
      nextStatus: DeviceConnectionStatus.connecting,
    );

    state = state.copyWith(
      connectionStatus: DeviceConnectionStatus.connecting,
      errorMessage: null,
      infoMessage: null,
      didTimeout: false,
      deviceName: device.name,
      connectingDeviceId: device.id,
      isAwaitingDeviceSelection: false,
    );

    try {
      await manager.connect(device);

      await ref
          .read(controllerRepositoryProvider)
          .saveDeviceBinding(
            DeviceBinding(
              deviceId: device.id,
              deviceName: device.name,
              boundAt: DateTime.now(),
            ),
          );
      ref.invalidate(activeDeviceBindingProvider);
      ref.read(controllerStateNotifierProvider.notifier).resetIntensities();

      state = state.copyWith(
        isSearching: false,
        connectionStatus: DeviceConnectionStatus.connected,
        connectedDevice: device,
        deviceName: device.name,
        devices: const [],
        connectingDeviceId: null,
        pendingSingleDevice: null,
        isAwaitingDeviceSelection: false,
      );
    } catch (_) {
      state = state.copyWith(
        isSearching: false,
        connectionStatus: DeviceConnectionStatus.disconnected,
        connectingDeviceId: null,
        errorMessage: '连接失败，请重试',
      );
    }
  }

  Future<void> disconnect() async {
    await _stopScanInternal(
      clearDevices: false,
      stopManagerScan: true,
      clearPendingSingleDevice: true,
      nextStatus: DeviceConnectionStatus.connecting,
    );
    await ref.read(bleConnectionManagerProvider).disconnect();
  }

  void clearTimeoutFlag() {
    if (!state.didTimeout) {
      return;
    }
    state = state.copyWith(didTimeout: false);
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = state.copyWith(errorMessage: null);
  }

  void clearInfo() {
    if (state.infoMessage == null) {
      return;
    }
    state = state.copyWith(infoMessage: null);
  }

  void _handleDiscoveredDevices(List<BleDevice> devices) {
    final sortedDevices = [...devices]
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    state = state.copyWith(devices: sortedDevices, isSearching: true);

    if (sortedDevices.isEmpty) {
      return;
    }

    if (_firstDeviceWindowTimer == null) {
      _firstDeviceWindowTimer = Timer(
        const Duration(seconds: 2),
        _handleSingleDeviceWindowElapsed,
      );
      return;
    }

    if (sortedDevices.length > 1) {
      _presentMultipleDeviceSelection(sortedDevices);
    }
  }

  void _handleSingleDeviceWindowElapsed() {
    _firstDeviceWindowTimer?.cancel();
    _firstDeviceWindowTimer = null;

    if (!state.isSearching ||
        state.devices.isEmpty ||
        state.hasMultipleDevices) {
      return;
    }

    unawaited(connectDevice(state.devices.first));
  }

  void _presentMultipleDeviceSelection(List<BleDevice> devices) {
    _firstDeviceWindowTimer?.cancel();
    _firstDeviceWindowTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _scanSub?.cancel();
    _scanSub = null;
    unawaited(ref.read(bleConnectionManagerProvider).stopScan());

    state = state.copyWith(
      devices: devices,
      isSearching: false,
      pendingSingleDevice: null,
      isAwaitingDeviceSelection: true,
      deviceSheetRequestToken: state.deviceSheetRequestToken + 1,
      connectionStatus: DeviceConnectionStatus.connecting,
    );
  }

  Future<void> _loadActiveBinding() async {
    final binding =
        await ref.read(controllerRepositoryProvider).getActiveDeviceBinding();
    if (binding == null || state.isConnected) {
      return;
    }

    state = state.copyWith(deviceName: binding.deviceName);
  }

  void _handleConnectionState(BleConnectionState connectionState) {
    switch (connectionState) {
      case BleConnectionState.connected:
        final connectedDevice =
            ref.read(bleConnectionManagerProvider).connectedDevice;
        state = state.copyWith(
          connectionStatus: DeviceConnectionStatus.connected,
          connectedDevice: connectedDevice,
          deviceName: connectedDevice?.name ?? state.deviceName,
          devices: const [],
          connectingDeviceId: null,
          pendingSingleDevice: null,
          isAwaitingDeviceSelection: false,
        );
        return;
      case BleConnectionState.connecting:
        state = state.copyWith(
          connectionStatus: DeviceConnectionStatus.connecting,
        );
        return;
      case BleConnectionState.disconnected:
        state = state.copyWith(
          connectionStatus: DeviceConnectionStatus.disconnected,
          connectedDevice: null,
          isSearching: false,
          devices: const [],
          pendingSingleDevice: null,
          connectingDeviceId: null,
          isAwaitingDeviceSelection: false,
        );
        return;
      case BleConnectionState.disconnecting:
        state = state.copyWith(
          connectionStatus: DeviceConnectionStatus.connecting,
        );
        return;
    }
  }

  void _handleDeviceInfo(Map<String, dynamic> info) {
    state = state.copyWith(
      deviceName: (info['deviceName'] as String?) ?? state.deviceName,
      batteryLevel: (info['batteryLevel'] as int?) ?? state.batteryLevel,
    );
  }

  Future<void> _stopScanInternal({
    required bool clearDevices,
    required bool stopManagerScan,
    required bool clearPendingSingleDevice,
    DeviceConnectionStatus? nextStatus,
  }) async {
    _scanSub?.cancel();
    _scanSub = null;
    _firstDeviceWindowTimer?.cancel();
    _firstDeviceWindowTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    if (stopManagerScan) {
      await ref.read(bleConnectionManagerProvider).stopScan();
    }

    state = state.copyWith(
      isSearching: false,
      devices: clearDevices ? const [] : state.devices,
      pendingSingleDevice:
          clearPendingSingleDevice ? null : state.pendingSingleDevice,
      connectionStatus: nextStatus ?? state.connectionStatus,
      connectingDeviceId:
          nextStatus == DeviceConnectionStatus.connecting
              ? state.connectingDeviceId
              : null,
    );
  }
}
