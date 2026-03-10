import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_waveform.freezed.dart';
part 'custom_waveform.g.dart';

@freezed
class CustomWaveform with _$CustomWaveform {
  const factory CustomWaveform({
    required int id,
    required String name,
    @Default(32000) int durationMs,
    @Default([]) List<WaveformKeyframe> keyframes,
  }) = _CustomWaveform;

  factory CustomWaveform.fromJson(Map<String, dynamic> json) =>
      _$CustomWaveformFromJson(json);
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
