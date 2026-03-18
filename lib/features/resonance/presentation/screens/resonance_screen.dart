import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
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
            // Purple gradient background
            Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, ref),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.listBackground,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTabBar(),
                          const Expanded(
                            child: TabBarView(
                              children: [_AllEntriesTab(), _CollectionsTab()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MiniPlayerBar(
                    onTap: () => context.pushNamed(RouteNames.resonancePlayer),
                    onPlaylistTap: () => _showPlaylist(context),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 28),
                      onPressed: () => context.pop(),
                      color: const Color(0xFF49454F),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '共鸣',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1B1F),
                      ),
                    ),
                  ),
                  if (showImport)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_box_outlined, size: 24),
                        onPressed: () => _onImportTap(context, ref),
                        color: const Color(0xFF49454F),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
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
              labelPadding: EdgeInsets.only(right: 24),
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
      icon: const Icon(Icons.sort, color: Color(0xFF49454F), size: 24),
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
                  () => _playAndOpenPlayer(
                    context,
                    ref,
                    entry,
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
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case SortMode.alphabeticalDesc:
        sorted.sort((a, b) => b.title.compareTo(a.title));
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
          Icon(
            Icons.send,
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

Future<void> _playAndOpenPlayer(
  BuildContext context,
  WidgetRef ref,
  AudioEntry entry, {
  List<AudioEntry>? playlistEntries,
  required String playlistTitle,
}) async {
  String? errorMessage;
  try {
    await ref
        .read(playerStateNotifierProvider.notifier)
        .playEntryWithTitle(
          entry,
          context: playlistEntries,
          playlistTitle: playlistTitle,
        );
  } catch (error) {
    errorMessage = '$error'.replaceFirst('Exception: ', '').trim();
  }

  if (!context.mounted) return;
  context.pushNamed(RouteNames.resonancePlayer);

  final message = errorMessage;
  if (message != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.isEmpty ? '当前音频无法播放' : message)),
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
            // New collection entry
            InkWell(
              onTap: () => _showNewCollectionDialog(context, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF79747E),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '新建合集',
                      style: TextStyle(fontSize: 16, color: Color(0xFF79747E)),
                    ),
                  ],
                ),
              ),
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

  void _showNewCollectionDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('新建合集'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '请输入合集名称'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  final service = ref.read(collectionServiceProvider);
                  await service.createCollection(
                    AudioCollection(id: 0, title: name),
                  );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }
}
