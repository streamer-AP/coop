import '../../../core/database/daos/story_dao.dart';
import '../domain/models/story_progress.dart';
import '../domain/models/story_checkpoint.dart';
import '../domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryDao _dao;

  StoryRepositoryImpl(this._dao);

  @override
  Future<StoryProgress?> getProgress(
    String characterId,
    String storyId,
  ) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> saveProgress(StoryProgress progress) async {
    // TODO: implement
  }

  @override
  Future<List<StoryCheckpoint>> getCheckpoints(String storyId) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> unlockCheckpoint(String storyId, String checkpointId) async {
    // TODO: implement
  }
}
