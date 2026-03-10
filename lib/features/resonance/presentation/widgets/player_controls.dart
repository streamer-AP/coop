import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/player_providers.dart';
import '../../domain/models/playlist.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final playlistSvc = ref.watch(playlistServiceProvider);
    final repeatMode = playlistSvc.currentPlaylist.repeatMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: _repeatIcon(repeatMode),
          onPressed: () {
            ref.read(playerStateNotifierProvider.notifier).cycleRepeatMode();
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 36,
          onPressed: () {
            ref.read(playerStateNotifierProvider.notifier).previous();
          },
        ),
        const SizedBox(width: 8),
        FilledButton.tonal(
          onPressed: () {
            final notifier = ref.read(playerStateNotifierProvider.notifier);
            playerState.isPlaying ? notifier.pause() : notifier.play();
          },
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(
            playerState.isPlaying ? Icons.pause : Icons.play_arrow,
            size: 36,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 36,
          onPressed: () {
            ref.read(playerStateNotifierProvider.notifier).next();
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.queue_music),
          onPressed: () {
            // Open playlist screen (handled by parent)
          },
        ),
      ],
    );
  }

  Widget _repeatIcon(RepeatMode mode) {
    return switch (mode) {
      RepeatMode.sequential => const Icon(Icons.repeat),
      RepeatMode.single => const Icon(Icons.repeat_one),
      RepeatMode.shuffle => const Icon(Icons.shuffle),
    };
  }
}
