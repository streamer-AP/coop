import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtitle.freezed.dart';
part 'subtitle.g.dart';

enum SubtitleFormat {
  srt,
  vtt,
  lrc,
  sub,
  stl,
}

@freezed
class SubtitleRef with _$SubtitleRef {
  const factory SubtitleRef({
    required int id,
    required int entryId,
    required String language,
    required String filePath,
    @Default(SubtitleFormat.srt) SubtitleFormat format,
  }) = _SubtitleRef;

  factory SubtitleRef.fromJson(Map<String, dynamic> json) =>
      _$SubtitleRefFromJson(json);
}

@freezed
class SubtitleCue with _$SubtitleCue {
  const factory SubtitleCue({
    required Duration start,
    required Duration end,
    required String text,
  }) = _SubtitleCue;
}

@freezed
class ParsedSubtitle with _$ParsedSubtitle {
  const factory ParsedSubtitle({
    required SubtitleRef ref,
    @Default([]) List<SubtitleCue> cues,
  }) = _ParsedSubtitle;
}
