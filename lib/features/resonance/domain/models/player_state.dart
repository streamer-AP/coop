import 'package:freezed_annotation/freezed_annotation.dart';

import 'audio_entry.dart';

part 'player_state.freezed.dart';

enum SignalMode {
  off,
  resonance,
  preset,
}

@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    AudioEntry? currentEntry,
    @Default(SignalMode.off) SignalMode signalMode,
  }) = _PlayerState;
}
