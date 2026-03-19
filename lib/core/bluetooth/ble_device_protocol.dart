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
    final safeSwing = _clampLevel(swing);
    final safeVibration = _clampLevel(vibration);
    final safeDuration = durationMs.clamp(0, 0xFFFF);
    final safeDelay = delayMs.clamp(0, 0x64);

    return Uint8List.fromList([
      safeSwing,
      safeVibration,
      safeDuration & 0xFF,
      (safeDuration >> 8) & 0xFF,
      safeDelay,
    ]);
  }

  /// 编码为简单控制帧（仅强度，持续不停止）
  Uint8List encodeSignal(BleSignal signal) {
    if (signal.usesTimedMode) {
      return encodeTimedSignal(
        swing: signal.swing,
        vibration: signal.vibration,
        durationMs: signal.durationMs ?? 0xFFFF,
        delayMs: signal.delayMs ?? 0,
      );
    }

    return Uint8List.fromList([
      _clampLevel(signal.swing),
      _clampLevel(signal.vibration),
    ]);
  }

  /// 解码设备上报数据
  BleSignal decode(Uint8List data) {
    if (data.length >= 5) {
      final durationMs = data[2] | (data[3] << 8);
      return BleSignal(
        swing: _clampLevel(data[0]),
        vibration: _clampLevel(data[1]),
        source: SignalSource.story,
        durationMs: durationMs,
        delayMs: data[4].clamp(0, 0x64),
      );
    }

    if (data.length >= 2) {
      return BleSignal(
        swing: _clampLevel(data[0]),
        vibration: _clampLevel(data[1]),
        source: SignalSource.story,
      );
    }

    return const BleSignal(swing: 0, vibration: 0, source: SignalSource.story);
  }

  int _clampLevel(int value) => value.clamp(0, 100);
}
