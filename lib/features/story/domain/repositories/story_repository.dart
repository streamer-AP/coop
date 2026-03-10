import '../models/story_progress.dart';
import '../models/story_checkpoint.dart';

abstract class StoryRepository {
  Future<StoryProgress?> getProgress(String characterId, String storyId);
  Future<void> saveProgress(StoryProgress progress);
  Future<List<StoryCheckpoint>> getCheckpoints(String storyId);
  Future<void> unlockCheckpoint(String storyId, String checkpointId);
}
