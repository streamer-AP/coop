import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/daos/resonance_dao.dart';
import '../domain/models/audio_entry.dart';
import '../domain/models/audio_collection.dart';
import '../domain/models/subtitle.dart';
import '../domain/repositories/resonance_repository.dart';

class ResonanceRepositoryImpl implements ResonanceRepository {
  final ResonanceDao _dao;

  ResonanceRepositoryImpl(this._dao);

  // ── Mapping helpers ───────────────────────────────────────────────────

  AudioEntry _mapEntry(db.AudioEntry row) {
    return AudioEntry(
      id: row.id,
      title: row.title,
      filePath: row.filePath,
      coverPath: row.coverPath,
      durationMs: row.durationMs,
      signalFilePath: row.signalFilePath,
      mediaType: row.mediaType,
      artist: row.artist,
      createdAt: row.createdAt,
    );
  }

  db.AudioEntriesCompanion _toEntryCompanion(AudioEntry entry) {
    return db.AudioEntriesCompanion(
      id: entry.id == 0 ? const Value.absent() : Value(entry.id),
      title: Value(entry.title),
      filePath: Value(entry.filePath),
      coverPath: Value(entry.coverPath),
      durationMs: Value(entry.durationMs),
      signalFilePath: Value(entry.signalFilePath),
      mediaType: Value(entry.mediaType),
      artist: Value(entry.artist),
      createdAt:
          entry.createdAt != null
              ? Value(entry.createdAt!)
              : const Value.absent(),
    );
  }

  AudioCollection _mapCollection(
    db.AudioCollection row, {
    int entryCount = 0,
    int totalDurationMs = 0,
    List<int> entryIds = const [],
  }) {
    return AudioCollection(
      id: row.id,
      title: row.title,
      coverPath: row.coverPath,
      description: row.description,
      entryIds: entryIds,
      entryCount: entryCount,
      totalDurationMs: totalDurationMs,
    );
  }

  SubtitleRef _mapSubtitle(db.Subtitle row) {
    return SubtitleRef(
      id: row.id,
      entryId: row.entryId,
      language: row.language,
      filePath: row.filePath,
      format: SubtitleFormat.values.byName(row.format),
    );
  }

  // ── AudioEntries ──────────────────────────────────────────────────────

  @override
  Future<List<AudioEntry>> getAllEntries() async {
    final rows = await _dao.getAllEntries();
    return rows.map(_mapEntry).toList();
  }

  @override
  Future<List<String>> getAllEntryTitles() async {
    final rows = await _dao.getAllEntries();
    return rows.map((r) => r.title).toList();
  }

