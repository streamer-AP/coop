import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_entry.freezed.dart';
part 'audio_entry.g.dart';

@freezed
class AudioEntry with _$AudioEntry {
  const factory AudioEntry({
    required int id,
    required String title,
    required String filePath,
    String? coverPath,
    @Default(0) int durationMs,
    String? signalFilePath,
    @Default('audio') String mediaType,
    @Default([]) List<String> subtitleRefs,
    String? artist,
    DateTime? createdAt,
  }) = _AudioEntry;

  factory AudioEntry.fromJson(Map<String, dynamic> json) =>
      _$AudioEntryFromJson(json);
}
