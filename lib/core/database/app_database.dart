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
    Waveforms,
    WaveformKeyframes,
    FavoriteSlots,
    UsageLogs,
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // v1 → v2: 统一波形表，新增常用槽位和使用日志
          // TODO: implement migration —
          //   1. 创建新的 Waveforms 表并迁移 WaveformPresets + CustomWaveforms 数据
          //   2. 迁移 WaveformKeyframes 的外键引用
          //   3. 创建 FavoriteSlots 表
          //   4. 创建 UsageLogs 表
          //   5. 删除旧的 WaveformPresets 和 CustomWaveforms 表
          await m.createTable(favoriteSlots);
          await m.createTable(usageLogs);
        }
      },
    );
  }
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  // TODO: initialize with proper QueryExecutor
  throw UnimplementedError('Provide platform-specific database executor');
}
