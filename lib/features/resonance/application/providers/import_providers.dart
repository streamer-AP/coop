import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/file_manager.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/models/import_result.dart';
import '../../domain/models/subtitle.dart';
import '../services/import_service.dart';
import 'resonance_providers.dart';

part 'import_providers.g.dart';

@riverpod
Future<ImportService> importService(Ref ref) async {
  final fileManager = FileManager();
  final importDir = await fileManager.getImportDirectory();
  return ImportService(importDirectory: importDir);
}

enum ImportStatus { idle, picking, importing, done, error }

@riverpod
class ImportProgressNotifier extends _$ImportProgressNotifier {
  @override
  ({ImportStatus status, ImportResult? result, String? error}) build() {
    return (status: ImportStatus.idle, result: null, error: null);
  }

  Future<void> pickAndImport({String? zipPassword}) async {
    state = (status: ImportStatus.picking, result: null, error: null);

    try {
      final importSvc = await ref.read(importServiceProvider.future);
      final paths = await importSvc.pickFiles();

      if (paths == null || paths.isEmpty) {
        state = (status: ImportStatus.idle, result: null, error: null);
        return;
      }

      state = (status: ImportStatus.importing, result: null, error: null);

      final importResult = await importSvc.importFiles(
        paths,
        zipPassword: zipPassword,
      );

      // Persist imported items to database
      await _persistImportedItems(importResult);

      state = (status: ImportStatus.done, result: importResult, error: null);
    } catch (e) {
      state = (status: ImportStatus.error, result: null, error: '$e');
    }
  }

  Future<void> _persistImportedItems(ImportResult result) async {
    final repo = ref.read(resonanceRepositoryProvider);

    for (final item in result.succeeded) {
      final entryId = await repo.insertEntry(AudioEntry(
        id: 0,
        title: item.title,
        filePath: item.filePath,
        coverPath: item.coverPath,
      ));

      if (item.subtitlePath != null) {
        final ext = item.subtitlePath!.split('.').last.toLowerCase();
        final format = SubtitleFormat.values.where((f) => f.name == ext).firstOrNull ??
            SubtitleFormat.srt;
        await repo.insertSubtitle(SubtitleRef(
          id: 0,
          entryId: entryId,
          language: 'default',
          filePath: item.subtitlePath!,
          format: format,
        ));
      }

      if (item.signalPath != null) {
        await repo.insertSignalFile(entryId, item.signalPath!);
      }
    }
  }

  void reset() {
    state = (status: ImportStatus.idle, result: null, error: null);
  }
}
