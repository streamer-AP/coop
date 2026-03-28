import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class EmbeddedLyricsData {
  const EmbeddedLyricsData({this.timedLyrics, this.plainLyrics});

  final String? timedLyrics;
  final String? plainLyrics;

  bool get isEmpty =>
      (timedLyrics == null || timedLyrics!.trim().isEmpty) &&
      (plainLyrics == null || plainLyrics!.trim().isEmpty);
}

class AudioEmbeddedLyricsExtractor {
  static const _mp4LyricsAtomType = '\u00A9lyr';
  static final _lrcLinePattern = RegExp(
    r'^\s*\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]',
    multiLine: true,
  );

  Future<EmbeddedLyricsData?> extract({required String inputPath}) async {
    final file = File(inputPath);
    if (!await file.exists()) {
      return null;
    }

    final reader = await file.open();
    try {
      final fileLength = await reader.length();
      final header = await _readBytes(
        reader,
        offset: 0,
        length: fileLength >= 16 ? 16 : fileLength,
      );

      EmbeddedLyricsData? lyrics;
      if (_matchesSignature(header, 'ID3')) {
        lyrics = await _extractFromId3(reader);
      } else if (_matchesSignature(header, 'fLaC')) {
        lyrics = await _extractFromFlac(reader, fileLength);
      } else if (header.length >= 8 &&
          latin1.decode(header.sublist(4, 8), allowInvalid: true) == 'ftyp') {
        lyrics = await _extractFromMp4(reader, fileLength);
      }

      return _finalizeLyrics(lyrics);
    } finally {
      await reader.close();
    }
  }

  Future<EmbeddedLyricsData?> _extractFromId3(RandomAccessFile reader) async {
    final header = await _readBytes(reader, offset: 0, length: 10);
    if (header.length < 10) {
      return null;
    }

    final versionMajor = header[3];
    if (versionMajor < 3 || versionMajor > 4) {
      return null;
    }

    final flags = header[5];
    var body = await _readBytes(
      reader,
      offset: 10,
      length: _readSyncSafeInt(header, 6),
    );
    if ((flags & 0x80) != 0) {
      body = _removeUnsynchronization(body);
    }

    var offset = 0;
    if ((flags & 0x40) != 0 && body.length >= 4) {
      if (versionMajor == 3) {
        final declaredSize = _readUint32(body, 0);
        final candidate = declaredSize + 4;
        offset = candidate <= body.length ? candidate : declaredSize;
      } else {
        final declaredSize = _readSyncSafeInt(body, 0);
        offset = declaredSize <= body.length ? declaredSize : 0;
      }
    }

    String? timedLyrics;
    String? plainLyrics;

    while (offset + 10 <= body.length) {
      final frameId = ascii.decode(
        body.sublist(offset, offset + 4),
        allowInvalid: true,
      );
      if (frameId.trim().isEmpty ||
          frameId.codeUnits.every((unit) => unit == 0)) {
        break;
      }

      final frameSize =
          versionMajor == 4
              ? _readSyncSafeInt(body, offset + 4)
              : _readUint32(body, offset + 4);
      if (frameSize <= 0 || offset + 10 + frameSize > body.length) {
        break;
      }

      final payload = body.sublist(offset + 10, offset + 10 + frameSize);
      switch (frameId) {
        case 'USLT':
          plainLyrics ??= _parseUsltFrame(payload);
          break;
        case 'SYLT':
          final parsed = _parseSyltFrame(payload);
          timedLyrics ??= parsed?.timedLyrics;
          plainLyrics ??= parsed?.plainLyrics;
          break;
      }

      offset += 10 + frameSize;
    }

    return EmbeddedLyricsData(
      timedLyrics: timedLyrics,
      plainLyrics: plainLyrics,
    );
  }

  String? _parseUsltFrame(List<int> payload) {
    if (payload.length < 5) {
      return null;
    }

    final encoding = payload[0];
    final descriptor = _readTerminatedText(
      payload,
      start: 4,
      encoding: encoding,
    );
    if (descriptor == null || descriptor.nextIndex > payload.length) {
      return null;
    }

    return _normalizePlainLyrics(
      _decodeText(payload.sublist(descriptor.nextIndex), encoding: encoding),
    );
  }

