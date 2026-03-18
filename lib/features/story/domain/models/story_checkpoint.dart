import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_checkpoint.freezed.dart';
part 'story_checkpoint.g.dart';

@freezed
class StoryCheckpoint with _$StoryCheckpoint {
  const factory StoryCheckpoint({
    required String storyId,
    required String checkpointId,
    required String sectionId,
    @Default(false) bool isEnding,
    @Default(false) bool isUnlocked,
  }) = _StoryCheckpoint;

  factory StoryCheckpoint.fromJson(Map<String, dynamic> json) =>
      _$StoryCheckpointFromJson(json);
}
