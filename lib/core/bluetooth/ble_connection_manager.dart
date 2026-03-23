import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logging/app_logger.dart';
import 'ble_device_protocol.dart';
import 'models/ble_device.dart';

part 'ble_connection_manager.g.dart';

enum BleConnectionState { disconnected, connecting, connected, disconnecting }

/// Manages BLE scanning, connection, and disconnection.
class BleConnectionManager {
  static const _tag = 'BleConnectionManager';

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;

  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();
  final _deviceInfoController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<List<int>>? _notifySub;

  BleDevice? _currentDevice;

  Stream<BleConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// 设备上报信息流（电池、档位等）
  Stream<Map<String, dynamic>> get deviceInfoStream =>
      _deviceInfoController.stream;

  BleDevice? get connectedDevice => _currentDevice;

  bool get isConnected => _connectedDevice != null;

  /// 扫描附近的 OMAO 设备
  Stream<List<BleDevice>> scanDevices({
    Duration timeout = const Duration(seconds: 10),
  }) {
    final discoveredDevices = <String, BleDevice>{};
    final controller = StreamController<List<BleDevice>>();

    FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );

    final scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (!_isTargetDevice(r)) continue;

        final deviceName = r.advertisementData.advName.isNotEmpty
            ? r.advertisementData.advName
            : r.device.platformName;

        if (deviceName.isEmpty) continue;

        discoveredDevices[r.device.remoteId.str] = BleDevice(
          id: r.device.remoteId.str,
          name: deviceName,
          rssi: r.rssi,
        );
        controller.add(discoveredDevices.values.toList());
      }
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning) {
        scanSub.cancel();
        controller.close();
      }
    });

    return controller.stream;
  }

  /// 停止扫描
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// 连接指定设备
  Future<void> connect(BleDevice device) async {
    _connectionStateController.add(BleConnectionState.connecting);
    AppLogger().info('$_tag: connecting to ${device.name} (${device.id})');

    try {
      final btDevice = BluetoothDevice.fromId(device.id);

      await btDevice.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );

      _connectedDevice = btDevice;
      _currentDevice = device.copyWith(isConnected: true);

      _connectionSub = btDevice.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      await _discoverAndSetupServices(btDevice);

      _connectionStateController.add(BleConnectionState.connected);
      AppLogger().info('$_tag: connected to ${device.name}');
    } catch (e) {
      AppLogger().error('$_tag: connection failed', error: e);
      _connectedDevice = null;
      _currentDevice = null;
      _connectionStateController.add(BleConnectionState.disconnected);
      rethrow;
    }
  }

  /// 断开当前连接
  Future<void> disconnect() async {
    if (_connectedDevice == null) return;
    _connectionStateController.add(BleConnectionState.disconnecting);
    AppLogger().info('$_tag: disconnecting');

    try {
      await _notifySub?.cancel();
      _notifySub = null;
      await _connectedDevice?.disconnect();
    } catch (e) {
      AppLogger().error('$_tag: disconnect error', error: e);
    } finally {
      _onDisconnected();
    }
  }

  /// 写入原始蓝牙负载
  Future<void> writePayload(Uint8List payload) async {
    if (_connectedDevice == null || _writeCharacteristic == null) return;

    try {
      await _writeCharacteristic!.write(
        payload.toList(),
        withoutResponse: true,
      );
    } catch (e) {
      AppLogger().error('$_tag: write failed', error: e);
    }
  }

  void dispose() {
    _connectionSub?.cancel();
    _notifySub?.cancel();
    _connectedDevice?.disconnect();
    _connectionStateController.close();
    _deviceInfoController.close();
  }

  bool _isTargetDevice(ScanResult result) {
    final name = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : result.device.platformName;

    if (name.isEmpty) return false;

    final trimmedName = name.trim();
    final nameMatch = BleDeviceProtocol.targetNamePrefixes
        .any((prefix) => trimmedName.startsWith(prefix));

    if (!nameMatch) return false;

    final mfgData = result.advertisementData.manufacturerData;
    if (mfgData.isNotEmpty) {
      final hasTargetMfg = mfgData.containsKey(
        BleDeviceProtocol.targetManufacturerId,
      );
      if (hasTargetMfg) return true;
    }

    return nameMatch;
  }

  Future<void> _discoverAndSetupServices(BluetoothDevice device) async {
    final services = await device.discoverServices();

    for (final service in services) {
      for (final char in service.characteristics) {
        final uuid = char.uuid.str.toUpperCase();

        if (uuid.startsWith('0000F320')) {
          _writeCharacteristic = char;
        }
        if (uuid.startsWith('0000F220')) {
          _notifyCharacteristic = char;
        }
      }
    }

    if (_notifyCharacteristic != null) {
      await _notifyCharacteristic!.setNotifyValue(true);
      _notifySub = _notifyCharacteristic!.lastValueStream.listen(
        _onCharacteristicNotified,
      );
    }

    _readDeviceInfo(services);
  }

  void _readDeviceInfo(List<BluetoothService> services) {
    for (final service in services) {
      for (final char in service.characteristics) {
        final uuid = char.uuid.str.toUpperCase();

        if (uuid.startsWith('00002A19') || // battery
            uuid.startsWith('00002A00') || // device name
            uuid.startsWith('0000F221') || // vibration type
            uuid.startsWith('0000F241') || // remaining time
            uuid.startsWith('0000F260')) {
          // control source
          if (char.properties.read) {
            char.read().then((value) {
              _handleCharacteristicValue(uuid, value);
            }).catchError((_) {});
          }
          if (char.properties.notify) {
            char.setNotifyValue(true).then((_) {
              char.lastValueStream.listen((value) {
                _handleCharacteristicValue(uuid, value);
              });
            }).catchError((_) {});
          }
        }
      }
    }
  }

  void _handleCharacteristicValue(String uuid, List<int> value) {
    if (value.isEmpty) return;

    final info = <String, dynamic>{};

    if (uuid.startsWith('00002A19')) {
      info['batteryLevel'] = value[0] & 0xFF;
    } else if (uuid.startsWith('00002A00')) {
      info['deviceName'] = String.fromCharCodes(value);
    } else if (uuid.startsWith('0000F220')) {
      info['currentGear'] = value;
    } else if (uuid.startsWith('0000F221')) {
      info['vibrationType'] = value[0] & 0xFF;
    } else if (uuid.startsWith('0000F241')) {
      info['remainingTime'] = value[0] & 0xFF;
    } else if (uuid.startsWith('0000F260')) {
      info['controlSource'] = value[0] & 0xFF;
    }

    if (info.isNotEmpty) {
      _deviceInfoController.add(info);
    }
  }

  void _onCharacteristicNotified(List<int> value) {
    _handleCharacteristicValue('0000F220', value);
  }

  void _onDisconnected() {
    AppLogger().info('$_tag: disconnected');
    _connectedDevice = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _currentDevice = _currentDevice?.copyWith(isConnected: false);
    _connectionSub?.cancel();
    _connectionSub = null;
    _notifySub?.cancel();
    _notifySub = null;
    _connectionStateController.add(BleConnectionState.disconnected);
  }
}

@Riverpod(keepAlive: true)
BleConnectionManager bleConnectionManager(Ref ref) {
  final manager = BleConnectionManager();
  ref.onDispose(manager.dispose);
  return manager;
}
