import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../application/providers/collection_providers.dart';
import '../../application/providers/player_providers.dart';
import '../../domain/models/audio_entry.dart';
import '../widgets/audio_entry_tile.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
  });

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(collectionEntriesProvider(collectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: edit collection metadata
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No tracks in this collection.'));
          }
          return _ReorderableEntryList(
            entries: entries,
            collectionId: collectionId,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: const Text('This will only remove the collection, not the audio files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(collectionServiceProvider).deleteCollection(collectionId);
      if (context.mounted) context.pop();
    }
  }
}

class _ReorderableEntryList extends ConsumerStatefulWidget {
  const _ReorderableEntryList({
    required this.entries,
    required this.collectionId,
  });

  final List<AudioEntry> entries;
  final int collectionId;

  @override
  ConsumerState<_ReorderableEntryList> createState() =>
      _ReorderableEntryListState();
}

class _ReorderableEntryListState
    extends ConsumerState<_ReorderableEntryList> {
  late List<AudioEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.of(widget.entries);
  }

  @override
  void didUpdateWidget(_ReorderableEntryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _entries = List.of(widget.entries);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: _entries.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return AudioEntryTile(
          key: ValueKey(entry.id),
          entry: entry,
          onTap: () {
            ref
                .read(playerStateNotifierProvider.notifier)
                .playEntry(entry, context: _entries);
            context.pushNamed(RouteNames.resonancePlayer);
          },
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        );
      },
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, item);
    });

    await ref.read(collectionServiceProvider).reorderEntriesInCollection(
          widget.collectionId,
          _entries.map((e) => e.id).toList(),
        );
  }
}
