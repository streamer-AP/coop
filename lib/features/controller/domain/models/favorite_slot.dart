import 'package:freezed_annotation/freezed_annotation.dart';

import 'waveform.dart';

part 'favorite_slot.freezed.dart';
part 'favorite_slot.g.dart';

@freezed
class FavoriteSlot with _$FavoriteSlot {
  const factory FavoriteSlot({
    required WaveformChannel channel,
    required int page, // 0-2
    required int index, // 0-3
    required int waveformId,
  }) = _FavoriteSlot;

  factory FavoriteSlot.fromJson(Map<String, dynamic> json) =>
      _$FavoriteSlotFromJson(json);
}
