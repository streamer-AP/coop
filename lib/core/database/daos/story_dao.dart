import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/story_tables.dart';

part 'story_dao.g.dart';

@DriftAccessor(tables: [StoryProgresses, StoryCheckpoints])
class StoryDao extends DatabaseAccessor<AppDatabase> with _$StoryDaoMixin {
  StoryDao(super.db);

  // TODO: implement CRUD operations
}
