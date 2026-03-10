import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/player_providers.dart';
import '../../domain/models/playlist.dart';
import '../widgets/audio_entry_tile.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistSvc = ref.watch(playlistServiceProvider);
    final playlist = playlistSvc.currentPlaylist;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildHandle(theme),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Playlist (${playlist.length})',
                      style: theme.textTheme.titleMedium,
                    ),
                    _buildRepeatModeChip(ref, playlist.repeatMode, theme),
                  ],
                ),
              ),
              Expanded(
                child: playlist.isEmpty
                    ? const Center(child: Text('Playlist is empty'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: playlist.items.length,
                        itemBuilder: (context, index) {
                          final item = playlist.items[index];
                          final isCurrent = index == playlist.currentIndex;

                          return Dismissible(
                            key: ValueKey(item.uid),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: theme.colorScheme.errorContainer,
                              child: Icon(
                                Icons.delete,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            onDismissed: (_) {
                              ref
                                  .read(playlistServiceProvider)
                                  .removeItem(item.uid);
                            },
                            child: AudioEntryTile(
                              entry: item.entry,
                              onTap: () {
                                ref
                                    .read(playerStateNotifierProvider.notifier)
                                    .playEntry(item.entry);
                              },
                              trailing: isCurrent
                                  ? Icon(
                                      Icons.equalizer,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildRepeatModeChip(
    WidgetRef ref,
    RepeatMode mode,
    ThemeData theme,
  ) {
    final (icon, label) = switch (mode) {
      RepeatMode.sequential => (Icons.repeat, 'Sequential'),
      RepeatMode.single => (Icons.repeat_one, 'Single'),
      RepeatMode.shuffle => (Icons.shuffle, 'Shuffle'),
    };

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        ref.read(playerStateNotifierProvider.notifier).cycleRepeatMode();
      },
    );
  }
}