  EmbeddedLyricsData? _parseSyltFrame(List<int> payload) {
    if (payload.length < 7) {
      return null;
    }

    final encoding = payload[0];
    final timestampFormat = payload[4];
    final descriptor = _readTerminatedText(
      payload,
      start: 6,
      encoding: encoding,
    );
    if (descriptor == null) {
      return null;
    }

    var offset = descriptor.nextIndex;
    final timedEntries = <({int timestampMs, String text})>[];
    final plainLines = <String>[];

    while (offset < payload.length) {
      final textResult = _readTerminatedText(
        payload,
        start: offset,
        encoding: encoding,
      );
      if (textResult == null) {
        break;
      }
      offset = textResult.nextIndex;
      if (offset + 4 > payload.length) {
        break;
      }

      final timestamp = _readUint32(payload, offset);
      offset += 4;

      final normalizedText = _normalizePlainLyrics(textResult.text);
      if (normalizedText == null) {
        continue;
      }
      plainLines.add(normalizedText);

      if (timestampFormat == 2) {
        timedEntries.add((timestampMs: timestamp, text: normalizedText));
      }
    }

    return EmbeddedLyricsData(
      timedLyrics: timedEntries.isEmpty ? null : _formatAsLrc(timedEntries),
      plainLyrics: plainLines.isEmpty ? null : plainLines.join('\n'),
    );
  }

  Future<EmbeddedLyricsData?> _extractFromFlac(
    RandomAccessFile reader,
    int fileLength,
  ) async {
    var offset = 4;
    String? timedLyrics;
    String? plainLyrics;
    var isLastBlock = false;

    while (!isLastBlock && offset + 4 <= fileLength) {
      final header = await _readBytes(reader, offset: offset, length: 4);
      if (header.length < 4) {
        break;
      }

      isLastBlock = (header[0] & 0x80) != 0;
      final blockType = header[0] & 0x7F;
      final blockLength = (header[1] << 16) | (header[2] << 8) | header[3];
      offset += 4;

      if (offset + blockLength > fileLength) {
        break;
      }

      if (blockType == 4) {
        final blockBytes = await _readBytes(
          reader,
          offset: offset,
          length: blockLength,
        );
        final parsed = _parseVorbisCommentBlock(blockBytes);
        timedLyrics ??= parsed?.timedLyrics;
        plainLyrics ??= parsed?.plainLyrics;
      }

      offset += blockLength;
    }

    return EmbeddedLyricsData(
      timedLyrics: timedLyrics,
      plainLyrics: plainLyrics,
    );
  }

  EmbeddedLyricsData? _parseVorbisCommentBlock(List<int> blockBytes) {
    final data = ByteData.sublistView(Uint8List.fromList(blockBytes));
    var offset = 0;
    if (blockBytes.length < 8) {
      return null;
    }

    final vendorLength = data.getUint32(offset, Endian.little);
    offset += 4 + vendorLength;
    if (offset + 4 > blockBytes.length) {
      return null;
    }

    final commentCount = data.getUint32(offset, Endian.little);
    offset += 4;

    String? timedLyrics;
    String? plainLyrics;

    for (var index = 0; index < commentCount; index++) {
      if (offset + 4 > blockBytes.length) {
        break;
      }

      final entryLength = data.getUint32(offset, Endian.little);
      offset += 4;
      if (offset + entryLength > blockBytes.length) {
        break;
      }

      final entry = utf8.decode(
        blockBytes.sublist(offset, offset + entryLength),
        allowMalformed: true,
      );
      offset += entryLength;

      final separator = entry.indexOf('=');
      if (separator <= 0) {
        continue;
      }

      final key = _normalizeVorbisKey(entry.substring(0, separator));
      final value = _normalizeLooseText(entry.substring(separator + 1));
      if (value == null || !_isLyricsLikeVorbisKey(key)) {
        continue;
      }

      if (_looksLikeLrc(value)) {
        timedLyrics ??= value;
      } else {
        plainLyrics ??= value;
      }
    }

    return EmbeddedLyricsData(
      timedLyrics: timedLyrics,
      plainLyrics: plainLyrics,
    );
  }

  Future<EmbeddedLyricsData?> _extractFromMp4(
    RandomAccessFile reader,
    int fileLength,
  ) {
    return _scanMp4Atoms(reader, start: 0, end: fileLength, depth: 0);
  }

