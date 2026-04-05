import 'dart:convert';
import 'dart:io';

import '../../domain/models/subtitle.dart';

/// Parses subtitle files in 5 formats and provides position-based cue lookup.
class SubtitleService {
  Future<String> readTextFile(String path) async {
    final bytes = await File(path).readAsBytes();
    return decodeTextBytes(bytes);
  }

  String decodeTextBytes(List<int> bytes) {
    if (bytes.isEmpty) return '';

    try {
      return _normalizeDecodedText(utf8.decode(bytes));
    } on FormatException {
      return _normalizeDecodedText(utf8.decode(bytes, allowMalformed: true));
    }
  }

  /// Parse a subtitle file content based on its format.
  ParsedSubtitle parse(SubtitleRef ref, String content) {
    final cues = switch (ref.format) {
      SubtitleFormat.srt => _parseSrt(content),
      SubtitleFormat.vtt => _parseVtt(content),
      SubtitleFormat.lrc => _parseLrc(content),
      SubtitleFormat.sub => _parseSub(content),
      SubtitleFormat.stl => _parseStl(content),
    };
    return ParsedSubtitle(ref: ref, cues: cues);
  }

  /// Find the cue at a given position.
  SubtitleCue? cueAtPosition(ParsedSubtitle subtitle, Duration position) {
    for (final cue in subtitle.cues) {
      if (position >= cue.start && position <= cue.end) {
        return cue;
      }
    }
    return null;
  }

  /// Find the index of the cue at a given position (for UI scrolling).
  int cueIndexAtPosition(ParsedSubtitle subtitle, Duration position) {
    for (int i = 0; i < subtitle.cues.length; i++) {
      if (position >= subtitle.cues[i].start &&
          position <= subtitle.cues[i].end) {
        return i;
      }
    }
    // Return closest upcoming cue
    for (int i = 0; i < subtitle.cues.length; i++) {
      if (subtitle.cues[i].start > position) {
        return i > 0 ? i - 1 : 0;
      }
    }
    return subtitle.cues.length - 1;
  }

  // --- SRT Parser ---
  List<SubtitleCue> _parseSrt(String content) {
    final cues = <SubtitleCue>[];
    final blocks = content.trim().split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;

      final timeLine = lines[1];
      final match = RegExp(
        r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})',
      ).firstMatch(timeLine);

      if (match == null) continue;

      final start = _parseSrtTime(match, 1);
      final end = _parseSrtTime(match, 5);
      final text = lines
          .sublist(2)
          .join('\n')
          .replaceAll(RegExp(r'<[^>]+>'), '');

      cues.add(SubtitleCue(start: start, end: end, text: text));
    }

    return cues;
  }

  Duration _parseSrtTime(RegExpMatch match, int offset) {
    return Duration(
      hours: int.parse(match.group(offset)!),
      minutes: int.parse(match.group(offset + 1)!),
      seconds: int.parse(match.group(offset + 2)!),
      milliseconds: int.parse(match.group(offset + 3)!),
    );
  }

  // --- VTT Parser ---
  List<SubtitleCue> _parseVtt(String content) {
    final cues = <SubtitleCue>[];
    // Strip WEBVTT header and any metadata lines before the first blank line
    final stripped = content.replaceFirst(
      RegExp(r'^WEBVTT[^\n]*\n(?:[^\n]+\n)*\n?'),
      '',
    );
    final blocks = stripped.trim().split(RegExp(r'\n\s*\n'));
    final timePattern = RegExp(
      r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})',
    );

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      // Find the line with the timestamp (could be first or second line)
      int timeLineIndex = -1;
      RegExpMatch? match;
      for (var i = 0; i < lines.length; i++) {
        match = timePattern.firstMatch(lines[i]);
        if (match != null) {
          timeLineIndex = i;
          break;
        }
      }
      if (match == null || timeLineIndex < 0) continue;

      final start = _parseSrtTime(match, 1);
      final end = _parseSrtTime(match, 5);
      final textLines = lines.sublist(timeLineIndex + 1);
      if (textLines.isEmpty) continue;
      final text = textLines.join('\n').replaceAll(RegExp(r'<[^>]+>'), '');

      cues.add(SubtitleCue(start: start, end: end, text: text));
    }

    return cues;
  }

  // --- LRC Parser ---
  List<SubtitleCue> _parseLrc(String content) {
    final cues = <SubtitleCue>[];
    final lines = content.trim().split('\n');
    final pattern = RegExp(r'\[(\d{2}):(\d{2})[.](\d{2,3})\](.*)');

    final timestamps = <(Duration, String)>[];
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match == null) continue;

      final ms = match.group(3)!;
      final millis = ms.length == 2 ? int.parse(ms) * 10 : int.parse(ms);
      final start = Duration(
        minutes: int.parse(match.group(1)!),
        seconds: int.parse(match.group(2)!),
        milliseconds: millis,
      );
      final text = match.group(4)?.trim() ?? '';
      if (text.isNotEmpty) {
        timestamps.add((start, text));
      }
    }

    for (int i = 0; i < timestamps.length; i++) {
      final end =
          i + 1 < timestamps.length
              ? timestamps[i + 1].$1
              : timestamps[i].$1 + const Duration(seconds: 5);
      cues.add(
        SubtitleCue(start: timestamps[i].$1, end: end, text: timestamps[i].$2),
      );
    }

    return cues;
  }

  // --- SUB (MicroDVD) Parser ---
  List<SubtitleCue> _parseSub(String content) {
    final cues = <SubtitleCue>[];
    final lines = content.trim().split('\n');
    const fps = 25.0; // Default frame rate for MicroDVD

    for (final line in lines) {
      final match = RegExp(r'\{(\d+)\}\{(\d+)\}(.*)').firstMatch(line);
      if (match == null) continue;

      final startFrame = int.parse(match.group(1)!);
      final endFrame = int.parse(match.group(2)!);
      final text = match.group(3)!.replaceAll('|', '\n');

      cues.add(
        SubtitleCue(
          start: Duration(milliseconds: (startFrame / fps * 1000).round()),
          end: Duration(milliseconds: (endFrame / fps * 1000).round()),
          text: text,
        ),
      );
    }

    return cues;
  }

  // --- STL (Spruce Subtitle) Parser ---
  List<SubtitleCue> _parseStl(String content) {
    final cues = <SubtitleCue>[];
    final lines = content.trim().split('\n');
    final pattern = RegExp(
      r'(\d{2}):(\d{2}):(\d{2}):(\d{2})\s*,\s*(\d{2}):(\d{2}):(\d{2}):(\d{2})\s*,\s*(.*)',
    );

    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match == null) continue;

      final start = Duration(
        hours: int.parse(match.group(1)!),
        minutes: int.parse(match.group(2)!),
        seconds: int.parse(match.group(3)!),
        milliseconds: int.parse(match.group(4)!) * 40, // frames to ms at 25fps
      );
      final end = Duration(
        hours: int.parse(match.group(5)!),
        minutes: int.parse(match.group(6)!),
        seconds: int.parse(match.group(7)!),
        milliseconds: int.parse(match.group(8)!) * 40,
      );
      final text = match.group(9)!.replaceAll('|', '\n');

      cues.add(SubtitleCue(start: start, end: end, text: text));
    }

    return cues;
  }

  String _normalizeDecodedText(String content) {
    return content.replaceFirst('\uFEFF', '').replaceAll('\u0000', '');
  }
}
