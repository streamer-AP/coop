import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_collection.freezed.dart';
part 'audio_collection.g.dart';

@freezed
class AudioCollection with _$AudioCollection {
  const factory AudioCollection({
    required int id,
    required String title,
    String? coverPath,
    String? description,
    @Default([]) List<int> entryIds,
    @Default(0) int entryCount,
    @Default(0) int totalDurationMs,
  }) = _AudioCollection;

  factory AudioCollection.fromJson(Map<String, dynamic> json) =>
      _$AudioCollectionFromJson(json);
}