  Future<EmbeddedLyricsData?> _scanMp4Atoms(
    RandomAccessFile reader, {
    required int start,
    required int end,
    required int depth,
  }) async {
    if (depth > 6) {
      return null;
    }

    var offset = start;
    while (offset + 8 <= end) {
      final atom = await _readMp4AtomHeader(
        reader,
        offset: offset,
        maxEnd: end,
      );
      if (atom == null) {
        break;
      }

      if (atom.type == 'ilst') {
        final parsed = await _parseMp4Ilst(
          reader,
          start: atom.contentStart,
          end: atom.end,
        );
        if (parsed != null && !parsed.isEmpty) {
          return parsed;
        }
      } else if (_isMp4ContainerAtom(atom.type)) {
        final childStart =
            atom.type == 'meta' ? atom.contentStart + 4 : atom.contentStart;
        if (childStart < atom.end) {
          final parsed = await _scanMp4Atoms(
            reader,
            start: childStart,
            end: atom.end,
            depth: depth + 1,
          );
          if (parsed != null && !parsed.isEmpty) {
            return parsed;
          }
        }
      }

      offset = atom.end;
    }

    return null;
  }

  Future<EmbeddedLyricsData?> _parseMp4Ilst(
    RandomAccessFile reader, {
    required int start,
    required int end,
  }) async {
    var offset = start;
    String? timedLyrics;
    String? plainLyrics;

    while (offset + 8 <= end) {
      final atom = await _readMp4AtomHeader(
        reader,
        offset: offset,
        maxEnd: end,
      );
      if (atom == null) {
        break;
      }

      String? value;
      if (atom.type == _mp4LyricsAtomType) {
        value = await _readMp4MetadataValue(
          reader,
          start: atom.contentStart,
          end: atom.end,
        );
      } else if (atom.type == '----') {
        value = await _readMp4FreeformLyrics(
          reader,
          start: atom.contentStart,
          end: atom.end,
        );
      }

      if (value != null) {
        if (_looksLikeLrc(value)) {
          timedLyrics ??= value;
        } else {
          plainLyrics ??= value;
        }
      }

      offset = atom.end;
    }

    return EmbeddedLyricsData(
      timedLyrics: timedLyrics,
      plainLyrics: plainLyrics,
    );
  }

  Future<String?> _readMp4MetadataValue(
    RandomAccessFile reader, {
    required int start,
    required int end,
  }) async {
    var offset = start;
    while (offset + 8 <= end) {
      final atom = await _readMp4AtomHeader(
        reader,
        offset: offset,
        maxEnd: end,
      );
      if (atom == null) {
        break;
      }

      if (atom.type == 'data') {
        return _readMp4DataAtom(reader, atom);
      }

      offset = atom.end;
    }
    return null;
  }

  Future<String?> _readMp4FreeformLyrics(
    RandomAccessFile reader, {
    required int start,
    required int end,
  }) async {
    var offset = start;
    String? name;
    String? value;

    while (offset + 8 <= end) {
      final atom = await _readMp4AtomHeader(
        reader,
        offset: offset,
        maxEnd: end,
      );
      if (atom == null) {
        break;
      }

      switch (atom.type) {
        case 'name':
          name = await _readMp4MetadataValue(
            reader,
            start: atom.contentStart,
            end: atom.end,
          );
          break;
        case 'data':
          value = await _readMp4DataAtom(reader, atom);
          break;
      }

      offset = atom.end;
    }

    final normalizedName = name?.trim().toLowerCase();
    if (normalizedName == null ||
        value == null ||
        !(normalizedName.contains('lyrics') ||
            normalizedName.contains('lrc'))) {
      return null;
    }

    return value;
  }

  Future<String?> _readMp4DataAtom(
    RandomAccessFile reader,
    _Mp4AtomHeader atom,
  ) async {
    final payloadOffset = atom.contentStart + 8;
    if (payloadOffset > atom.end) {
      return null;
    }
    final payload = await _readBytes(
      reader,
      offset: payloadOffset,
      length: atom.end - payloadOffset,
    );
    return _normalizeLooseText(_decodeLooseText(payload));
  }

  Future<_Mp4AtomHeader?> _readMp4AtomHeader(
    RandomAccessFile reader, {
    required int offset,
    required int maxEnd,
  }) async {
    final header = await _readBytes(reader, offset: offset, length: 8);
    if (header.length < 8) {
      return null;
    }

    final size32 = _readUint32(header, 0);
    final type = latin1.decode(header.sublist(4, 8), allowInvalid: true);
    var headerSize = 8;
    var atomSize = size32;

    if (size32 == 1) {
      final extended = await _readBytes(reader, offset: offset + 8, length: 8);
      if (extended.length < 8) {
        return null;
      }
      atomSize = _readUint64(extended, 0);
      headerSize = 16;
    } else if (size32 == 0) {
      atomSize = maxEnd - offset;
    }

    if (atomSize < headerSize || offset + atomSize > maxEnd) {
      return null;
    }

    return _Mp4AtomHeader(
      type: type,
      contentStart: offset + headerSize,
      end: offset + atomSize,
    );
  }

