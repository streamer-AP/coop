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
  }) = _AudioEntry;

  factory AudioEntry.fromJson(Map<String, dynamic> json) =>
      _$AudioEntryFromJson(json);
}
