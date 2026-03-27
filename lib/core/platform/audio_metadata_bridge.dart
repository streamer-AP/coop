import 'dart:io';

import 'package:flutter/services.dart';

class AudioEmbeddedMetadata {
  const AudioEmbeddedMetadata({this.title, this.artist, this.album});

  final String? title;
  final String? artist;
  final String? album;

  static String? _normalize(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  factory AudioEmbeddedMetadata.fromMap(Map<Object?, Object?> map) {
    return AudioEmbeddedMetadata(
      title: _normalize(map['title']),
      artist: _normalize(map['artist']),
      album: _normalize(map['album']),
    );
  }
}

class AudioMetadataBridge {
  static const _channel = MethodChannel('com.omao/audio_metadata');

  Future<AudioEmbeddedMetadata?> extractEmbeddedMetadata({
    required String inputPath,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return null;
    }

    final payload = await _channel
        .invokeMapMethod<Object?, Object?>('extractEmbeddedMetadata', {
          'inputPath': inputPath,
        })
        .onError<PlatformException>((error, _) {
          final message = error.message?.trim();
          throw Exception(
            message == null || message.isEmpty ? '音频元信息读取失败' : message,
          );
        });

    if (payload == null || payload.isEmpty) {
      return null;
    }

    final metadata = AudioEmbeddedMetadata.fromMap(payload);
    if (metadata.title == null &&
        metadata.artist == null &&
        metadata.album == null) {
      return null;
    }
    return metadata;
  }
}
