import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/player_providers.dart';
import '../../domain/models/playlist.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key, this.onPlaylistTap});

  final VoidCallback? onPlaylistTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final playlist =
        ref.watch(playlistStateProvider).valueOrNull ??
        ref.read(playlistServiceProvider).currentPlaylist;
    final repeatMode = playlist.repeatMode;
    final hasEntry = playerState.currentEntry != null;
    const mutedColor = Color(0xFF797979);
    const disabledColor = Color(0xFFC8C8C8);

    return SizedBox(
      width: 349,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ControlIconButton(
            icon: _repeatIcon(repeatMode),
            color: hasEntry ? mutedColor : disabledColor,
            onTap:
                hasEntry
                    ? () {
                      ref
                          .read(playerStateNotifierProvider.notifier)
                          .cycleRepeatMode();
                    }
                    : null,
          ),
          _ControlIconButton(
            icon: const Icon(Icons.skip_previous_rounded, size: 30),
            color: hasEntry ? mutedColor : disabledColor,
            onTap:
                hasEntry
                    ? () {
                      ref.read(playerStateNotifierProvider.notifier).previous();
                    }
                    : null,
          ),
          _PlayPauseButton(
            enabled: hasEntry,
            isPlaying: playerState.isPlaying,
            onTap: () {
              final notifier = ref.read(playerStateNotifierProvider.notifier);
              playerState.isPlaying ? notifier.pause() : notifier.play();
            },
          ),
          _ControlIconButton(
            icon: const Icon(Icons.skip_next_rounded, size: 30),
            color: hasEntry ? mutedColor : disabledColor,
            onTap:
                hasEntry
                    ? () {
                      ref.read(playerStateNotifierProvider.notifier).next();
                    }
                    : null,
          ),
          _ControlIconButton(
            icon: const Icon(Icons.queue_music_rounded, size: 24),
            color: hasEntry ? mutedColor : disabledColor,
            onTap: hasEntry ? onPlaylistTap : null,
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

class _ControlIconButton extends StatelessWidget {
  const _ControlIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final Widget icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        splashRadius: 24,
        icon: IconTheme(data: IconThemeData(color: color), child: icon),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.enabled,
    required this.isPlaying,
    required this.onTap,
  });

  final bool enabled;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient:
              enabled
                  ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFF0ECFB)],
                  )
                  : const LinearGradient(
                    colors: [Color(0xFFE2E2E2), Color(0xFFD8D8D8)],
                  ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF8E7FB0,
              ).withValues(alpha: enabled ? 0.22 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 34,
          color: enabled ? const Color(0xFF6A53A7) : const Color(0xFFAFAFAF),
        ),
      ),
    );
  }
}
