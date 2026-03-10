import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/resonance_tables.dart';

part 'resonance_dao.g.dart';

@DriftAccessor(tables: [
  AudioEntries,
  AudioCollections,
  EntryCollectionCrossRef,
  Playlists,
  PlaylistItems,
  Subtitles,
  SignalFiles,
])
class ResonanceDao extends DatabaseAccessor<AppDatabase>
    with _$ResonanceDaoMixin {
  ResonanceDao(super.db);

  // TODO: implement CRUD operations
}
