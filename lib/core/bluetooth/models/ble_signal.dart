import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_signal.freezed.dart';
part 'ble_signal.g.dart';

@freezed
class BleSignal with _$BleSignal {
  const factory BleSignal({
    required int swing,
    required int vibration,
    required SignalSource source,
    int? durationMs,
    int? delayMs,
  }) = _BleSignal;

  factory BleSignal.fromJson(Map<String, dynamic> json) =>
      _$BleSignalFromJson(json);
}

enum SignalSource { preset, resonance, story }

extension BleSignalX on BleSignal {
  bool get usesTimedMode => durationMs != null || delayMs != null;
}
