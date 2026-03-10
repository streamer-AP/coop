import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/providers/player_providers.dart';
import '../../application/providers/resonance_providers.dart';
import '../widgets/audio_entry_tile.dart';
import '../widgets/collection_card.dart';

class ResonanceScreen extends ConsumerWidget {
  const ResonanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resonance'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Collections'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AllEntriesTab(),
            _CollectionsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed(RouteNames.importScreen),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AllEntriesTab extends ConsumerWidget {
  const _AllEntriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(watchEntriesProvider);

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('No audio files yet. Tap + to import.'));
        }
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return AudioEntryTile(
              entry: entry,
              onTap: () {
                ref
                    .read(playerStateNotifierProvider.notifier)
                    .playEntry(entry, context: entries);
                context.pushNamed(RouteNames.resonancePlayer);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
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
        if (collections.isEmpty) {
          return const Center(child: Text('No collections yet.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];
            return CollectionCard(
              collection: collection,
              onTap: () => context.pushNamed(
                RouteNames.collectionDetail,
                pathParameters: {'id': collection.id.toString()},
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
