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

class BleScanException implements Exception {
  const BleScanException(this.message);

  final String message;

  @override
  String toString() => message;
}

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
  Map<String, dynamic> _lastDeviceInfo = <String, dynamic>{};

  Stream<BleConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// 设备上报信息流（电池、档位等）
  Stream<Map<String, dynamic>> get deviceInfoStream =>
      _deviceInfoController.stream;

  BleDevice? get connectedDevice => _currentDevice;

  bool get isConnected => _connectedDevice != null;

  Map<String, dynamic> get lastDeviceInfo =>
      Map<String, dynamic>.unmodifiable(_lastDeviceInfo);

  // /// 扫描附近的 OMAO 设备
  // Stream<List<BleDevice>> scanDevices({
  //   Duration timeout = const Duration(seconds: 10),
  // }) {
  //   final discoveredDevices = <String, BleDevice>{};
  //   final controller = StreamController<List<BleDevice>>();
  //
  //   FlutterBluePlus.startScan(
  //     timeout: timeout,
  //     androidUsesFineLocation: true,
  //   );
  //
  //   final scanSub = FlutterBluePlus.scanResults.listen((results) {
  //     for (final r in results) {
  //       if (!_isTargetDevice(r)) continue;
  //
  //       final deviceName = r.advertisementData.advName.isNotEmpty
  //           ? r.advertisementData.advName
  //           : r.device.platformName;
  //
  //       if (deviceName.isEmpty) continue;
  //
  //       discoveredDevices[r.device.remoteId.str] = BleDevice(
  //         id: r.device.remoteId.str,
  //         name: deviceName,
  //         rssi: r.rssi,
  //       );
  //       controller.add(discoveredDevices.values.toList());
  //     }
  //   });
  //
  //   FlutterBluePlus.isScanning.listen((scanning) {
  //     if (!scanning) {
  //       scanSub.cancel();
  //       controller.close();
  //     }
  //   });
  //
  //   return controller.stream;
  // }

  /// 扫描附近的 OMAO 设备,修复首次无法连接蓝牙
  Stream<List<BleDevice>> scanDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async* {
    final discoveredDevices = <String, BleDevice>{};
    final controller = StreamController<List<BleDevice>>();
    StreamSubscription<List<ScanResult>>? scanSub;
    StreamSubscription<bool>? scanStateSub;

    Future<void> cancelSubscriptions() async {
      await scanSub?.cancel();
      await scanStateSub?.cancel();
      scanSub = null;
      scanStateSub = null;
    }

    Future<void> closeController() async {
      if (!controller.isClosed) {
        await controller.close();
      }
    }

    controller.onCancel = () async {
      await cancelSubscriptions();
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    };

    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        throw const BleScanException('当前设备不支持蓝牙');
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw const BleScanException('请先开启蓝牙');
      }

      await FlutterBluePlus.stopScan();

      scanSub = FlutterBluePlus.onScanResults.listen(
        (results) {
          for (final result in results) {
            if (!_isTargetDevice(result)) {
              continue;
            }

            final deviceName =
                result.advertisementData.advName.isNotEmpty
                    ? result.advertisementData.advName
                    : result.device.platformName;

            if (deviceName.isEmpty) {
              continue;
            }

            discoveredDevices[result.device.remoteId.str] = BleDevice(
              id: result.device.remoteId.str,
              name: deviceName,
              rssi: result.rssi,
            );
            controller.add(discoveredDevices.values.toList());
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          AppLogger().error(
            '$_tag: scan stream failed',
            error: error,
            stackTrace: stackTrace,
          );
          controller.addError(error, stackTrace);
          unawaited(closeController());
        },
      );

      var hasStartedScanning = false;
      scanStateSub = FlutterBluePlus.isScanning.listen((scanning) {
        if (scanning) {
          hasStartedScanning = true;
          return;
        }

        if (!hasStartedScanning) {
          return;
        }

        unawaited(cancelSubscriptions());
        unawaited(closeController());
      });

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );
    } catch (error, stackTrace) {
      AppLogger().error(
        '$_tag: start scan failed',
        error: error,
        stackTrace: stackTrace,
      );
      controller.addError(error, stackTrace);
      await cancelSubscriptions();
      await closeController();
    }

    try {
      yield* controller.stream;
    } finally {
      await cancelSubscriptions();
    }
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
      _lastDeviceInfo = {'deviceName': device.name};

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
      _lastDeviceInfo = <String, dynamic>{};
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
    if (_connectedDevice == null || _writeCharacteristic == null) {
      AppLogger().warning(
        '$_tag: skip write payload=${payload.toList()} '
        'connected=${_connectedDevice != null} '
        'hasWriteCharacteristic=${_writeCharacteristic != null}',
      );
      return;
    }

    try {
      final writeCharacteristic = _writeCharacteristic!;
      final withoutResponse =
          writeCharacteristic.properties.writeWithoutResponse;
      AppLogger().debug(
        '$_tag: write payload=${payload.toList()} '
        'char=${writeCharacteristic.uuid.str} '
        'withoutResponse=$withoutResponse '
        'write=${writeCharacteristic.properties.write} '
        'writeWithoutResponse=${writeCharacteristic.properties.writeWithoutResponse}',
      );
      await writeCharacteristic.write(
        payload.toList(),
        withoutResponse: withoutResponse,
      );
    } catch (e, stackTrace) {
      AppLogger().error(
        '$_tag: write failed',
        error: e,
        stackTrace: stackTrace,
      );
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
    final name =
        result.advertisementData.advName.isNotEmpty
            ? result.advertisementData.advName
            : result.device.platformName;

    if (name.isEmpty) return false;

    final trimmedName = name.trim();
    final nameMatch = BleDeviceProtocol.targetNamePrefixes.any(
      (prefix) => trimmedName.startsWith(prefix),
    );

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
    _writeCharacteristic = null;
    _notifyCharacteristic = null;

    for (final service in services) {
      for (final char in service.characteristics) {
        final uuid = char.uuid.str128.toUpperCase();

        if (_matchesUuid(uuid, BleDeviceProtocol.writeCharacteristicUuid)) {
          _writeCharacteristic = char;
        }
        if (_matchesUuid(uuid, BleDeviceProtocol.notifyCharacteristicUuid)) {
          _notifyCharacteristic = char;
        }
      }
    }

    if (_notifyCharacteristic != null) {
      try {
        await _notifyCharacteristic!.setNotifyValue(true);
        _notifySub = _notifyCharacteristic!.lastValueStream.listen(
          _onCharacteristicNotified,
        );
      } catch (e, stackTrace) {
        AppLogger().warning(
          '$_tag: notify setup failed, continue without notify',
        );
        AppLogger().error(
          '$_tag: notify setup failed',
          error: e,
          stackTrace: stackTrace,
        );
        _notifyCharacteristic = null;
      }
    }

    _readDeviceInfo(services);
  }

  void _readDeviceInfo(List<BluetoothService> services) {
    for (final service in services) {
      for (final char in service.characteristics) {
        final uuid = char.uuid.str128.toUpperCase();

        if (_matchesUuid(uuid, BleDeviceProtocol.batteryCharacteristicUuid) ||
            _matchesUuid(
              uuid,
              BleDeviceProtocol.deviceNameCharacteristicUuid,
            ) ||
            _matchesUuid(
              uuid,
              BleDeviceProtocol.vibrationTypeCharacteristicUuid,
            ) ||
            _matchesUuid(
              uuid,
              BleDeviceProtocol.remainingTimeCharacteristicUuid,
            ) ||
            _matchesUuid(
              uuid,
              BleDeviceProtocol.controlSourceCharacteristicUuid,
            )) {
          if (char.properties.read) {
            char
                .read()
                .then((value) {
                  _handleCharacteristicValue(uuid, value);
                })
                .catchError((_) {});
          }
          if (char.properties.notify) {
            char
                .setNotifyValue(true)
                .then((_) {
                  char.lastValueStream.listen((value) {
                    _handleCharacteristicValue(uuid, value);
                  });
                })
                .catchError((_) {});
          }
        }
      }
    }
  }

  bool _matchesUuid(String actualUuid, String expectedUuid) {
    return actualUuid.toUpperCase() == expectedUuid.toUpperCase();
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
      _lastDeviceInfo = {..._lastDeviceInfo, ...info};
      _deviceInfoController.add(Map<String, dynamic>.from(_lastDeviceInfo));
    }
  }

  void _onCharacteristicNotified(List<int> value) {
    _handleCharacteristicValue(
      BleDeviceProtocol.notifyCharacteristicUuid.toUpperCase(),
      value,
    );
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
