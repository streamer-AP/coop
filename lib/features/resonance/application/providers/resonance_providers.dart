import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart'
    hide AudioEntry, AudioCollection, Subtitle, SignalFile;
import '../../../../core/logging/app_logger.dart';
import '../../../../core/storage/user_storage_service.dart';
import '../../data/resonance_repository_impl.dart';
import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/repositories/resonance_repository.dart';

part 'resonance_providers.g.dart';

@riverpod
ResonanceRepository resonanceRepository(Ref ref) {
  ref.watch(userStorageEpochProvider);
  final db = ref.watch(appDatabaseProvider);
  return ResonanceRepositoryImpl(db.resonanceDao);
}

@riverpod
Future<List<AudioEntry>> audioEntries(Ref ref) async {
  final epoch = ref.watch(userStorageEpochProvider);
  ref.watch(watchEntriesProvider);
  final entries = await ref.watch(resonanceRepositoryProvider).getAllEntries();
  AppLogger().info(
    '[Resonance] audioEntries: epoch=$epoch, count=${entries.length}',
  );
  return entries;
}

@riverpod
Stream<List<AudioEntry>> watchEntries(Ref ref) {
  final epoch = ref.watch(userStorageEpochProvider);
  return ref.watch(resonanceRepositoryProvider).watchAllEntries().map((
    entries,
  ) {
    AppLogger().info(
      '[Resonance] watchEntries: epoch=$epoch, count=${entries.length}',
    );
    return entries;
  });
}

@riverpod
Stream<List<AudioCollection>> watchCollections(Ref ref) {
  final epoch = ref.watch(userStorageEpochProvider);
  return ref.watch(resonanceRepositoryProvider).watchCollections().map((
    collections,
  ) {
    AppLogger().info(
      '[Resonance] watchCollections: epoch=$epoch, count=${collections.length}',
    );
    return collections;
  });
}
