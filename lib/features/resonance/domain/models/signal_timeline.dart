import 'package:freezed_annotation/freezed_annotation.dart';

part 'signal_timeline.freezed.dart';
part 'signal_timeline.g.dart';

@freezed
class SignalKeyframe with _$SignalKeyframe {
  const factory SignalKeyframe({
    required int timestampMs,
    @Default(0) int swing,
    @Default(0) int vibration,
  }) = _SignalKeyframe;

  factory SignalKeyframe.fromJson(Map<String, dynamic> json) =>
      _$SignalKeyframeFromJson(json);
}

@freezed
class SignalTimeline with _$SignalTimeline {
  const factory SignalTimeline({
    @Default([]) List<SignalKeyframe> keyframes,
  }) = _SignalTimeline;

  factory SignalTimeline.fromJson(Map<String, dynamic> json) =>
      _$SignalTimelineFromJson(json);
}
