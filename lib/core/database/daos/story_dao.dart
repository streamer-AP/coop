import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/story_tables.dart';

part 'story_dao.g.dart';

@DriftAccessor(tables: [StoryProgresses, StoryCheckpoints])
class StoryDao extends DatabaseAccessor<AppDatabase> with _$StoryDaoMixin {
  StoryDao(super.db);

  Future<StoryProgressesData?> getProgress(String characterId, String storyId) {
    return (select(storyProgresses)
          ..where((tbl) => tbl.characterId.equals(characterId))
          ..where((tbl) => tbl.storyId.equals(storyId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsertProgress(StoryProgressesCompanion companion) async {
    final existing =
        await (select(storyProgresses)
              ..where(
                (tbl) => tbl.characterId.equals(companion.characterId.value),
              )
              ..where((tbl) => tbl.storyId.equals(companion.storyId.value))
              ..limit(1))
            .getSingleOrNull();

    if (existing == null) {
      await into(storyProgresses).insert(companion);
      return;
    }

    await (update(storyProgresses)
      ..where((tbl) => tbl.id.equals(existing.id))).write(companion);
  }

  Future<List<StoryCheckpoint>> getCheckpoints(String storyId) {
    return (select(storyCheckpoints)
          ..where((tbl) => tbl.storyId.equals(storyId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]))
        .get();
  }

  Future<void> upsertCheckpoint(StoryCheckpointsCompanion companion) async {
    final existing =
        await (select(storyCheckpoints)
              ..where((tbl) => tbl.storyId.equals(companion.storyId.value))
              ..where(
                (tbl) => tbl.checkpointId.equals(companion.checkpointId.value),
              )
              ..limit(1))
            .getSingleOrNull();

    if (existing == null) {
      await into(storyCheckpoints).insert(companion);
      return;
    }

    await (update(storyCheckpoints)
      ..where((tbl) => tbl.id.equals(existing.id))).write(companion);
  }

  Future<void> unlockCheckpoint(String storyId, String checkpointId) {
    return (update(storyCheckpoints)
          ..where((tbl) => tbl.storyId.equals(storyId))
          ..where((tbl) => tbl.checkpointId.equals(checkpointId)))
        .write(const StoryCheckpointsCompanion(isUnlocked: Value(true)));
  }
}
