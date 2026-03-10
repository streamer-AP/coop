import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/player_providers.dart';
import '../../domain/models/audio_entry.dart';

class AudioEntryTile extends ConsumerWidget {
  const AudioEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final AudioEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final isPlaying = playerState.currentEntry?.id == entry.id;
    final theme = Theme.of(context);

    return ListTile(
      leading: _buildCover(theme),
      title: Text(
        entry.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isPlaying
            ? TextStyle(color: theme.colorScheme.primary)
            : null,
      ),
      subtitle: Text(
        _formatDuration(Duration(milliseconds: entry.durationMs)),
        style: theme.textTheme.bodySmall,
      ),
      trailing: trailing ??
          (isPlaying
              ? Icon(Icons.equalizer, color: theme.colorScheme.primary)
              : null),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildCover(ThemeData theme) {
    if (entry.coverPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(entry.coverPath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(theme),
        ),
      );
    }
    return _placeholderCover(theme);
  }

  Widget _placeholderCover(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.music_note,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
