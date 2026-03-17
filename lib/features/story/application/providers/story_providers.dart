import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../domain/models/story_progress.dart';
import '../../domain/models/story_checkpoint.dart';
import '../../domain/repositories/story_repository.dart';
import '../../data/story_repository_impl.dart';
import '../../../../core/database/app_database.dart' hide StoryCheckpoint;
import '../../../../core/platform/native_bridge.dart';
import '../../../../core/platform/page_switcher.dart';
import '../../../../core/platform/unity_bridge.dart';
import '../services/story_bridge_service.dart';

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
  return ref.watch(storyRepositoryProvider).getProgress(characterId, storyId);
}

@riverpod
Future<List<StoryCheckpoint>> storyCheckpoints(
  Ref ref, {
  required String storyId,
}) async {
  return ref.watch(storyRepositoryProvider).getCheckpoints(storyId);
}

@Riverpod(keepAlive: true)
StoryBridgeService storyBridgeService(Ref ref) {
  final unityBridge = ref.watch(unityBridgeProvider);
  final storyRepository = ref.watch(storyRepositoryProvider);
  final signalArbitrator = ref.watch(bleSignalArbitratorProvider);
  final nativeBridge = NativeBridge();
  final pageSwitcher = PageSwitcher(nativeBridge);

  final service = StoryBridgeService(
    unityMessages: unityBridge.messages,
    sendToUnity: unityBridge.sendToUnity,
    showUnity: pageSwitcher.showUnity,
    showFlutter: pageSwitcher.showFlutter,
    initUnityEngine: nativeBridge.initUnityEngine,
    storyRepository: storyRepository,
    signalArbitrator: signalArbitrator,
    invalidateStoryProgress:
        (characterId, storyId) => ref.invalidate(
          storyProgressProvider(characterId: characterId, storyId: storyId),
        ),
    invalidateStoryCheckpoints:
        (storyId) => ref.invalidate(storyCheckpointsProvider(storyId: storyId)),
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
