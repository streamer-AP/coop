import 'dart:typed_data';
import 'models/ble_signal.dart';

/// Encodes/decodes BLE device protocol messages.
class BleDeviceProtocol {
  // --- 待硬件侧确认后填入 ---
  static const serviceUuid = 'TODO';
  static const writeCharacteristicUuid = 'TODO';
  static const notifyCharacteristicUuid = 'TODO';

  /// 编码为定时长模式帧（5 字节）
  /// [swing(1B), vibration(1B), durationMs(2B, little-endian), delayMs(1B)]
  Uint8List encodeTimedSignal({
    required int swing,
    required int vibration,
    int durationMs = 0xFFFF,
    int delayMs = 0,
  }) {
    // TODO: implement device-specific protocol
    throw UnimplementedError();
  }

  /// 编码为简单控制帧（仅强度，持续不停止）
  Uint8List encodeSignal(BleSignal signal) {
    // TODO: implement device-specific protocol
    throw UnimplementedError();
  }

  /// 解码设备上报数据
  BleSignal decode(Uint8List data) {
    // TODO: implement device-specific protocol
    throw UnimplementedError();
  }
}
