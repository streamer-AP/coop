import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omao_app/core/platform/audio_embedded_lyrics_extractor.dart';

void main() {
  late Directory tempDir;
  late AudioEmbeddedLyricsExtractor extractor;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('omao_lyrics_test_');
    extractor = AudioEmbeddedLyricsExtractor();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('extracts plain lyrics from MP3 USLT frame', () async {
    final file = await _writeTempFile(
      tempDir,
      'plain.mp3',
      _buildId3Tag([
        ..._buildId3Frame('USLT', <int>[
          3,
          ...ascii.encode('eng'),
          0,
          ...utf8.encode('first line\nsecond line'),
        ]),
      ]),
    );

    final lyrics = await extractor.extract(inputPath: file.path);

    expect(lyrics?.timedLyrics, isNull);
    expect(lyrics?.plainLyrics, 'first line\nsecond line');
  });

  test('extracts timed lyrics from MP3 SYLT frame', () async {
    final file = await _writeTempFile(
      tempDir,
      'timed.mp3',
      _buildId3Tag([
        ..._buildId3Frame('SYLT', <int>[
          3,
          ...ascii.encode('eng'),
          2,
          1,
          0,
          ...utf8.encode('hello'),
          0,
          ..._be32(0),
          ...utf8.encode('world'),
          0,
          ..._be32(5000),
        ]),
      ]),
    );

    final lyrics = await extractor.extract(inputPath: file.path);

    expect(lyrics?.timedLyrics, '[00:00.000]hello\n[00:05.000]world');
    expect(lyrics?.plainLyrics, 'hello\nworld');
  });

  test('extracts LRC lyrics from FLAC vorbis comments', () async {
    const lrc = '[00:00.000]alpha\n[00:04.500]beta';
    const comment = 'LYRICS=$lrc';
    final block = <int>[
      ..._le32(4),
      ...ascii.encode('test'),
      ..._le32(1),
      ..._le32(utf8.encode(comment).length),
      ...utf8.encode(comment),
    ];
    final file = await _writeTempFile(tempDir, 'embedded.flac', <int>[
      ...ascii.encode('fLaC'),
      0x84,
      (block.length >> 16) & 0xFF,
      (block.length >> 8) & 0xFF,
      block.length & 0xFF,
      ...block,
    ]);

    final lyrics = await extractor.extract(inputPath: file.path);

    expect(lyrics?.timedLyrics, lrc);
    expect(lyrics?.plainLyrics, 'alpha\nbeta');
  });

  test('extracts lyrics from MP4 ilst atom', () async {
    const lyricsText = 'line one\nline two';
    final dataAtom = _buildAtom('data', <int>[
      ...List<int>.filled(8, 0),
      ...utf8.encode(lyricsText),
    ]);
    final lyricsAtom = _buildAtom('\u00A9lyr', dataAtom);
    final ilst = _buildAtom('ilst', lyricsAtom);
    final meta = _buildAtom('meta', <int>[0, 0, 0, 0, ...ilst]);
    final udta = _buildAtom('udta', meta);
    final moov = _buildAtom('moov', udta);
    final ftyp = _buildAtom('ftyp', <int>[
      ...ascii.encode('M4A '),
      0,
      0,
      0,
      0,
      ...ascii.encode('isom'),
    ]);
    final file = await _writeTempFile(tempDir, 'lyrics.m4a', <int>[
      ...ftyp,
      ...moov,
    ]);

    final extracted = await extractor.extract(inputPath: file.path);

    expect(extracted?.timedLyrics, isNull);
    expect(extracted?.plainLyrics, lyricsText);
  });
}

Future<File> _writeTempFile(
  Directory directory,
  String name,
  List<int> bytes,
) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

List<int> _buildId3Tag(List<int> frames) {
  return <int>[
    ...ascii.encode('ID3'),
    4,
    0,
    0,
    ..._syncSafe(frames.length),
    ...frames,
  ];
}

List<int> _buildId3Frame(String id, List<int> payload) {
  return <int>[
    ...ascii.encode(id),
    ..._syncSafe(payload.length),
    0,
    0,
    ...payload,
  ];
}

List<int> _buildAtom(String type, List<int> payload) {
  final typeBytes = latin1.encode(type);
  final size = 8 + payload.length;
  return <int>[..._be32(size), ...typeBytes, ...payload];
}

List<int> _syncSafe(int value) {
  return <int>[
    (value >> 21) & 0x7F,
    (value >> 14) & 0x7F,
    (value >> 7) & 0x7F,
    value & 0x7F,
  ];
}

List<int> _be32(int value) {
  return <int>[
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF,
  ];
}

List<int> _le32(int value) {
  return <int>[
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];
}
