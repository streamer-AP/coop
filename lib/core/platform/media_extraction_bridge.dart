import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../logging/app_logger.dart';

/// Native bridge for extracting audio tracks from local video files.
/// Falls back to FFmpeg for formats not supported by the native extractor
/// (e.g. AVI).
class MediaExtractionBridge {
  static const _channel = MethodChannel('com.omao/media_extraction');

  Future<String> extractAudio({
    required String inputPath,
    required String outputPath,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('当前平台暂不支持视频抽取音频');
    }

    // Try native extraction first (faster, lower memory)
    try {
      final extractedPath = await _channel
          .invokeMethod<String>('extractAudio', {
            'inputPath': inputPath,
            'outputPath': outputPath,
          });

      if (extractedPath != null && extractedPath.isNotEmpty) {
        return extractedPath;
      }
    } on PlatformException catch (e) {
      final msg = e.message ?? '';
      AppLogger().debug(
        'Native extraction failed for ${p.basename(inputPath)}: $msg, '
        'falling back to FFmpeg',
      );
    }

    // Fallback: use FFmpeg for unsupported formats (AVI, etc.)
    return _extractWithFFmpeg(inputPath, outputPath);
  }

  Future<String> _extractWithFFmpeg(
    String inputPath,
    String outputPath,
  ) async {
    // Output as M4A (AAC) for best compatibility
    final ffmpegOutput = '${p.withoutExtension(outputPath)}.m4a';

    // Delete existing output
    final outFile = File(ffmpegOutput);
    if (await outFile.exists()) {
      await outFile.delete();
    }

    // -i input -vn (no video) -acodec aac -y (overwrite)
    final command =
        '-i "$inputPath" -vn -acodec aac -b:a 192k -y "$ffmpegOutput"';

    AppLogger().debug('FFmpeg: $command');
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getLogsAsString();
      AppLogger().error('FFmpeg extraction failed: $logs');
      throw Exception('音频提取失败，该视频格式可能不受支持');
    }

    if (!await File(ffmpegOutput).exists()) {
      throw Exception('音频提取失败');
    }

    return ffmpegOutput;
  }
}
