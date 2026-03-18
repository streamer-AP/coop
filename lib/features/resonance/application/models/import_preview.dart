import 'package:path/path.dart' as p;

enum ImportSourceType { files, zip }

enum ImportPreviewItemType {
  audio,
  video,
  subtitle,
  cover,
  script,
  signal,
  unsupported,
}

class ImportPreviewItem {
  const ImportPreviewItem({
    required this.path,
    required this.name,
    required this.type,
    required this.selected,
    required this.selectable,
  });

  final String path;
  final String name;
  final ImportPreviewItemType type;
  final bool selected;
  final bool selectable;

  bool get isMedia =>
      type == ImportPreviewItemType.audio ||
      type == ImportPreviewItemType.video;

  String get basename => p.basename(path);

  ImportPreviewItem copyWith({
    String? path,
    String? name,
    ImportPreviewItemType? type,
    bool? selected,
    bool? selectable,
  }) {
    return ImportPreviewItem(
      path: path ?? this.path,
      name: name ?? this.name,
      type: type ?? this.type,
      selected: selected ?? this.selected,
      selectable: selectable ?? this.selectable,
    );
  }
}

class ImportPreview {
  const ImportPreview({
    required this.sourceType,
    required this.items,
    this.archivePath,
    this.extractedDir,
  });

  final ImportSourceType sourceType;
  final List<ImportPreviewItem> items;
  final String? archivePath;
  final String? extractedDir;

  List<ImportPreviewItem> get selectedItems =>
      items.where((item) => item.selected && item.selectable).toList();

  List<ImportPreviewItem> get selectedMediaItems =>
      selectedItems.where((item) => item.isMedia).toList();

  List<String> get selectedPaths =>
      selectedItems.map((item) => item.path).toList(growable: false);

  int get selectedCount => selectedItems.length;

  int get selectedMediaCount => selectedMediaItems.length;

  int get totalSelectableCount => items.where((item) => item.selectable).length;

  bool get hasSelectedMedia => selectedMediaCount > 0;

  ImportPreview copyWith({
    ImportSourceType? sourceType,
    List<ImportPreviewItem>? items,
    String? archivePath,
    String? extractedDir,
  }) {
    return ImportPreview(
      sourceType: sourceType ?? this.sourceType,
      items: items ?? this.items,
      archivePath: archivePath ?? this.archivePath,
      extractedDir: extractedDir ?? this.extractedDir,
    );
  }
}
