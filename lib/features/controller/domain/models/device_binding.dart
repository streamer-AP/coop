import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_binding.freezed.dart';
part 'device_binding.g.dart';

@freezed
class DeviceBinding with _$DeviceBinding {
  const factory DeviceBinding({
    required String deviceId,
    required String deviceName,
    required DateTime boundAt,
    @Default(true) bool isActive,
  }) = _DeviceBinding;

  factory DeviceBinding.fromJson(Map<String, dynamic> json) =>
      _$DeviceBindingFromJson(json);
}
