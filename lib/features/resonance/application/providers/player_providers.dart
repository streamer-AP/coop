import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_providers.g.dart';

enum RepeatMode { off, one, all }

@riverpod
class PlayerNotifier extends _$PlayerNotifier {
  @override
  PlayerState build() {
    return const PlayerState();
  }

  void play() {
    // TODO: implement with just_audio
  }

  void pause() {
    // TODO: implement
  }

  void seekTo(Duration position) {
    // TODO: implement
  }
}

class PlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final RepeatMode repeatMode;

  const PlayerState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeatMode = RepeatMode.off,
  });
}
