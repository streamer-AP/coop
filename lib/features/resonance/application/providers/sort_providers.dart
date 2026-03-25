import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'import_providers.dart';

part 'sort_providers.g.dart';

enum SortMode { alphabeticalAsc, alphabeticalDesc, timeAsc, timeDesc }

@riverpod
class SortModeNotifier extends _$SortModeNotifier {
  @override
  SortMode build() => SortMode.timeDesc;

  void setSortMode(SortMode mode) {
    if (state != mode) {
      ref.read(recentlyImportedEntryIdsProvider.notifier).state = const [];
    }
    state = mode;
  }
}
