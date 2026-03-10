import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_result.freezed.dart';

@freezed
class ImportedItem with _$ImportedItem {
  const factory ImportedItem({
    required String title,
    required String filePath,
    String? coverPath,
    String? subtitlePath,
    String? signalPath,
  }) = _ImportedItem;
}

@freezed
class ImportFailure with _$ImportFailure {
  const factory ImportFailure({
    required String fileName,
    required String reason,
  }) = _ImportFailure;
}

@freezed
class ImportResult with _$ImportResult {
  const factory ImportResult({
    @Default([]) List<ImportedItem> succeeded,
    @Default([]) List<ImportFailure> failed,
  }) = _ImportResult;

  const ImportResult._();

  int get totalCount => succeeded.length + failed.length;
  bool get hasFailures => failed.isNotEmpty;
}
