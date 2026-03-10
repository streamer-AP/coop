import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'tables/resonance_tables.dart';
import 'tables/controller_tables.dart';
import 'tables/story_tables.dart';
import 'tables/user_tables.dart';
import 'daos/resonance_dao.dart';
import 'daos/controller_dao.dart';
import 'daos/story_dao.dart';
import 'daos/user_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // Resonance
    AudioEntries,
    AudioCollections,
    EntryCollectionCrossRef,
    Playlists,
    PlaylistItems,
    Subtitles,
    SignalFiles,
    // Controller
    WaveformPresets,
    CustomWaveforms,
    WaveformKeyframes,
    // Story
    StoryProgresses,
    StoryCheckpoints,
    // User
    UserPreferences,
    DeviceBindings,
    CachedPermissions,
  ],
  daos: [ResonanceDao, ControllerDao, StoryDao, UserDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  // TODO: initialize with proper QueryExecutor
  throw UnimplementedError('Provide platform-specific database executor');
}
