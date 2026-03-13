import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/waveform.dart';
import '../../domain/repositories/controller_repository.dart';
import '../../data/controller_repository_impl.dart';
import '../../../../core/database/app_database.dart' hide Waveform;

part 'controller_providers.g.dart';

@riverpod
ControllerRepository controllerRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ControllerRepositoryImpl(db.controllerDao);
}

@riverpod
Future<List<Waveform>> waveforms(Ref ref) async {
  return ref.watch(controllerRepositoryProvider).getAllWaveforms();
}
