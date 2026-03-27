import 'dart:io';

import 'package:flutter/services.dart';

/// Native bridge for extracting embedded artwork from local audio files.
class AudioArtworkBridge {
  static const _channel = MethodChannel('com.omao/audio_artwork');

  Future<String?> extractEmbeddedArtwork({
    required String inputPath,
    required String outputPath,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return null;
    }

    final artworkPath = await _channel
        .invokeMethod<String>('extractEmbeddedArtwork', {
          'inputPath': inputPath,
          'outputPath': outputPath,
        })
        .onError<PlatformException>((error, _) {
          final message = error.message?.trim();
          throw Exception(
            message == null || message.isEmpty ? '音频封面提取失败' : message,
          );
        });

    if (artworkPath == null || artworkPath.trim().isEmpty) {
      return null;
    }

    return artworkPath;
  }
}
