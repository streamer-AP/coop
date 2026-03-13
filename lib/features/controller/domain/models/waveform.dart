import 'package:freezed_annotation/freezed_annotation.dart';

part 'waveform.freezed.dart';
part 'waveform.g.dart';

@freezed
class Waveform with _$Waveform {
  const factory Waveform({
    required int id,
    required String name,
    @Default(8000) int durationMs,
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
    required int swingValue,
    required int vibrationValue,
  }) = _WaveformKeyframe;

  factory WaveformKeyframe.fromJson(Map<String, dynamic> json) =>
      _$WaveformKeyframeFromJson(json);
}
