import 'package:freezed_annotation/freezed_annotation.dart';

part 'usage_log.freezed.dart';
part 'usage_log.g.dart';

@freezed
class UsageLog with _$UsageLog {
  const factory UsageLog({
    required int id,
    required DateTime startTime,
    required String signalMode,    // 'swing' / 'vibration' / 'both'
    required int waveformId,
    required int intensityLevel,
    required int durationMs,
    String? deviceModel,
    String? deviceSerial,
  }) = _UsageLog;

  factory UsageLog.fromJson(Map<String, dynamic> json) =>
      _$UsageLogFromJson(json);
}
