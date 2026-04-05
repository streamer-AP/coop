import 'dart:io';

import 'package:flutter/services.dart';

/// Native bridge for analyzing audio files and generating signal timelines.
class AudioAnalysisBridge {
  static const _channel = MethodChannel('com.omao/audio_analysis');

  /// Analyzes the audio file at [audioFilePath] and returns a JSON string
  /// representing a [SignalTimeline] with keyframes every ~200ms.
  Future<String> analyzeAudio({required String audioFilePath}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('当前平台暂不支持音频分析');
    }

    final json = await _channel
        .invokeMethod<String>('analyzeAudio', {
          'audioFilePath': audioFilePath,
        })
        .onError<PlatformException>((error, _) {
          final message = error.message?.trim();
          throw Exception(
            message == null || message.isEmpty ? '音频分析失败' : message,
          );
        });

    if (json == null || json.isEmpty) {
      throw Exception('音频分析返回空结果');
    }

    return json;
  }
}
