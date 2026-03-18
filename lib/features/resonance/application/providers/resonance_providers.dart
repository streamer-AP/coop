import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart'
    hide AudioEntry, AudioCollection, Subtitle, SignalFile;
import '../../data/resonance_repository_impl.dart';
import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/repositories/resonance_repository.dart';

part 'resonance_providers.g.dart';

@riverpod
ResonanceRepository resonanceRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ResonanceRepositoryImpl(db.resonanceDao);
}

@riverpod
Future<List<AudioEntry>> audioEntries(Ref ref) async {
  return ref.watch(resonanceRepositoryProvider).getAllEntries();
}

@riverpod
Stream<List<AudioEntry>> watchEntries(Ref ref) {
  return ref.watch(resonanceRepositoryProvider).watchAllEntries();
}

@riverpod
Stream<List<AudioCollection>> watchCollections(Ref ref) {
  return ref.watch(resonanceRepositoryProvider).watchCollections();
}
