import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Manages file operations for downloaded/cached resources.
class FileManager {
  String? _importDir;

  Future<String> getImportDirectory() async {
    if (_importDir != null) return _importDir!;

    final appDir = await getApplicationDocumentsDirectory();
    final importDir = Directory(p.join(appDir.path, 'imports'));
    if (!await importDir.exists()) {
      await importDir.create(recursive: true);
    }
    _importDir = importDir.path;
    return _importDir!;
  }

  Future<String> getResourcePath(String resourceId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'resources', resourceId);
  }

  Future<void> deleteResource(String resourceId) async {
    final path = await getResourcePath(resourceId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<int> getCacheSize() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(appDir.path, 'imports'));
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
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(appDir.path, 'imports'));
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
    }
  }
}
