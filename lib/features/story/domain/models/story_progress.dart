import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_progress.freezed.dart';
part 'story_progress.g.dart';

@freezed
class StoryProgress with _$StoryProgress {
  const factory StoryProgress({
    required String characterId,
    required String storyId,
    String? currentSectionId,
    @Default(false) bool isCompleted,
  }) = _StoryProgress;

  factory StoryProgress.fromJson(Map<String, dynamic> json) =>
      _$StoryProgressFromJson(json);
}
