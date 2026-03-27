import 'package:flutter/services.dart';

/// Native bridge for on-device text translation.
class TextTranslationBridge {
  static const _channel = MethodChannel('com.omao/translation');

  Future<List<String>> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (texts.isEmpty) {
      return const [];
    }

    try {
      final raw = await _channel.invokeListMethod<dynamic>('translateBatch', {
        'texts': texts,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
      });

      if (raw == null) {
        throw const FormatException('translation response is null');
      }

      return raw.map((item) => '${item ?? ''}').toList(growable: false);
    } on PlatformException catch (error) {
      final message = error.message?.trim();
      throw Exception(message == null || message.isEmpty ? '字幕翻译失败' : message);
    } on MissingPluginException {
      throw Exception('当前平台暂不支持字幕翻译');
    }
  }
}
