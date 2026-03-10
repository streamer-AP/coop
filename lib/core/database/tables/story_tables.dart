import 'package:drift/drift.dart';

class StoryProgresses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get characterId => text()();
  TextColumn get storyId => text()();
  TextColumn get currentSectionId => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class StoryCheckpoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get storyId => text()();
  TextColumn get checkpointId => text()();
  TextColumn get sectionId => text()();
  BoolColumn get isEnding => boolean().withDefault(const Constant(false))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
}
