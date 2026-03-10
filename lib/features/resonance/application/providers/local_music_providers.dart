import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/local_music_scanner_service.dart';
import '../../domain/models/audio_entry.dart';

part 'local_music_providers.g.dart';

@riverpod
LocalMusicScannerService localMusicScanner(LocalMusicScannerRef ref) {
  return LocalMusicScannerService();
}

@riverpod
class LocalMusicList extends _$LocalMusicList {
  @override
  Future<List<AudioEntry>> build() async {
    return [];
  }

  Future<void> scan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final scanner = ref.read(localMusicScannerProvider);
      return await scanner.scanLocalMusic();
    });
  }

  Future<void> refresh() async {
    await scan();
  }
}

@riverpod
class PermissionStatus extends _$PermissionStatus {
  @override
  Future<bool> build() async {
    final scanner = ref.read(localMusicScannerProvider);
    return await scanner.requestPermissions();
  }

  Future<void> request() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final scanner = ref.read(localMusicScannerProvider);
      return await scanner.requestPermissions();
    });
  }
}
