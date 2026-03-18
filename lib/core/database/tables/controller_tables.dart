import 'package:drift/drift.dart';

class Waveforms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get durationMs => integer().withDefault(const Constant(8000))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class WaveformKeyframes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get waveformId => integer().references(Waveforms, #id)();
  IntColumn get timeMs => integer()();
  IntColumn get swingValue => integer()();
  IntColumn get vibrationValue => integer()();
}

class FavoriteSlots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get page => integer()();       // 0-2
  IntColumn get slotIndex => integer()();  // 0-3
  IntColumn get waveformId => integer().references(Waveforms, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [{page, slotIndex}];
}

class UsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get signalMode => text()();
  IntColumn get waveformId => integer()();
  IntColumn get intensityLevel => integer()();
  IntColumn get durationMs => integer()();
  TextColumn get deviceModel => text().nullable()();
  TextColumn get deviceSerial => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
