import 'dart:io';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'user_storage_service.dart';

part 'file_manager.g.dart';

/// Manages file operations for user-scoped imported/cached resources.
class FileManager {
  FileManager(this._importDir);

  final String _importDir;

  String getImportDirectory() => _importDir;

  Future<int> getCacheSize() async {
    final cacheDir = Directory(_importDir);
    if (!await cacheDir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  Future<void> clearCache() async {
    final cacheDir = Directory(_importDir);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
    }
  }
}

@Riverpod(keepAlive: true)
FileManager fileManager(Ref ref) {
  final userStorage = ref.watch(userStorageNotifierProvider).requireValue;
  return FileManager(userStorage.importDirectory);
}
