import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/subtitle_providers.dart';
import '../widgets/player_controls.dart';
import '../widgets/seek_bar.dart';
import '../widgets/signal_mode_toggle.dart';
import '../widgets/subtitle_view.dart';
import 'playlist_screen.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _showSubtitle = true;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateNotifierProvider);
    final currentEntry = playerState.currentEntry;
    final hasSubtitle = ref.watch(currentSubtitleNotifierProvider) != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background: cover image with gradient overlay
          _buildBackground(currentEntry?.coverPath),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(hasSubtitle),
                const SizedBox(height: 8),
                // Song title + artist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    currentEntry?.title ?? '无播放',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    currentEntry?.artist ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle / Cover area
                Expanded(
                  child: _showSubtitle && hasSubtitle
                      ? const SubtitleView()
                      : _buildCoverArea(currentEntry?.coverPath),
                ),
                // Seek bar
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SeekBar(),
                ),
                const SizedBox(height: 4),
                // Player controls
                const PlayerControls(),
                const SizedBox(height: 8),
                // Signal mode toggle
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SignalModeToggle(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(String? coverPath) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverPath != null)
            Image.file(
              File(coverPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primary,
              ),
            )
          else
            Container(color: AppColors.primary),
          // Dark gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.7),
                  AppColors.primary.withValues(alpha: 0.85),
                  AppColors.background.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool hasSubtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (hasSubtitle)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _showSubtitle ? Icons.subtitles : Icons.subtitles_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => _showSubtitle = !_showSubtitle);
                },
              ),
            ),
          const SizedBox(width: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.queue_music, color: Colors.white),
              onPressed: () => _showPlaylist(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverArea(String? coverPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: coverPath != null
              ? Image.file(
                  File(coverPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderCover(),
                )
              : _placeholderCover(),
        ),
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.music_note,
        size: 80,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }

  void _showPlaylist() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlaylistScreen(),
    );
  }
}
