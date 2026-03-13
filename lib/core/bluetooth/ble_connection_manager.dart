import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'models/ble_device.dart';

part 'ble_connection_manager.g.dart';

enum BleConnectionState { disconnected, connecting, connected, disconnecting }

/// Manages BLE scanning, connection, and disconnection.
class BleConnectionManager {
  BluetoothDevice? _connectedDevice;

  /// 当前连接状态的 Stream
  Stream<BleConnectionState> get connectionStateStream {
    // TODO: implement — 基于 flutter_blue_plus 连接状态映射
    throw UnimplementedError();
  }

  /// 当前连接的设备（null 表示未连接）
  BleDevice? get connectedDevice {
    // TODO: implement — 将 _connectedDevice 转为 BleDevice
    return null;
  }

  bool get isConnected => _connectedDevice != null;

  /// 扫描附近的 OMAO 设备
  Stream<List<BleDevice>> scanDevices({
    Duration timeout = const Duration(seconds: 10),
  }) {
    // TODO: implement — 使用 FlutterBluePlus.startScan，按 service UUID 过滤
    throw UnimplementedError();
  }

  /// 停止扫描
  Future<void> stopScan() async {
    // TODO: implement
    throw UnimplementedError();
  }

  /// 连接指定设备
  Future<void> connect(BleDevice device) async {
    // TODO: implement
  }

  /// 断开当前连接
  Future<void> disconnect() async {
    // TODO: implement
  }

  /// 释放资源
  void dispose() {
    // TODO: implement — 断开连接 + 取消订阅
  }
}

@Riverpod(keepAlive: true)
BleConnectionManager bleConnectionManager(Ref ref) {
  final manager = BleConnectionManager();
  ref.onDispose(manager.dispose);
  return manager;
}