  EmbeddedLyricsData? _finalizeLyrics(EmbeddedLyricsData? lyrics) {
    if (lyrics == null) {
      return null;
    }

    var timedLyrics = _normalizeLooseText(lyrics.timedLyrics);
    var plainLyrics = _normalizePlainLyrics(lyrics.plainLyrics);

    if (timedLyrics == null &&
        plainLyrics != null &&
        _looksLikeLrc(plainLyrics)) {
      timedLyrics = plainLyrics;
      plainLyrics = null;
    }

    if (timedLyrics != null) {
      timedLyrics = _normalizeLrcText(timedLyrics);
      plainLyrics ??= _stripLrcTimestamps(timedLyrics);
    }

    final finalized = EmbeddedLyricsData(
      timedLyrics: timedLyrics,
      plainLyrics: plainLyrics,
    );
    return finalized.isEmpty ? null : finalized;
  }

  bool _matchesSignature(List<int> bytes, String signature) {
    if (bytes.length < signature.length) {
      return false;
    }
    return ascii.decode(
          bytes.sublist(0, signature.length),
          allowInvalid: true,
        ) ==
        signature;
  }

  Future<List<int>> _readBytes(
    RandomAccessFile reader, {
    required int offset,
    required int length,
  }) async {
    await reader.setPosition(offset);
    return reader.read(length);
  }

  int _readSyncSafeInt(List<int> bytes, int offset) {
    if (offset + 4 > bytes.length) {
      return 0;
    }
    return ((bytes[offset] & 0x7F) << 21) |
        ((bytes[offset + 1] & 0x7F) << 14) |
        ((bytes[offset + 2] & 0x7F) << 7) |
        (bytes[offset + 3] & 0x7F);
  }

