import 'dart:async';

import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/repositories/resonance_repository.dart';

/// Manages audio collection CRUD and entry membership.
class CollectionService {
  final ResonanceRepository _repository;

  CollectionService(this._repository);

  Future<List<AudioCollection>> getAllCollections() =>
      _repository.getAllCollections();

  Future<AudioCollection?> getCollection(int id) =>
      _repository.getCollection(id);

  Future<int> createCollection(AudioCollection collection) =>
      _repository.createCollection(collection);

  /// Generate a unique collection title, appending 1, 2, 3... if duplicated.
  Future<String> uniqueCollectionTitle(
    String desired, {
    String? excludeTitle,
  }) async {
    final allTitles = await _repository.getAllCollectionTitles();
    final others =
        excludeTitle != null
            ? allTitles.where((t) => t != excludeTitle).toSet()
            : allTitles.toSet();
    if (!others.contains(desired)) return desired;
    var suffix = 1;
    while (others.contains('$desired$suffix')) {
      suffix++;
    }
    return '$desired$suffix';
  }

  Future<void> updateCollection(AudioCollection collection) =>
      _repository.updateCollection(collection);

  Future<void> deleteCollection(int id) => _repository.deleteCollection(id);

  Stream<List<AudioCollection>> watchCollections() =>
      _repository.watchCollections();

  Future<void> addEntryToCollection(int entryId, int collectionId) =>
      _repository.addEntryToCollection(entryId, collectionId);

  Future<void> addEntriesToCollection(
    List<int> entryIds,
    int collectionId,
  ) => _repository.addEntriesToCollection(entryIds, collectionId);

  Future<void> removeEntryFromCollection(int entryId, int collectionId) =>
      _repository.removeEntryFromCollection(entryId, collectionId);

  Future<List<AudioEntry>> getEntriesForCollection(int collectionId) =>
      _repository.getEntriesForCollection(collectionId);

  Stream<List<AudioEntry>> watchEntriesForCollection(int collectionId) =>
      _repository.watchEntriesForCollection(collectionId);

  Future<void> reorderEntriesInCollection(
    int collectionId,
    List<int> entryIds,
  ) => _repository.reorderEntriesInCollection(collectionId, entryIds);
}
