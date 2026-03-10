import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/repositories/resonance_repository.dart';
import '../../data/resonance_repository_impl.dart';
import '../../../../core/database/app_database.dart' hide AudioEntry;

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
