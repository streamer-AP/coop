import 'package:freezed_annotation/freezed_annotation.dart';

part 'waveform_preset.freezed.dart';
part 'waveform_preset.g.dart';

@freezed
class WaveformPreset with _$WaveformPreset {
  const factory WaveformPreset({
    required int id,
    required String name,
    @Default(0) int swingIntensity,
    @Default(0) int vibrationIntensity,
    @Default(true) bool isBuiltIn,
  }) = _WaveformPreset;

  factory WaveformPreset.fromJson(Map<String, dynamic> json) =>
      _$WaveformPresetFromJson(json);
}
