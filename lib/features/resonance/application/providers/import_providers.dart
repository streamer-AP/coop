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

typedef ImportState = ({
  ImportStatus status,
  ImportResult? result,
  String? error,
  int current,
  int total,
});

ImportState _importState({
  required ImportStatus status,
  ImportResult? result,
  String? error,
  int current = 0,
  int total = 0,
}) =>
    (status: status, result: result, error: error, current: current, total: total);

@riverpod
class ImportProgressNotifier extends _$ImportProgressNotifier {
  @override
  ImportState build() {
    return _importState(status: ImportStatus.idle);
  }

  /// Pick regular files and import.
  Future<void> pickAndImport({String? zipPassword}) async {
    state = _importState(status: ImportStatus.picking);

    try {
      final importSvc = await ref.read(importServiceProvider.future);
      final paths = await importSvc.pickFiles();

      if (paths == null || paths.isEmpty) {
        state = _importState(status: ImportStatus.idle);
        return;
      }

      await _doImport(importSvc, paths, zipPassword: zipPassword);
    } catch (e) {
      state = _importState(status: ImportStatus.error, error: '$e');
    }
  }

  /// Pick a zip archive and import.
  Future<void> pickZipAndImport({String? zipPassword}) async {
    state = _importState(status: ImportStatus.picking);

    try {
      final importSvc = await ref.read(importServiceProvider.future);
      final zipPath = await importSvc.pickZipFile();

      if (zipPath == null) {
        state = _importState(status: ImportStatus.idle);
        return;
      }

      await _doImport(importSvc, [zipPath], zipPassword: zipPassword);
    } catch (e) {
      state = _importState(status: ImportStatus.error, error: '$e');
    }
  }

  Future<void> _doImport(
    ImportService importSvc,
    List<String> paths, {
    String? zipPassword,
  }) async {
    state = _importState(status: ImportStatus.importing);

    // Get existing titles for deduplication (lightweight, titles only)
    final repo = ref.read(resonanceRepositoryProvider);
    final existingTitles = await repo.getAllEntryTitles();

    final importResult = await importSvc.importFiles(
      paths,
      zipPassword: zipPassword,
      existingTitles: existingTitles,
      onProgress: (current, total) {
        state = _importState(
          status: ImportStatus.importing,
          current: current,
          total: total,
        );
      },
    );

    // Persist imported items to database
    await _persistImportedItems(importResult);

    // Cleanup extracted zip temp dirs
    await importSvc.cleanupExtractedDirs();

    state = _importState(status: ImportStatus.done, result: importResult);
  }

  Future<void> _persistImportedItems(ImportResult result) async {
    final repo = ref.read(resonanceRepositoryProvider);

    for (final item in result.succeeded) {
      final entryId = await repo.insertEntry(AudioEntry(
        id: 0,
        title: item.title,
        filePath: item.filePath,
        coverPath: item.coverPath,
        mediaType: item.mediaType,
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
    state = _importState(status: ImportStatus.idle);
  }
}
