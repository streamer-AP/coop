import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/user_storage_service.dart';
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
    ScriptFiles,
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
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // v1 → v2: 统一波形表，新增常用槽位和使用日志
        if (from < 2) {
          await m.createTable(favoriteSlots);
          await m.createTable(usageLogs);
        }
        // v2 → v3: 新增消息表
        if (from < 3) {
          await m.createTable(messages);
        }
        // v3 → v4: 新增台本文件表
        if (from < 4) {
          await m.createTable(scriptFiles);
        }
        // v4 → v5: 消息表新增服务端消息 ID，用于远端同步去重
        if (from >= 3 && from < 5) {
          await m.addColumn(messages, messages.serverId);
        }
        // v5 → v6: 控制器波形切分为单通道模型，并把蓝牙时序配置提升到波形主表
        if (from < 6) {
          await customStatement('PRAGMA foreign_keys = OFF');
          await customStatement('DROP TABLE IF EXISTS favorite_slots');
          await customStatement('DROP TABLE IF EXISTS waveform_keyframes');
          await customStatement('DROP TABLE IF EXISTS waveforms');
          await customStatement('PRAGMA foreign_keys = ON');
          await m.createTable(waveforms);
          await m.createTable(waveformKeyframes);
          await m.createTable(favoriteSlots);
        }
        // v6 → v7: 音频条目新增专辑字段，保留原文件名作为 title
        if (from < 7) {
          await m.addColumn(audioEntries, audioEntries.album);
        }
      },
    );
  }
}

/// 从 UserStorageService 获取用户专属数据库实例。
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  ref.watch(userStorageEpochProvider);
  final userStorage = ref.watch(userStorageNotifierProvider).requireValue;
  return userStorage.db;
}
