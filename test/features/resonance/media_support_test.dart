import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omao_app/features/resonance/application/services/media_support.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ResonanceMediaSupport.ensureLikelyPlayableMediaFile', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'omao_media_support_test_',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('accepts a valid mp3 file', () async {
      final source = File('test/integration/test_assets/test_song.mp3');
      final target = File(p.join(tempDir.path, 'test_song.mp3'));
      await source.copy(target.path);

      await expectLater(
        ResonanceMediaSupport.ensureLikelyPlayableMediaFile(
          target.path,
          label: '测试音频',
        ),
        completes,
      );
    });

    test('rejects a zip archive masquerading as mp3', () async {
      final source = File('test/integration/test_assets/test_archive.zip');
      final target = File(p.join(tempDir.path, '测试.zip.mp3'));
      await source.copy(target.path);

      await expectLater(
        () => ResonanceMediaSupport.ensureLikelyPlayableMediaFile(
          target.path,
          label: '测试音频',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('ZIP 压缩包'),
          ),
        ),
      );
    });

    test('rejects a png image masquerading as mp3', () async {
      final source = File('test/integration/test_assets/test_cover.png');
      final target = File(p.join(tempDir.path, 'cover.mp3'));
      await source.copy(target.path);

      await expectLater(
        () => ResonanceMediaSupport.ensureLikelyPlayableMediaFile(
          target.path,
          label: '测试音频',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('PNG 图片'),
          ),
        ),
      );
    });
  });
}
