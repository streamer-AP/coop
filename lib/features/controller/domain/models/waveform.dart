import 'package:freezed_annotation/freezed_annotation.dart';

part 'waveform.freezed.dart';
part 'waveform.g.dart';

enum WaveformChannel { swing, vibration }

@freezed
class Waveform with _$Waveform {
  const factory Waveform({
    required int id,
    required String name,
    required WaveformChannel channel,
    @Default(8000) int durationMs,
    @Default(200) int signalIntervalMs,
    @Default(0) int signalDelayMs,
    @Default(true) bool isBuiltIn,
    @Default([]) List<WaveformKeyframe> keyframes,
  }) = _Waveform;

  factory Waveform.fromJson(Map<String, dynamic> json) =>
      _$WaveformFromJson(json);
}

@freezed
class WaveformKeyframe with _$WaveformKeyframe {
  const factory WaveformKeyframe({
    required int timeMs,
    required int value,
  }) = _WaveformKeyframe;

  factory WaveformKeyframe.fromJson(Map<String, dynamic> json) =>
      _$WaveformKeyframeFromJson(json);
}
