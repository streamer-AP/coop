import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart'
    show StoryCheckpointsCompanion, StoryProgressesCompanion;
import '../../../core/database/daos/story_dao.dart';
import '../domain/models/story_progress.dart';
import '../domain/models/story_checkpoint.dart';
import '../domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryDao _dao;

  StoryRepositoryImpl(this._dao);

  @override
  Future<StoryProgress?> getProgress(String characterId, String storyId) async {
    final row = await _dao.getProgress(characterId, storyId);
    if (row == null) return null;

    return StoryProgress(
      characterId: row.characterId,
      storyId: row.storyId,
      currentSectionId: row.currentSectionId,
      isCompleted: row.isCompleted,
    );
  }

  @override
  Future<void> saveProgress(StoryProgress progress) async {
    await _dao.upsertProgress(
      StoryProgressesCompanion(
        characterId: Value(progress.characterId),
        storyId: Value(progress.storyId),
        currentSectionId: Value(progress.currentSectionId),
        isCompleted: Value(progress.isCompleted),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<StoryCheckpoint>> getCheckpoints(String storyId) async {
    final rows = await _dao.getCheckpoints(storyId);
    return rows
        .map(
          (row) => StoryCheckpoint(
            storyId: row.storyId,
            checkpointId: row.checkpointId,
            sectionId: row.sectionId,
            isEnding: row.isEnding,
            isUnlocked: row.isUnlocked,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveCheckpoint(StoryCheckpoint checkpoint) async {
    await _dao.upsertCheckpoint(
      StoryCheckpointsCompanion(
        storyId: Value(checkpoint.storyId),
        checkpointId: Value(checkpoint.checkpointId),
        sectionId: Value(checkpoint.sectionId),
        isEnding: Value(checkpoint.isEnding),
        isUnlocked: Value(checkpoint.isUnlocked),
      ),
    );
  }

  @override
  Future<void> unlockCheckpoint(String storyId, String checkpointId) async {
    await _dao.unlockCheckpoint(storyId, checkpointId);
  }
}
