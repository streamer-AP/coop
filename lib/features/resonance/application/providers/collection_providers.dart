import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../services/collection_service.dart';
import 'resonance_providers.dart';

part 'collection_providers.g.dart';

@riverpod
CollectionService collectionService(Ref ref) {
  final repo = ref.watch(resonanceRepositoryProvider);
  return CollectionService(repo);
}

@riverpod
Future<List<AudioCollection>> collections(Ref ref) async {
  // 监听 collections stream 获取变化通知，但用 getAllCollections 获取带 count 的数据
  ref.watch(watchCollectionsProvider);
  return ref.watch(collectionServiceProvider).getAllCollections();
}

@riverpod
Stream<List<AudioEntry>> collectionEntries(Ref ref, int collectionId) {
  return ref
      .watch(collectionServiceProvider)
      .watchEntriesForCollection(collectionId);
}
