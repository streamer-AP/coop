import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/story_progress.dart';
import '../../domain/repositories/story_repository.dart';
import '../../data/story_repository_impl.dart';
import '../../../../core/database/app_database.dart';

part 'story_providers.g.dart';

@riverpod
StoryRepository storyRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return StoryRepositoryImpl(db.storyDao);
}

@riverpod
Future<StoryProgress?> storyProgress(
  Ref ref, {
  required String characterId,
  required String storyId,
}) async {
  return ref
      .watch(storyRepositoryProvider)
      .getProgress(characterId, storyId);
}