  @override
  Stream<List<AudioEntry>> watchAllEntries() {
    return _dao.watchAllEntries().map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Future<AudioEntry?> getEntry(int id) async {
    final row = await _dao.getEntry(id);
    return row != null ? _mapEntry(row) : null;
  }

  @override
  Future<int> insertEntry(AudioEntry entry) {
    return _dao.insertEntry(_toEntryCompanion(entry));
  }

  @override
  Future<void> insertEntries(List<AudioEntry> entries) {
    return _dao.insertEntries(entries.map(_toEntryCompanion).toList());
  }

  @override
  Future<void> updateEntry(AudioEntry entry) async {
    await _dao.updateEntry(
      _toEntryCompanion(entry).copyWith(id: Value(entry.id)),
    );
  }

  @override
  Future<void> deleteEntry(int id) async {
    await _dao.deleteEntry(id);
  }

  @override
  Future<void> deleteEntryCompletely(int id) async {
    // Gather file paths before deleting DB records
    final entry = await getEntry(id);
    final subtitles = await getSubtitlesForEntry(id);
    final signalPath = await getSignalFilePathForEntry(id);
    final scriptPath = await getScriptFilePathForEntry(id);

    // Delete DB records (order matters: children first)
    await _dao.deleteSubtitlesForEntry(id);
    await _dao.deleteSignalFilesForEntry(id);
    await _dao.deleteScriptFilesForEntry(id);
    await _dao.deleteEntryFromAllCollections(id);
    await _dao.deletePlaylistItemsForEntry(id);
    await _dao.deleteEntry(id);

    // Delete files from disk
    Future<void> deleteFile(String? path) async {
      if (path == null) return;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    if (entry != null) {
      await deleteFile(entry.filePath);
      await deleteFile(entry.coverPath);
    }
    for (final sub in subtitles) {
      await deleteFile(sub.filePath);
    }
    await deleteFile(signalPath);
    await deleteFile(scriptPath);
  }

  @override
  Future<void> deleteEntries(List<int> ids) {
    return _dao.deleteEntries(ids);
  }

  // ── AudioCollections ──────────────────────────────────────────────────

  @override
  Future<List<AudioCollection>> getAllCollections() async {
    final rows = await _dao.getAllCollections();
    final counts = await _dao.getCollectionEntryCounts();
    final durations = await _dao.getCollectionTotalDurations();
    return rows
        .map(
          (row) => _mapCollection(
            row,
            entryCount: counts[row.id] ?? 0,
            totalDurationMs: durations[row.id] ?? 0,
          ),
        )
        .toList();
  }

  @override
  Stream<List<AudioCollection>> watchCollections() {
    return _dao.watchAllCollections().asyncMap((rows) async {
      final counts = await _dao.getCollectionEntryCounts();
      final durations = await _dao.getCollectionTotalDurations();
      return rows
          .map(
            (row) => _mapCollection(
              row,
              entryCount: counts[row.id] ?? 0,
              totalDurationMs: durations[row.id] ?? 0,
            ),
          )
          .toList();
    });
  }

  @override
  Future<AudioCollection?> getCollection(int id) async {
    final row = await _dao.getCollection(id);
    if (row == null) return null;
    final entries = await _dao.getEntriesForCollection(id);
    return _mapCollection(
      row,
      entryCount: entries.length,
      entryIds: entries.map((e) => e.id).toList(),
    );
  }

  @override
  Future<int> createCollection(AudioCollection collection) {
    return _dao.insertCollection(
      db.AudioCollectionsCompanion(
        title: Value(collection.title),
        coverPath: Value(collection.coverPath),
        description: Value(collection.description),
      ),
    );
  }

  @override
  Future<void> updateCollection(AudioCollection collection) async {
    await _dao.updateCollection(
      db.AudioCollectionsCompanion(
        id: Value(collection.id),
        title: Value(collection.title),
        coverPath: Value(collection.coverPath),
        description: Value(collection.description),
      ),
    );
  }

  @override
  Future<void> deleteCollection(int id) async {
    await _dao.deleteCollection(id);
  }

  @override
  Future<List<String>> getAllCollectionTitles() async {
    return _dao.getAllCollectionTitles();
  }

  @override
  Future<Set<int>> getCollectionIdsContainingAllEntries(
    List<int> entryIds,
  ) async {
    if (entryIds.isEmpty) return {};
    // For a single entry, just get its collection IDs
    if (entryIds.length == 1) {
      return _dao.getCollectionIdsForEntry(entryIds.first);
    }
    // For multiple entries, find collections that contain ALL entries
    final allCids = await _dao.getCollectionIdsForEntries(entryIds);
    final result = <int>{};
    for (final cid in allCids) {
      final entries = await _dao.getEntriesForCollection(cid);
      final entryIdSet = entries.map((e) => e.id).toSet();
      if (entryIds.every(entryIdSet.contains)) {
        result.add(cid);
      }
    }
    return result;
  }

  // ── CrossRef ──────────────────────────────────────────────────────────

  @override
  Future<void> addEntryToCollection(int entryId, int collectionId) {
    return _dao.addEntryToCollection(entryId, collectionId);
  }

  @override
  Future<void> addEntriesToCollection(List<int> entryIds, int collectionId) {
    return _dao.addEntriesToCollection(entryIds, collectionId);
  }

  @override
  Future<void> removeEntryFromCollection(int entryId, int collectionId) async {
    await _dao.removeEntryFromCollection(entryId, collectionId);
  }

  @override
  Future<List<AudioEntry>> getEntriesForCollection(int collectionId) async {
    final rows = await _dao.getEntriesForCollection(collectionId);
    return rows.map(_mapEntry).toList();
  }

  @override
  Stream<List<AudioEntry>> watchEntriesForCollection(int collectionId) {
    return _dao
        .watchEntriesForCollection(collectionId)
        .map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Future<void> reorderEntriesInCollection(
    int collectionId,
    List<int> entryIds,
  ) {
    return _dao.reorderEntriesInCollection(collectionId, entryIds);
  }

  // ── Subtitles ─────────────────────────────────────────────────────────

  @override
  Future<List<SubtitleRef>> getSubtitlesForEntry(int entryId) async {
    final rows = await _dao.getSubtitlesForEntry(entryId);
    return rows.map(_mapSubtitle).toList();
  }

  @override
  Future<int> insertSubtitle(SubtitleRef subtitle) {
    return _dao.insertSubtitle(
      db.SubtitlesCompanion(
        entryId: Value(subtitle.entryId),
        language: Value(subtitle.language),
        filePath: Value(subtitle.filePath),
        format: Value(subtitle.format.name),
      ),
    );
  }

  @override
  Future<void> deleteSubtitlesForEntry(int entryId) async {
    await _dao.deleteSubtitlesForEntry(entryId);
  }

  // ── SignalFiles ───────────────────────────────────────────────────────

  @override
  Future<String?> getSignalFilePathForEntry(int entryId) async {
    final row = await _dao.getSignalFileForEntry(entryId);
    return row?.filePath;
  }

  @override
  Future<void> insertSignalFile(int entryId, String filePath) async {
    await _dao.insertSignalFile(
      db.SignalFilesCompanion(
        entryId: Value(entryId),
        filePath: Value(filePath),
      ),
    );
  }

  @override
  Future<void> deleteSignalFilesForEntry(int entryId) async {
    await _dao.deleteSignalFilesForEntry(entryId);
  }

  // ── ScriptFiles ───────────────────────────────────────────────────────

  @override
  Future<String?> getScriptFilePathForEntry(int entryId) async {
    final row = await _dao.getScriptFileForEntry(entryId);
    return row?.filePath;
  }

  @override
  Future<void> insertScriptFile(int entryId, String filePath) async {
    await _dao.insertScriptFile(
      db.ScriptFilesCompanion(
        entryId: Value(entryId),
        filePath: Value(filePath),
      ),
    );
  }

  @override
  Future<void> deleteScriptFilesForEntry(int entryId) async {
    await _dao.deleteScriptFilesForEntry(entryId);
  }
}
