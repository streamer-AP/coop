import 'dart:typed_data';
import 'models/ble_signal.dart';

/// Encodes/decodes BLE device protocol messages.
class BleDeviceProtocol {
  /// Encodes a signal into bytes for BLE transmission.
  Uint8List encode(BleSignal signal) {
    // TODO: implement device-specific protocol
    throw UnimplementedError();
  }

  /// Decodes raw BLE data into a signal.
  BleSignal decode(Uint8List data) {
    // TODO: implement device-specific protocol
    throw UnimplementedError();
  }
}
