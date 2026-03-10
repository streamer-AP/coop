import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/player_providers.dart';
import '../../application/providers/subtitle_providers.dart';
import '../widgets/player_controls.dart';
import '../widgets/seek_bar.dart';
import '../widgets/signal_mode_toggle.dart';
import '../widgets/subtitle_view.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _showSubtitle = false;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final currentEntry = playerState.currentEntry;
    final hasSubtitle = ref.watch(currentSubtitleNotifierProvider) != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (hasSubtitle)
            IconButton(
              icon: Icon(
                _showSubtitle ? Icons.subtitles : Icons.subtitles_outlined,
              ),
              onPressed: () {
                setState(() => _showSubtitle = !_showSubtitle);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _showSubtitle && hasSubtitle
                  ? const SubtitleView()
                  : _buildCover(theme, currentEntry?.coverPath),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                currentEntry?.title ?? 'No track',
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const SeekBar(),
            const SizedBox(height: 8),
            const PlayerControls(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: SignalModeToggle(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(ThemeData theme, String? coverPath) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: coverPath != null
              ? Image.file(
                  File(coverPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderCover(theme),
                )
              : _placeholderCover(theme),
        ),
      ),
    );
  }

  Widget _placeholderCover(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note,
        size: 80,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
