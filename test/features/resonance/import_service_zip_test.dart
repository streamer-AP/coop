import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omao_app/features/resonance/application/services/import_service.dart';

void main() {
  group('ImportService zip filename repair', () {
    late Directory importDir;
    late ImportService service;

    setUp(() async {
      importDir = await Directory.systemTemp.createTemp('omao_import_service_');
      service = ImportService(importDirectory: importDir.path);
    });

    tearDown(() async {
      if (await importDir.exists()) {
        await importDir.delete(recursive: true);
      }
    });

    test('repairs mojibake entry names in zip preview', () async {
      final preview = await service.prepareZipPreview(
        'test/integration/test_assets/test_archive.zip',
      );

      expect(preview.items.any((item) => item.name == '歌曲A/歌曲A.mp3'), isTrue);
      expect(
        preview.items.any((item) => item.name == '歌曲C_无字幕/歌曲C.flac'),
        isTrue,
      );

      await service.cleanupPreview(preview);
    });
  });
}
