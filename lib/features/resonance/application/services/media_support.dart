import 'dart:io';

import 'package:path/path.dart' as p;

/// Shared media format support + lightweight media payload validation.
class ResonanceMediaSupport {
  static const Set<String> audioExtensions = {
    'mp3',
    'wav',
    'flac',
    'aac',
    'm4a',
    'ogg',
    'wma',
    'opus',
    'amr',
    'aiff',
    'aif',
  };

  static const Set<String> videoExtensions = {
    'mp4',
    'mkv',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v',
    '3gp',
  };

  static const Set<String> playableMediaExtensions = {
    ...audioExtensions,
    ...videoExtensions,
  };

  static const List<String> _textMarkers = <String>[
    '{',
    '[',
    '<',
    'WEBVTT',
    '[00:',
    '[01:',
    '[02:',
    '1\n00:',
    '#EXTM3U',
  ];

  static String extensionOf(String path) {
    return p.extension(path).toLowerCase().replaceFirst('.', '');
  }

  static Future<void> ensureLikelyPlayableMediaFile(
    String path, {
    required String label,
  }) async {
    final file = File(path);
    if (!await runWithPendingFsRetry(() => file.exists())) {
      throw Exception('$label 不存在');
    }

    final length = await runWithPendingFsRetry(() => file.length());
    if (length <= 0) {
      throw Exception('$label 为空');
    }

    final ext = extensionOf(path);
    if (ext.isEmpty) {
      throw Exception('$label 缺少后缀，无法识别媒体格式');
    }
    if (!playableMediaExtensions.contains(ext)) {
      throw Exception('不支持的媒体格式: .$ext');
    }

    final header = await _readHeader(file, length: 128);
    if (header.isEmpty) return;
    if (!_looksLikeText(header)) return;

    final headerText = String.fromCharCodes(header).trimLeft();
    if (_textMarkers.any(headerText.startsWith)) {
      throw Exception('文件内容不是可播放音频，请重新导入媒体文件');
    }
  }

  static bool isPendingFsOperation(FileSystemException error) {
    final message = error.message.toLowerCase();
    return message.contains('an async operation is currently pending') ||
        message.contains('async operation is currently pending');
  }

  static Future<T> runWithPendingFsRetry<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
  }) async {
    FileSystemException? lastError;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await action();
      } on FileSystemException catch (error) {
        if (!isPendingFsOperation(error) || attempt == maxAttempts - 1) {
          rethrow;
        }
        lastError = error;
        await Future<void>.delayed(Duration(milliseconds: 120 * (attempt + 1)));
      }
    }

    throw lastError ?? const FileSystemException('文件系统操作失败，且未捕获到具体异常');
  }

  static Future<List<int>> _readHeader(File file, {required int length}) async {
    return runWithPendingFsRetry(() async {
      final fileLength = await file.length();
      final safeLength = fileLength < length ? fileLength : length;
      if (safeLength <= 0) return const [];

      final buffer = <int>[];
      await for (final chunk in file.openRead(0, safeLength)) {
        buffer.addAll(chunk);
        if (buffer.length >= safeLength) {
          break;
        }
      }
      return buffer.length <= safeLength
          ? buffer
          : buffer.sublist(0, safeLength);
    });
  }

  static bool _looksLikeText(List<int> bytes) {
    if (bytes.isEmpty) return false;
    var printable = 0;
    for (final b in bytes) {
      if (b == 0) return false;
      if (b == 9 || b == 10 || b == 13 || (b >= 32 && b <= 126)) {
        printable++;
      }
    }
    return printable / bytes.length > 0.9;
  }
}
