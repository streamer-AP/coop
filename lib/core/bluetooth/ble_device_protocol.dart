import 'dart:typed_data';
import 'models/ble_signal.dart';

/// Encodes/decodes BLE device protocol messages.
class BleDeviceProtocol {
  /// OMAO 设备主控制服务
  static const serviceUuid = '0000F004-0000-1000-8000-00805F9B34FB';

  /// 振动控制写入特征
  static const writeCharacteristicUuid =
      '0000F320-0000-1000-8000-00805F9B34FB';

  /// 当前档位通知特征
  static const notifyCharacteristicUuid =
      '0000F220-0000-1000-8000-00805F9B34FB';

  /// 电池电量特征
  static const batteryCharacteristicUuid =
      '00002A19-0000-1000-8000-00805F9B34FB';

  /// 设备名特征
  static const deviceNameCharacteristicUuid =
      '00002A00-0000-1000-8000-00805F9B34FB';

  /// 震动类型特征
  static const vibrationTypeCharacteristicUuid =
      '0000F221-0000-1000-8000-00805F9B34FB';

  /// 剩余时间特征
  static const remainingTimeCharacteristicUuid =
      '0000F241-0000-1000-8000-00805F9B34FB';

  /// 控制源特征
  static const controlSourceCharacteristicUuid =
      '0000F260-0000-1000-8000-00805F9B34FB';

  /// 设备所需的全部服务 UUID
  static const requiredServiceUuids = [
    '0000180A-0000-1000-8000-00805F9B34FB',
    '0000180F-0000-1000-8000-00805F9B34FB',
    '00001800-0000-1000-8000-00805F9B34FB',
    '0000F000-0000-1000-8000-00805F9B34FB',
    '0000F001-0000-1000-8000-00805F9B34FB',
    '0000F004-0000-1000-8000-00805F9B34FB',
    '0000F005-0000-1000-8000-00805F9B34FB',
    '0000F006-0000-1000-8000-00805F9B34FB',
  ];

  /// 设备名前缀白名单
  static const targetNamePrefixes = ['OMAO', 'ETOUCH', '744'];

  /// 目标厂商 ID
  static const targetManufacturerId = 511;

  /// 编码为定时长模式帧（5 字节）
  /// [swing(1B), vibration(1B), durationMs高字节(1B), durationMs低字节(1B), delayMs(1B)]
  Uint8List encodeTimedSignal({
    required int swing,
    required int vibration,
    int durationMs = 200,
    int delayMs = 0,
  }) {
    final safeSwing = _clampLevel(swing);
    final safeVibration = _clampLevel(vibration);
    final safeDuration = durationMs.clamp(0, 0xFFFF);
    final safeDelay = delayMs.clamp(0, 0x64);

    return Uint8List.fromList([
      safeSwing,
      safeVibration,
      (safeDuration >> 8) & 0xFF,
      safeDuration & 0xFF,
      safeDelay,
    ]);
  }

  /// 编码控制帧（默认对齐原生旧实现，持续 200ms）
  Uint8List encodeSignal(BleSignal signal) {
    return encodeTimedSignal(
      swing: signal.swing,
      vibration: signal.vibration,
      durationMs: signal.durationMs ?? 200,
      delayMs: signal.delayMs ?? 0,
    );
  }

  /// 解码设备上报数据
  BleSignal decode(Uint8List data) {
    if (data.length >= 5) {
      final durationMs = (data[2] << 8) | data[3];
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
