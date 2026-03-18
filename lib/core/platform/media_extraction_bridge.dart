import 'dart:io';

import 'package:flutter/services.dart';

/// Native bridge for extracting audio tracks from local video files.
class MediaExtractionBridge {
  static const _channel = MethodChannel('com.omao/media_extraction');

  Future<String> extractAudio({
    required String inputPath,
    required String outputPath,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('当前平台暂不支持视频抽取音频');
    }

    final extractedPath = await _channel.invokeMethod<String>('extractAudio', {
      'inputPath': inputPath,
      'outputPath': outputPath,
    });

    if (extractedPath == null || extractedPath.isEmpty) {
      throw Exception('视频音频提取失败');
    }

    return extractedPath;
  }
}
