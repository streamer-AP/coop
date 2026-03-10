import '../../../core/database/daos/resonance_dao.dart';
import '../domain/models/audio_entry.dart';
import '../domain/models/audio_collection.dart';
import '../domain/repositories/resonance_repository.dart';

class ResonanceRepositoryImpl implements ResonanceRepository {
  final ResonanceDao _dao;

  ResonanceRepositoryImpl(this._dao);

  @override
  Future<List<AudioEntry>> getAllEntries() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<AudioEntry?> getEntry(int id) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<int> insertEntry(AudioEntry entry) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEntry(int id) async {
    // TODO: implement
  }

  @override
  Future<List<AudioCollection>> getAllCollections() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<AudioCollection?> getCollection(int id) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<int> createCollection(AudioCollection collection) async {
    // TODO: implement
    throw UnimplementedError();
  }
}
