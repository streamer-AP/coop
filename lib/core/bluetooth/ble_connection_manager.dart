import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'models/ble_device.dart';

part 'ble_connection_manager.g.dart';

/// Manages BLE scanning, connection, and disconnection.
class BleConnectionManager {
  BluetoothDevice? _connectedDevice;

  Stream<List<BleDevice>> scanDevices() {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<void> connect(BleDevice device) async {
    // TODO: implement
  }

  Future<void> disconnect() async {
    // TODO: implement
  }

  bool get isConnected => _connectedDevice != null;
}

@Riverpod(keepAlive: true)
BleConnectionManager bleConnectionManager(Ref ref) {
  return BleConnectionManager();
}
