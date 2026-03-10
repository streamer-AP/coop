import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/collection_providers.dart';
import '../../domain/models/audio_collection.dart';

class CollectionPickerDialog extends ConsumerStatefulWidget {
  const CollectionPickerDialog({
    super.key,
    required this.entryIds,
  });

  final List<int> entryIds;

  @override
  ConsumerState<CollectionPickerDialog> createState() =>
      _CollectionPickerDialogState();
}

class _CollectionPickerDialogState
    extends ConsumerState<CollectionPickerDialog> {
  final _newCollectionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _newCollectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add to Collection'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isCreating)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _newCollectionController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Collection name',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _createCollection,
                    ),
                  ),
                  onSubmitted: (_) => _createCollection(),
                ),
              ),
            Flexible(
              child: collectionsAsync.when(
                data: (collections) {
                  if (collections.isEmpty && !_isCreating) {
                    return Center(
                      child: Text(
                        'No collections yet',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      return ListTile(
                        leading: const Icon(Icons.library_music),
                        title: Text(collection.title),
                        subtitle: Text('${collection.entryCount} tracks'),
                        onTap: () => _addToCollection(collection),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!_isCreating)
          TextButton(
            onPressed: () => setState(() => _isCreating = true),
            child: const Text('New Collection'),
          ),
      ],
    );
  }

  Future<void> _createCollection() async {
    final name = _newCollectionController.text.trim();
    if (name.isEmpty) return;

    final service = ref.read(collectionServiceProvider);
    final collection = AudioCollection(id: 0, title: name);
    final id = await service.createCollection(collection);

    if (widget.entryIds.isNotEmpty) {
      await service.addEntriesToCollection(widget.entryIds, id);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _addToCollection(AudioCollection collection) async {
    final service = ref.read(collectionServiceProvider);
    await service.addEntriesToCollection(widget.entryIds, collection.id);
    if (mounted) Navigator.of(context).pop(true);
  }
}
