import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../logging/app_logger.dart';
import 'token_storage.dart';

part 'user_storage_service.g.dart';

final userStorageEpochProvider = StateProvider<int>((ref) => 0);

/// 管理用户隔离的存储路径和数据库生命周期。
class UserStorageService {
  UserStorageService._(this.userId, this._userRoot);

  final String userId;
  final String _userRoot;
  AppDatabase? _db;

  String get importDirectory => p.join(_userRoot, 'imports');
  String get avatarDirectory => p.join(_userRoot, 'avatars');
  String get exportDirectory => p.join(_userRoot, 'exports');
  String get databasePath => p.join(_userRoot, 'omao.db');

  AppDatabase get db {
    if (_db == null) {
      throw StateError('UserStorageService 未初始化，请先调用 initialize()');
    }
    return _db!;
  }

  /// 创建用户目录结构 + 打开数据库。
  static Future<UserStorageService> create(String userId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final userRoot = p.join(appDir.path, 'users', userId);
    AppLogger().info(
      '[UserStorage] create: userId=$userId, '
      'appDir=${appDir.path}, userRoot=$userRoot',
    );
    final service = UserStorageService._(userId, userRoot);
    await service._initialize();
    return service;
  }

  Future<void> _initialize() async {
    // 确保各子目录存在
    for (final dir in [importDirectory, avatarDirectory, exportDirectory]) {
      final directory = Directory(dir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }

    // 打开用户专属数据库
    final dbFile = File(databasePath);
    AppLogger().info(
      '[UserStorage] _initialize: dbPath=$databasePath, '
      'dbExists=${await dbFile.exists()}, '
      'importsDir=$importDirectory',
    );
    _db = AppDatabase(
      NativeDatabase.createInBackground(
        dbFile,
        setup: (db) {
          db.execute('PRAGMA journal_mode=WAL');
          db.execute('PRAGMA busy_timeout=5000');
        },
      ),
    );
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }
}

@Riverpod(keepAlive: true)
class UserStorageNotifier extends _$UserStorageNotifier {
  @override
  AsyncValue<UserStorageService> build() {
    _tryRestoreFromCache();
    return const AsyncLoading();
  }

  UserStorageService? _current;
  Future<void> _operationQueue = Future.value();

  void _bumpEpoch(String reason) {
    final notifier = ref.read(userStorageEpochProvider.notifier);
    final nextEpoch = notifier.state + 1;
    notifier.state = nextEpoch;
    AppLogger().info(
      '[UserStorage] epoch bumped: epoch=$nextEpoch, reason=$reason',
    );
  }

  Future<void> _enqueueOperation(Future<void> Function() operation) {
    final next = _operationQueue.then((_) => operation());
    _operationQueue = next.catchError((Object error, StackTrace stackTrace) {
      AppLogger().error(
        '[UserStorage] queued operation failed',
        error: error,
        stackTrace: stackTrace,
      );
    });
    return next;
  }

  /// 尝试从 TokenStorage 恢复上次登录的用户。
  Future<void> _tryRestoreFromCache() async {
    final userId = await TokenStorage().getCurrentUserId();
    AppLogger().info(
      '[UserStorage] _tryRestoreFromCache: cachedUserId=$userId',
    );
    if (userId != null && userId.trim().isNotEmpty) {
      await switchUser(userId.trim());
    } else {
      AppLogger().warning(
        '[UserStorage] _tryRestoreFromCache: no cached userId, '
        'storage stays in AsyncLoading',
      );
    }
  }

  /// 切换到指定用户的存储空间。
  Future<void> switchUser(String userId, {bool force = false}) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      AppLogger().warning('[UserStorage] switchUser: empty userId, skipping');
      return;
    }

    await _enqueueOperation(() async {
      // 相同用户则跳过，避免重复 dispose/create
      if (!force && _current != null && _current!.userId == normalizedUserId) {
        AppLogger().info(
          '[UserStorage] switchUser: same userId=$normalizedUserId, skipping',
        );
        return;
      }

      AppLogger().info(
        '[UserStorage] switchUser: userId=$normalizedUserId, '
        'force=$force (prev=${_current?.userId})',
      );

      // 关闭旧数据库
      await _current?.dispose();

      final service = await UserStorageService.create(normalizedUserId);
      _current = service;
      state = AsyncData(service);
      _bumpEpoch('switchUser:$normalizedUserId:force=$force');
    });
  }

  /// 登出时清理。账号注销场景可额外删除当前用户的本地目录。
  Future<void> clear({bool deleteCurrentUserData = false}) async {
    await _enqueueOperation(() async {
      final previousUserId = _current?.userId;
      final previousUserRoot = _current?._userRoot;
      await _current?.dispose();
      _current = null;
      state = const AsyncLoading();
      _bumpEpoch(
        '${deleteCurrentUserData ? 'purge' : 'clear'}:${previousUserId ?? 'none'}',
      );

      if (!deleteCurrentUserData ||
          previousUserRoot == null ||
          previousUserRoot.isEmpty) {
        return;
      }

      final userRootDir = Directory(previousUserRoot);
      try {
        if (await userRootDir.exists()) {
          await userRootDir.delete(recursive: true);
          AppLogger().info(
            '[UserStorage] deleted user root: userId=${previousUserId ?? ''}, '
            'path=$previousUserRoot',
          );
        }
      } catch (error, stackTrace) {
        AppLogger().error(
          '[UserStorage] failed to delete user root: path=$previousUserRoot',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }
}
