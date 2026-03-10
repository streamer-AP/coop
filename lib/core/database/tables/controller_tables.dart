import 'package:drift/drift.dart';

class WaveformPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get swingIntensity => integer().withDefault(const Constant(0))();
  IntColumn get vibrationIntensity => integer().withDefault(const Constant(0))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(true))();
}

class CustomWaveforms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get durationMs => integer().withDefault(const Constant(32000))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class WaveformKeyframes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get waveformId => integer().references(CustomWaveforms, #id)();
  IntColumn get timeMs => integer()();
  IntColumn get swingValue => integer()();
  IntColumn get vibrationValue => integer()();
}
