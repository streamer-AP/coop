import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/file_manager.dart';
import '../models/import_preview.dart';
import '../../domain/models/audio_entry.dart';
import '../../domain/models/import_result.dart';
import '../../domain/models/subtitle.dart';
import '../services/import_service.dart';
import 'resonance_providers.dart';

part 'import_providers.g.dart';

final recentlyImportedEntryIdsProvider = StateProvider<List<int>>(
  (ref) => const [],
);

@riverpod
Future<ImportService> importService(Ref ref) async {
  final fileManager = ref.read(fileManagerProvider);
  final importDir = fileManager.getImportDirectory();
  return ImportService(importDirectory: importDir);
}

enum ImportStatus { idle, picking, preview, importing, done, error }

class ImportState {
  const ImportState({
    required this.status,
    this.preview,
    this.result,
    this.error,
    this.current = 0,
    this.total = 0,
  });

  final ImportStatus status;
  final ImportPreview? preview;
  final ImportResult? result;
  final String? error;
  final int current;
  final int total;

  ImportState copyWith({
    ImportStatus? status,
    ImportPreview? preview,
    bool clearPreview = false,
    ImportResult? result,
    bool clearResult = false,
    String? error,
    bool clearError = false,
    int? current,
    int? total,
  }) {
    return ImportState(
      status: status ?? this.status,
      preview: clearPreview ? null : (preview ?? this.preview),
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      current: current ?? this.current,
      total: total ?? this.total,
    );
  }
}

ImportState _importState({
  required ImportStatus status,
  ImportPreview? preview,
  ImportResult? result,
  String? error,
  int current = 0,
  int total = 0,
}) => ImportState(
  status: status,
  preview: preview,
  result: result,
  error: error,
  current: current,
  total: total,
);

@riverpod
class ImportProgressNotifier extends _$ImportProgressNotifier {
  @override
  ImportState build() {
    ref.onDispose(() {
      final preview = state.preview;
      if (preview != null) {
        unawaited(_cleanupPreview(preview));
      }
    });
    return _importState(status: ImportStatus.idle);
  }

  Future<void> pickFilesForPreview() async {
    final previousPreview = state.preview;
    state = _importState(status: ImportStatus.picking);

    try {
      final importSvc = await ref.read(importServiceProvider.future);
      await _cleanupPreview(previousPreview);
      final paths = await importSvc.pickFiles();

      if (paths == null || paths.isEmpty) {
        state = _importState(status: ImportStatus.idle);
        return;
      }

      final preview = await importSvc.prepareFilesPreview(paths);
      state = _importState(status: ImportStatus.preview, preview: preview);
    } catch (e) {
      state = _importState(status: ImportStatus.error, error: '$e');
    }
  }

  Future<void> pickZipForPreview({String? zipPassword}) async {
    final previousPreview = state.preview;
    state = _importState(status: ImportStatus.picking);

    try {
      final importSvc = await ref.read(importServiceProvider.future);
      await _cleanupPreview(previousPreview);
      final zipPath = await importSvc.pickZipFile();

      if (zipPath == null) {
        state = _importState(status: ImportStatus.idle);
        return;
      }

      final preview = await importSvc.prepareZipPreview(
        zipPath,
        password: zipPassword,
      );
      state = _importState(status: ImportStatus.preview, preview: preview);
    } catch (e) {
      state = _importState(status: ImportStatus.error, error: '$e');
    }
  }

  void togglePreviewSelection(String path) {
    final preview = state.preview;
    if (preview == null) return;

    final updatedItems = preview.items
        .map((item) {
          if (item.path != path || !item.selectable) {
            return item;
          }
          return item.copyWith(selected: !item.selected);
        })
        .toList(growable: false);

    state = _importState(
      status: ImportStatus.preview,
      preview: preview.copyWith(items: updatedItems),
      result: state.result,
      error: state.error,
    );
  }

  Future<void> importSelected() async {
    final preview = state.preview;
    if (preview == null) {
      state = _importState(status: ImportStatus.error, error: '没有可导入的预览内容');
      return;
    }

    state = _importState(
      status: ImportStatus.importing,
      preview: preview,
      current: 0,
      total: preview.selectedMediaCount,
    );

    try {
      final importSvc = await ref.read(importServiceProvider.future);
      final repo = ref.read(resonanceRepositoryProvider);
      final existingTitles = await repo.getAllEntryTitles();

      final importResult = await importSvc.importPreview(
        preview,
        existingTitles: existingTitles,
        onProgress: (current, total) {
          state = _importState(
            status: ImportStatus.importing,
            preview: preview,
            current: current,
            total: total,
          );
        },
      );

      await _persistImportedItems(importResult);
      await _cleanupPreview(preview);

      state = _importState(status: ImportStatus.done, result: importResult);
    } catch (e) {
      state = _importState(
        status: ImportStatus.error,
        preview: preview,
        error: '$e',
      );
    }
  }

  Future<void> pickAndImport({String? zipPassword}) async {
    await pickFilesForPreview();
    if (state.preview != null) {
      await importSelected();
    }
  }

  Future<void> pickZipAndImport({String? zipPassword}) async {
    await pickZipForPreview(zipPassword: zipPassword);
    if (state.preview != null) {
      await importSelected();
    }
  }

  Future<void> _persistImportedItems(ImportResult result) async {
    final repo = ref.read(resonanceRepositoryProvider);
    final importedEntryIds = <int>[];

    for (final item in result.succeeded) {
      final entryId = await repo.insertEntry(
        AudioEntry(
          id: 0,
          title: item.title,
          filePath: item.filePath,
          coverPath: item.coverPath,
          mediaType: item.mediaType,
          artist: item.artist,
          album: item.album,
          durationMs: item.durationMs,
        ),
      );
      importedEntryIds.add(entryId);

      if (item.subtitlePath != null) {
        final ext = item.subtitlePath!.split('.').last.toLowerCase();
        final format =
            SubtitleFormat.values.where((f) => f.name == ext).firstOrNull ??
            SubtitleFormat.srt;
        await repo.insertSubtitle(
          SubtitleRef(
            id: 0,
            entryId: entryId,
            language: 'default',
            filePath: item.subtitlePath!,
            format: format,
          ),
        );
      }

      if (item.signalPath != null) {
        await repo.insertSignalFile(entryId, item.signalPath!);
      }

      if (item.scriptPath != null) {
        await repo.insertScriptFile(entryId, item.scriptPath!);
      }
    }

    ref.read(recentlyImportedEntryIdsProvider.notifier).state =
        importedEntryIds;
  }

  Future<void> reset() async {
    await _cleanupPreview(state.preview);
    state = _importState(status: ImportStatus.idle);
  }

  Future<void> _cleanupPreview(ImportPreview? preview) async {
    if (preview == null) return;
    final importSvc = await ref.read(importServiceProvider.future);
    await importSvc.cleanupPreview(preview);
  }
}
