import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_device.freezed.dart';
part 'ble_device.g.dart';

@freezed
class BleDevice with _$BleDevice {
  const factory BleDevice({
    required String id,
    required String name,
    required int rssi,
    @Default(false) bool isConnected,
  }) = _BleDevice;

  factory BleDevice.fromJson(Map<String, dynamic> json) =>
      _$BleDeviceFromJson(json);
}
