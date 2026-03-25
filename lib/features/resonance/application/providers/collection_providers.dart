import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/storage/user_storage_service.dart';
import '../../domain/models/audio_collection.dart';
import '../../domain/models/audio_entry.dart';
import '../services/collection_service.dart';
import 'resonance_providers.dart';

part 'collection_providers.g.dart';

@riverpod
CollectionService collectionService(Ref ref) {
  ref.watch(userStorageEpochProvider);
  final repo = ref.watch(resonanceRepositoryProvider);
  return CollectionService(repo);
}

@riverpod
Future<List<AudioCollection>> collections(Ref ref) async {
  final epoch = ref.watch(userStorageEpochProvider);
  // 监听 collections stream 获取变化通知，但用 getAllCollections 获取带 count 的数据
  ref.watch(watchCollectionsProvider);
  final collections =
      await ref.watch(collectionServiceProvider).getAllCollections();
  AppLogger().info(
    '[Resonance] collections: epoch=$epoch, count=${collections.length}',
  );
  return collections;
}

@riverpod
Stream<List<AudioEntry>> collectionEntries(Ref ref, int collectionId) {
  final epoch = ref.watch(userStorageEpochProvider);
  return ref
      .watch(collectionServiceProvider)
      .watchEntriesForCollection(collectionId)
      .map((entries) {
        AppLogger().info(
          '[Resonance] collectionEntries: epoch=$epoch, collectionId=$collectionId, count=${entries.length}',
        );
        return entries;
      });
}
