import '../models/audio_entry.dart';
import '../models/audio_collection.dart';
import '../models/subtitle.dart';

abstract class ResonanceRepository {
  // ── AudioEntries ──────────────────────────────────────────────────────

  Future<List<AudioEntry>> getAllEntries();
  Future<List<String>> getAllEntryTitles();
  Stream<List<AudioEntry>> watchAllEntries();
  Future<AudioEntry?> getEntry(int id);
  Future<int> insertEntry(AudioEntry entry);
  Future<void> insertEntries(List<AudioEntry> entries);
  Future<void> updateEntry(AudioEntry entry);
  Future<void> deleteEntry(int id);

  /// Delete entry and all associated data (subtitles, signals, scripts, cross-refs).
  Future<void> deleteEntryCompletely(int id);
  Future<void> deleteEntriesCompletely(List<int> ids);
  Future<void> deleteEntries(List<int> ids);

  // ── AudioCollections ──────────────────────────────────────────────────

  Future<List<AudioCollection>> getAllCollections();
  Stream<List<AudioCollection>> watchCollections();
  Future<AudioCollection?> getCollection(int id);
  Future<int> createCollection(AudioCollection collection);
  Future<void> updateCollection(AudioCollection collection);
  Future<void> deleteCollection(int id);

  // ── Collection titles ───────────────────────────────────────────────

  Future<List<String>> getAllCollectionTitles();

  /// Get collection IDs that already contain all the given entries.
  Future<Set<int>> getCollectionIdsContainingAllEntries(List<int> entryIds);

  // ── CrossRef (Entry ↔ Collection) ─────────────────────────────────────

  Future<void> addEntryToCollection(int entryId, int collectionId);
  Future<void> addEntriesToCollection(List<int> entryIds, int collectionId);
  Future<void> removeEntryFromCollection(int entryId, int collectionId);
  Future<List<AudioEntry>> getEntriesForCollection(int collectionId);
  Stream<List<AudioEntry>> watchEntriesForCollection(int collectionId);
  Future<void> reorderEntriesInCollection(int collectionId, List<int> entryIds);

  // ── Subtitles ─────────────────────────────────────────────────────────

  Future<List<SubtitleRef>> getSubtitlesForEntry(int entryId);
  Future<int> insertSubtitle(SubtitleRef subtitle);
  Future<void> deleteSubtitlesForEntry(int entryId);
  Future<void> deleteSubtitlesForEntryLanguage(int entryId, String language);

  // ── SignalFiles ───────────────────────────────────────────────────────

  Future<String?> getSignalFilePathForEntry(int entryId);
  Future<void> insertSignalFile(int entryId, String filePath);
  Future<void> deleteSignalFilesForEntry(int entryId);

  // ── ScriptFiles ───────────────────────────────────────────────────────

  Future<String?> getScriptFilePathForEntry(int entryId);
  Future<void> insertScriptFile(int entryId, String filePath);
  Future<void> deleteScriptFilesForEntry(int entryId);
}
