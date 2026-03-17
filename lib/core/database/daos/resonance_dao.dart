import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/resonance_tables.dart';

part 'resonance_dao.g.dart';

@DriftAccessor(
  tables: [
    AudioEntries,
    AudioCollections,
    EntryCollectionCrossRef,
    Playlists,
    PlaylistItems,
    Subtitles,
    SignalFiles,
    ScriptFiles,
  ],
)
class ResonanceDao extends DatabaseAccessor<AppDatabase>
    with _$ResonanceDaoMixin {
  ResonanceDao(super.db);

  // ── AudioEntries ──────────────────────────────────────────────────────

  Future<List<AudioEntry>> getAllEntries() => select(audioEntries).get();

  Stream<List<AudioEntry>> watchAllEntries() => select(audioEntries).watch();

  Future<AudioEntry?> getEntry(int id) =>
      (select(audioEntries)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertEntry(AudioEntriesCompanion entry) =>
      into(audioEntries).insert(entry);

  Future<void> insertEntries(List<AudioEntriesCompanion> entries) async {
    await batch((b) => b.insertAll(audioEntries, entries));
  }

  Future<bool> updateEntry(AudioEntriesCompanion entry) =>
      update(audioEntries).replace(entry);

  Future<int> deleteEntry(int id) =>
      (delete(audioEntries)..where((t) => t.id.equals(id))).go();

  Future<void> deleteEntries(List<int> ids) async {
    await (delete(audioEntries)..where((t) => t.id.isIn(ids))).go();
  }

  // ── AudioCollections ──────────────────────────────────────────────────

  Future<List<AudioCollection>> getAllCollections() =>
      select(audioCollections).get();

  /// Returns collections with entry counts as a map.
  Future<Map<int, int>> getCollectionEntryCounts() async {
    final query = select(audioCollections).join([
      leftOuterJoin(
        entryCollectionCrossRef,
        entryCollectionCrossRef.collectionId.equalsExp(audioCollections.id),
      ),
    ]);

    final rows = await query.get();
    final counts = <int, int>{};
    for (final row in rows) {
      final collection = row.readTable(audioCollections);
      final crossRef = row.readTableOrNull(entryCollectionCrossRef);
      counts[collection.id] =
          (counts[collection.id] ?? 0) + (crossRef != null ? 1 : 0);
    }
    return counts;
  }

  Stream<List<AudioCollection>> watchAllCollections() =>
      select(audioCollections).watch();

  Future<AudioCollection?> getCollection(int id) =>
      (select(audioCollections)
        ..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertCollection(AudioCollectionsCompanion collection) =>
      into(audioCollections).insert(collection);

  Future<bool> updateCollection(AudioCollectionsCompanion collection) =>
      update(audioCollections).replace(collection);

  Future<int> deleteCollection(int id) =>
      (delete(audioCollections)..where((t) => t.id.equals(id))).go();

  // ── EntryCollectionCrossRef ───────────────────────────────────────────

  Future<void> addEntryToCollection(int entryId, int collectionId) async {
    final maxOrder = await _maxSortOrder(collectionId);
    await into(entryCollectionCrossRef).insert(
      EntryCollectionCrossRefCompanion.insert(
        entryId: entryId,
        collectionId: collectionId,
        sortOrder: Value(maxOrder + 1),
      ),
    );
  }

  Future<void> addEntriesToCollection(
    List<int> entryIds,
    int collectionId,
  ) async {
    final maxOrder = await _maxSortOrder(collectionId);
    await batch((b) {
      for (var i = 0; i < entryIds.length; i++) {
        b.insert(
          entryCollectionCrossRef,
          EntryCollectionCrossRefCompanion.insert(
            entryId: entryIds[i],
            collectionId: collectionId,
            sortOrder: Value(maxOrder + i + 1),
          ),
        );
      }
    });
  }

  Future<int> removeEntryFromCollection(int entryId, int collectionId) =>
      (delete(entryCollectionCrossRef)..where(
        (t) => t.entryId.equals(entryId) & t.collectionId.equals(collectionId),
      )).go();

  Future<List<AudioEntry>> getEntriesForCollection(int collectionId) async {
    final query =
        select(audioEntries).join([
            innerJoin(
              entryCollectionCrossRef,
              entryCollectionCrossRef.entryId.equalsExp(audioEntries.id),
            ),
          ])
          ..where(entryCollectionCrossRef.collectionId.equals(collectionId))
          ..orderBy([OrderingTerm.asc(entryCollectionCrossRef.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(audioEntries)).toList();
  }

  Stream<List<AudioEntry>> watchEntriesForCollection(int collectionId) {
    final query =
        select(audioEntries).join([
            innerJoin(
              entryCollectionCrossRef,
              entryCollectionCrossRef.entryId.equalsExp(audioEntries.id),
            ),
          ])
          ..where(entryCollectionCrossRef.collectionId.equals(collectionId))
          ..orderBy([OrderingTerm.asc(entryCollectionCrossRef.sortOrder)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(audioEntries)).toList(),
    );
  }

  Future<void> reorderEntriesInCollection(
    int collectionId,
    List<int> entryIds,
  ) async {
    await batch((b) {
      for (var i = 0; i < entryIds.length; i++) {
        b.update(
          entryCollectionCrossRef,
          EntryCollectionCrossRefCompanion(sortOrder: Value(i)),
          where:
              ($EntryCollectionCrossRefTable t) =>
                  t.entryId.equals(entryIds[i]) &
                  t.collectionId.equals(collectionId),
        );
      }
    });
  }

  Future<int> _maxSortOrder(int collectionId) async {
    final query =
        selectOnly(entryCollectionCrossRef)
          ..addColumns([entryCollectionCrossRef.sortOrder.max()])
          ..where(entryCollectionCrossRef.collectionId.equals(collectionId));
    final result = await query.getSingleOrNull();
    return result?.read(entryCollectionCrossRef.sortOrder.max()) ?? -1;
  }

  // ── Subtitles ─────────────────────────────────────────────────────────

  Future<List<Subtitle>> getSubtitlesForEntry(int entryId) =>
      (select(subtitles)..where((t) => t.entryId.equals(entryId))).get();

  Future<int> insertSubtitle(SubtitlesCompanion subtitle) =>
      into(subtitles).insert(subtitle);

  Future<int> deleteSubtitlesForEntry(int entryId) =>
      (delete(subtitles)..where((t) => t.entryId.equals(entryId))).go();

  // ── SignalFiles ───────────────────────────────────────────────────────

  Future<SignalFile?> getSignalFileForEntry(int entryId) =>
      (select(signalFiles)
        ..where((t) => t.entryId.equals(entryId))).getSingleOrNull();

  Future<int> insertSignalFile(SignalFilesCompanion signalFile) =>
      into(signalFiles).insert(signalFile);

  Future<int> deleteSignalFilesForEntry(int entryId) =>
      (delete(signalFiles)..where((t) => t.entryId.equals(entryId))).go();

  // ── ScriptFiles ───────────────────────────────────────────────────────

  Future<ScriptFile?> getScriptFileForEntry(int entryId) =>
      (select(scriptFiles)
        ..where((t) => t.entryId.equals(entryId))).getSingleOrNull();

  Future<int> insertScriptFile(ScriptFilesCompanion scriptFile) =>
      into(scriptFiles).insert(scriptFile);

  Future<int> deleteScriptFilesForEntry(int entryId) =>
      (delete(scriptFiles)..where((t) => t.entryId.equals(entryId))).go();
}
