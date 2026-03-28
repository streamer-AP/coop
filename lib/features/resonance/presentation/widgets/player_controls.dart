import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
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
            icon: _repeatIcon(repeatMode, enabled: hasEntry),
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
            icon: AppIcons.icon(AppIcons.skipBack, size: 30),
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
            icon: AppIcons.icon(AppIcons.skipForward, size: 30),
            color: hasEntry ? mutedColor : disabledColor,
            onTap:
                hasEntry
                    ? () {
                      ref.read(playerStateNotifierProvider.notifier).next();
                    }
                    : null,
          ),
          _ControlIconButton(
            icon: AppIcons.icon(AppIcons.playlist, size: 24),
            color: hasEntry ? mutedColor : disabledColor,
            onTap: hasEntry ? onPlaylistTap : null,
          ),
        ],
      ),
    );
  }

  Widget _repeatIcon(RepeatMode mode, {required bool enabled}) {
    final svgPath = switch (mode) {
      RepeatMode.sequential => AppIcons.refresh2,
      RepeatMode.single => AppIcons.refresh1,
      RepeatMode.shuffle => AppIcons.shuffle,
    };

    return AppIcons.icon(
      svgPath,
      color: enabled ? const Color(0xFF6A53A7) : const Color(0xFFC8C8C8),
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
                    begin: Alignment(-0.42, -0.95),
                    end: Alignment(0.88, 1.0),
                    colors: [Color(0xFFEFECFD), Color(0xFF543A99)],
                  )
                  : const LinearGradient(
                    colors: [Color(0xFFE2E2E2), Color(0xFFD8D8D8)],
                  ),
          border:
              enabled
                  ? Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 0.8,
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF6A53A7,
              ).withValues(alpha: enabled ? 0.30 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child:
              isPlaying
                  ? AppIcons.icon(
                    AppIcons.pause,
                    size: 20,
                    color: enabled ? Colors.white : const Color(0xFFAFAFAF),
                  )
                  : AppIcons.icon(
                    AppIcons.play,
                    size: 20,
                    color: enabled ? Colors.white : const Color(0xFFAFAFAF),
                  ),
        ),
      ),
    );
  }
}
