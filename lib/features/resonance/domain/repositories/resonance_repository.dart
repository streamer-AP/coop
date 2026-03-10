import '../models/audio_entry.dart';
import '../models/audio_collection.dart';

abstract class ResonanceRepository {
  Future<List<AudioEntry>> getAllEntries();
  Future<AudioEntry?> getEntry(int id);
  Future<int> insertEntry(AudioEntry entry);
  Future<void> deleteEntry(int id);
  Future<List<AudioCollection>> getAllCollections();
  Future<AudioCollection?> getCollection(int id);
  Future<int> createCollection(AudioCollection collection);
}
