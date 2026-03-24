import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/omao_toast.dart';
import '../../../../core/theme/app_icons.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../../application/providers/search_providers.dart';
import '../../application/providers/sort_providers.dart';
import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../widgets/audio_entry_action_sheet.dart';
import '../widgets/audio_entry_tile.dart';
import '../widgets/collection_action_sheet.dart';
import '../widgets/collection_card.dart';
import '../widgets/create_collection_dialog.dart';
import '../widgets/import_instruction_sheet.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/sort_bottom_sheet.dart';
import 'playlist_screen.dart';

class ResonanceScreen extends ConsumerWidget {
  const ResonanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // 流光背景
            SizedBox.expand(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFFEAEAEA)),
                  // 紫色渐变 — Figma: rgba(99,78,131,0.7) → rgba(234,234,234,0.7), h=596, stop 79%
                  Container(
                    height: 596,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF634E83).withValues(alpha: 0.7),
                          const Color(0xFFEAEAEA).withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.79],
                      ),
                    ),
                  ),
                  // Radial light glow
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 393,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.15,
                        child: Image.asset(
                          'assets/figma/player/radial_light.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  // Noise texture
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.12,
                        child: Image.asset(
                          'assets/figma/player/noise_texture.png',
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.overlay,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Iridescent light
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 393,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.30,
                        child: Image.asset(
                          'assets/figma/player/iridescent_light.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildAppBar(context, ref),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFFEAEAEA).withValues(alpha: 0.3),
                                const Color(0xFFE5DCE8).withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildTabBar(),
                              const Expanded(
                                child: TabBarView(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 80),
                                      child: _AllEntriesTab(),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 80),
                                      child: _CollectionsTab(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Mini player floats at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).padding.bottom,
                    child: MiniPlayerBar(
                      onTap:
                          () => context.pushNamed(RouteNames.resonancePlayer),
                      onPlaylistTap: () => _showPlaylist(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (context) {
        final tabController = DefaultTabController.of(context);
        return AnimatedBuilder(
          animation: tabController,
          builder: (context, _) {
            final showImport = tabController.index == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: AppIcons.asset(
                      AppIcons.arrowLeft,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '共鸣',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  if (showImport)
                    _CircleButton(
                      onTap: () => _onImportTap(context, ref),
                      child: AppIcons.icon(
                        AppIcons.importIcon,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabBar() {
    return const Padding(
      padding: EdgeInsets.only(left: 16, right: 8, top: 8),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.symmetric(horizontal: 14),
              labelColor: Color(0xFF6A53A7),
              unselectedLabelColor: Colors.white,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              indicatorColor: Color(0xFF6A53A7),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              dividerHeight: 0,
              tabs: [Tab(text: '全部'), Tab(text: '合集')],
            ),
          ),
          _SortButton(),
        ],
      ),
    );
  }

  void _showPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlaylistScreen(),
    );
  }

  void _onImportTap(BuildContext context, WidgetRef ref) async {
    final confirmed = await ImportInstructionSheet.show(context);
    if (confirmed == true && context.mounted) {
      context.pushNamed(RouteNames.importScreen);
    }
  }
}

class _SortButton extends ConsumerWidget {
  const _SortButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: AppIcons.icon(
        AppIcons.sort,
        size: 24,
        color: const Color(0xFF49454F),
      ),
      onPressed: () => SortBottomSheet.show(context),
    );
  }
}

class _AllEntriesTab extends ConsumerWidget {
  const _AllEntriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(watchEntriesProvider);
    final sortMode = ref.watch(sortModeNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return entriesAsync.when(
      data: (entries) {
        var filtered = entries;

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          filtered =
              filtered
                  .where(
                    (e) =>
                        e.title.toLowerCase().contains(query) ||
                        (e.artist?.toLowerCase().contains(query) ?? false),
                  )
                  .toList();
        }

        // Apply sorting
        filtered = _sortEntries(filtered, sortMode);

        if (filtered.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final entry = filtered[index];
            return AudioEntryTile(
              entry: entry,
              onTap:
                  () => _playEntry(
                    context,
                    ref,
                    entry,
                    playlistEntries: filtered,
                    playlistTitle: '全部音频',
                  ),
              onMoreTap: () {
                AudioEntryActionSheet.show(context, entry: entry);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  List<AudioEntry> _sortEntries(List<AudioEntry> entries, SortMode mode) {
    final sorted = List<AudioEntry>.of(entries);
    switch (mode) {
      case SortMode.alphabeticalAsc:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case SortMode.alphabeticalDesc:
        sorted.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
      case SortMode.timeAsc:
        sorted.sort(
          (a, b) => (a.createdAt ?? DateTime(0)).compareTo(
            b.createdAt ?? DateTime(0),
          ),
        );
      case SortMode.timeDesc:
        sorted.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
    }
    return sorted;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcons.icon(
            AppIcons.send01,
            size: 64,
            color: const Color(0xFF79747E).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有资源哦~',
            style: TextStyle(fontSize: 16, color: Color(0xFF79747E)),
          ),
          const SizedBox(height: 4),
          const Text(
            '点击右上角导入音频',
            style: TextStyle(fontSize: 14, color: Color(0xFF79747E)),
          ),
        ],
      ),
    );
  }
}

Future<void> _playEntry(
  BuildContext context,
  WidgetRef ref,
  AudioEntry entry, {
  List<AudioEntry>? playlistEntries,
  required String playlistTitle,
}) async {
  try {
    await ref
        .read(playerStateNotifierProvider.notifier)
        .playEntryWithTitle(
          entry,
          context: playlistEntries,
          playlistTitle: playlistTitle,
        );
  } catch (error) {
    if (!context.mounted) return;
    final message = '$error'.replaceFirst('Exception: ', '').trim();
    OmaoToast.show(
      context,
      message.isEmpty ? '当前音频无法播放' : message,
      isSuccess: false,
    );
  }
}

class _CollectionsTab extends ConsumerWidget {
  const _CollectionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return collectionsAsync.when(
      data: (collections) {
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          children: [
            NewCollectionTile(
              onTap: () => _showNewCollectionDialog(context, ref),
            ),
            ...collections.map(
              (collection) => CollectionCard(
                collection: collection,
                onTap:
                    () => context.pushNamed(
                      RouteNames.collectionDetail,
                      pathParameters: {'id': collection.id.toString()},
                    ),
                onMoreTap: () {
                  CollectionActionSheet.show(context, collection: collection);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Future<void> _showNewCollectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final name = await CreateCollectionDialog.show(context);
    if (!context.mounted || name == null || name.isEmpty) {
      return;
    }
    final service = ref.read(collectionServiceProvider);
    final uniqueName = await service.uniqueCollectionTitle(name);
    await service.createCollection(AudioCollection(id: 0, title: uniqueName));
  }
}

/// 30% white circle button matching Figma top bar style.
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
