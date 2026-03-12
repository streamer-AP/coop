import 'package:drift/drift.dart';

class AudioEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  TextColumn get coverPath => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get signalFilePath => text().nullable()();
  TextColumn get mediaType => text().withDefault(const Constant('audio'))();
  TextColumn get artist => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class AudioCollections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class EntryCollectionCrossRef extends Table {
  IntColumn get entryId => integer().references(AudioEntries, #id)();
  IntColumn get collectionId => integer().references(AudioCollections, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {entryId, collectionId};
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer().references(Playlists, #id)();
  IntColumn get entryId => integer().references(AudioEntries, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Subtitles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId => integer().references(AudioEntries, #id)();
  TextColumn get language => text()();
  TextColumn get filePath => text()();
  TextColumn get format => text().withDefault(const Constant('srt'))();
}

class SignalFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entryId => integer().references(AudioEntries, #id)();
  TextColumn get filePath => text()();
}
