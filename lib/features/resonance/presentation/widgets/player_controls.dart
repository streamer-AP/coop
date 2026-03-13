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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Repeat mode
          IconButton(
            icon: _repeatIcon(repeatMode),
            onPressed: () {
              ref.read(playerStateNotifierProvider.notifier).cycleRepeatMode();
            },
          ),
          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
            iconSize: 36,
            color: Colors.white,
            onPressed: () {
              ref.read(playerStateNotifierProvider.notifier).previous();
            },
          ),
          // Play / Pause
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              icon: Icon(
                playerState.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 36,
                color: Colors.white,
              ),
              onPressed: () {
                final notifier = ref.read(playerStateNotifierProvider.notifier);
                playerState.isPlaying ? notifier.pause() : notifier.play();
              },
            ),
          ),
          // Next
          IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            iconSize: 36,
            color: Colors.white,
            onPressed: () {
              ref.read(playerStateNotifierProvider.notifier).next();
            },
          ),
          // Invisible counterpart to balance the repeat button on the left
          const Opacity(
            opacity: 0,
            child: IconButton(
              icon: Icon(Icons.repeat),
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _repeatIcon(RepeatMode mode) {
    final (icon, isActive) = switch (mode) {
      RepeatMode.sequential => (Icons.repeat, false),
      RepeatMode.single => (Icons.repeat_one, true),
      RepeatMode.shuffle => (Icons.shuffle, true),
    };

    return Icon(
      icon,
      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
    );
  }
}
