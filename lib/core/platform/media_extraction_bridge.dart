import 'dart:io';

import 'package:flutter/services.dart';

import '../logging/app_logger.dart';

/// Native bridge for extracting audio tracks from local video files.
/// Uses platform-native APIs (MediaCodec on Android, AVFoundation on iOS).
/// Unsupported codecs are transcoded to AAC via MediaCodec.
class MediaExtractionBridge {
  static const _channel = MethodChannel('com.omao/media_extraction');

  Future<String> extractAudio({
    required String inputPath,
    required String outputPath,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('当前平台暂不支持视频抽取音频');
    }

    try {
      final extractedPath = await _channel
          .invokeMethod<String>('extractAudio', {
            'inputPath': inputPath,
            'outputPath': outputPath,
          });

      if (extractedPath != null && extractedPath.isNotEmpty) {
        return extractedPath;
      }
      throw Exception('音频提取失败');
    } on PlatformException catch (e) {
      AppLogger().error(
        'Audio extraction failed for $inputPath: ${e.message}',
      );
      throw Exception(e.message ?? '音频提取失败');
    }
  }
}
