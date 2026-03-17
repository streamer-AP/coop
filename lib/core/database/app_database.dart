import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'tables/resonance_tables.dart';
import 'tables/controller_tables.dart';
import 'tables/story_tables.dart';
import 'tables/user_tables.dart';
import 'tables/message_tables.dart';
import 'daos/resonance_dao.dart';
import 'daos/controller_dao.dart';
import 'daos/story_dao.dart';
import 'daos/user_dao.dart';
import 'daos/message_dao.dart';

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
    // Message
    Messages,
  ],
  daos: [ResonanceDao, ControllerDao, StoryDao, UserDao, MessageDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // v1 → v2: 统一波形表，新增常用槽位和使用日志
        if (from < 2) {
          // TODO: implement migration —
          //   1. 创建新的 Waveforms 表并迁移 WaveformPresets + CustomWaveforms 数据
          //   2. 迁移 WaveformKeyframes 的外键引用
          //   3. 创建 FavoriteSlots 表
          //   4. 创建 UsageLogs 表
          //   5. 删除旧的 WaveformPresets 和 CustomWaveforms 表
          await m.createTable(favoriteSlots);
          await m.createTable(usageLogs);
        }
        // v2 → v3: 新增消息表
        if (from < 3) {
          await m.createTable(messages);
        }
      },
    );
  }
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase(_openConnection());
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'omao.db'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        db.execute('PRAGMA journal_mode=WAL');
        db.execute('PRAGMA busy_timeout=5000');
      },
    );
  });
}