  int _readUint32(List<int> bytes, int offset) {
    if (offset + 4 > bytes.length) {
      return 0;
    }
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  int _readUint64(List<int> bytes, int offset) {
    if (offset + 8 > bytes.length) {
      return 0;
    }
    var value = 0;
    for (var index = 0; index < 8; index++) {
      value = (value << 8) | bytes[offset + index];
    }
    return value;
  }

  List<int> _removeUnsynchronization(List<int> bytes) {
    final normalized = <int>[];
    for (var index = 0; index < bytes.length; index++) {
      final current = bytes[index];
      if (current == 0xFF &&
          index + 1 < bytes.length &&
          bytes[index + 1] == 0x00) {
        normalized.add(0xFF);
        index++;
        continue;
      }
      normalized.add(current);
    }
    return normalized;
  }

  _DecodedTextResult? _readTerminatedText(
    List<int> bytes, {
    required int start,
    required int encoding,
  }) {
    if (start > bytes.length) {
      return null;
    }

    final terminatorLength = _terminatorLengthForEncoding(encoding);
    if (terminatorLength == 1) {
      final end = bytes.indexOf(0, start);
      final actualEnd = end >= 0 ? end : bytes.length;
      return _DecodedTextResult(
        text: _decodeText(bytes.sublist(start, actualEnd), encoding: encoding),
        nextIndex: end >= 0 ? actualEnd + 1 : actualEnd,
      );
    }

    for (var index = start; index + 1 < bytes.length; index += 2) {
      if (bytes[index] == 0 && bytes[index + 1] == 0) {
        return _DecodedTextResult(
          text: _decodeText(bytes.sublist(start, index), encoding: encoding),
          nextIndex: index + 2,
        );
      }
    }

    return _DecodedTextResult(
      text: _decodeText(bytes.sublist(start), encoding: encoding),
      nextIndex: bytes.length,
    );
  }

  int _terminatorLengthForEncoding(int encoding) {
    return switch (encoding) {
      1 || 2 => 2,
      _ => 1,
    };
  }

  String _decodeText(List<int> bytes, {required int encoding}) {
    if (bytes.isEmpty) {
      return '';
    }

    return switch (encoding) {
      0 => latin1.decode(bytes, allowInvalid: true),
      1 => _decodeUtf16(bytes),
      2 => _decodeUtf16(bytes, bigEndian: true),
      3 => utf8.decode(bytes, allowMalformed: true),
      _ => _decodeLooseText(bytes),
    };
  }

  String _decodeLooseText(List<int> bytes) {
    if (bytes.isEmpty) {
      return '';
    }

    if (bytes.length >= 2 &&
        ((bytes[0] == 0xFF && bytes[1] == 0xFE) ||
            (bytes[0] == 0xFE && bytes[1] == 0xFF))) {
      return _decodeUtf16(bytes);
    }

    final evenZeroCount =
        bytes
            .asMap()
            .entries
            .where((entry) => entry.key.isEven && entry.value == 0)
            .length;
    final oddZeroCount =
        bytes
            .asMap()
            .entries
            .where((entry) => entry.key.isOdd && entry.value == 0)
            .length;
    if (oddZeroCount > bytes.length ~/ 4 || evenZeroCount > bytes.length ~/ 4) {
      return _decodeUtf16(bytes, bigEndian: evenZeroCount > oddZeroCount);
    }

    try {
      return utf8.decode(bytes);
    } on FormatException {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  String _decodeUtf16(List<int> bytes, {bool? bigEndian}) {
    if (bytes.isEmpty) {
      return '';
    }

    var offset = 0;
    var useBigEndian = bigEndian ?? false;
    if (bytes.length >= 2) {
      if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
        useBigEndian = true;
        offset = 2;
      } else if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
        useBigEndian = false;
        offset = 2;
      } else if (bigEndian == null) {
        useBigEndian = bytes[0] == 0 && bytes[1] != 0;
      }
    }

    final available = bytes.length - offset;
    final truncatedLength = available.isOdd ? available - 1 : available;
    if (truncatedLength <= 0) {
      return '';
    }

    final data = ByteData.sublistView(
      Uint8List.fromList(bytes.sublist(offset, offset + truncatedLength)),
    );
    final codeUnits = <int>[];
    for (var index = 0; index < truncatedLength; index += 2) {
      codeUnits.add(
        data.getUint16(index, useBigEndian ? Endian.big : Endian.little),
      );
    }
    return String.fromCharCodes(codeUnits);
  }

  bool _looksLikeLrc(String text) {
    return _lrcLinePattern.hasMatch(text);
  }

  String _normalizeVorbisKey(String key) {
    return key.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), '');
  }

  bool _isLyricsLikeVorbisKey(String key) {
    const exactKeys = {
      'LYRICS',
      'LYRIC',
      'LRC',
      'SYNCEDLYRICS',
      'SYNCHRONIZEDLYRICS',
      'UNSYNCEDLYRICS',
      'UNSYNCHRONIZEDLYRICS',
    };
    return exactKeys.contains(key);
  }

  String? _normalizeLooseText(String? text) {
    if (text == null) {
      return null;
    }
    final normalized =
        text
            .replaceFirst('\uFEFF', '')
            .replaceAll('\u0000', '')
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n')
            .trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _normalizePlainLyrics(String? text) {
    final normalized = _normalizeLooseText(text);
    if (normalized == null) {
      return null;
    }

    final lines = normalized
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    return lines.isEmpty ? null : lines.join('\n');
  }

  String _normalizeLrcText(String text) {
    final normalized =
        text
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n')
            .split('\n')
            .map((line) => line.trimRight())
            .where((line) => line.trim().isNotEmpty)
            .join('\n')
            .trim();
    return normalized;
  }

  String? _stripLrcTimestamps(String lrcText) {
    final lines = lrcText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          if (RegExp(
            r'^\[(ar|ti|al|by|offset):',
            caseSensitive: false,
          ).hasMatch(line)) {
            return '';
          }
          return line
              .replaceAll(
                RegExp(r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]'),
                '',
              )
              .trim();
        })
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    return lines.isEmpty ? null : lines.join('\n');
  }

  String _formatAsLrc(List<({int timestampMs, String text})> entries) {
    return entries
        .map((entry) {
          final totalMilliseconds = entry.timestampMs;
          final minutes = totalMilliseconds ~/ 60000;
          final seconds = (totalMilliseconds % 60000) ~/ 1000;
          final milliseconds = totalMilliseconds % 1000;
          final timestamp =
              '[${minutes.toString().padLeft(2, '0')}:'
              '${seconds.toString().padLeft(2, '0')}.'
              '${milliseconds.toString().padLeft(3, '0')}]';
          return '$timestamp${entry.text}';
        })
        .join('\n');
  }

  bool _isMp4ContainerAtom(String type) {
    const containerTypes = {'moov', 'udta', 'meta'};
    return containerTypes.contains(type);
  }
}

class _DecodedTextResult {
  const _DecodedTextResult({required this.text, required this.nextIndex});

  final String text;
  final int nextIndex;
}

class _Mp4AtomHeader {
  const _Mp4AtomHeader({
    required this.type,
    required this.contentStart,
    required this.end,
  });

  final String type;
  final int contentStart;
  final int end;
}
