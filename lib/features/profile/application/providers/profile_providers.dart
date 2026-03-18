import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/profile_repository_impl.dart';
import '../../domain/models/app_version.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(ref.watch(apiClientProvider));
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<Profile> build() async {
    return ref.watch(profileRepositoryProvider).getProfile();
  }

  Future<void> updateNickname(String nickname) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(nickname: nickname));
    }
    try {
      await ref.read(profileRepositoryProvider).updateNickname(nickname);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(avatarUrl: avatarUrl));
    }
    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.updateAvatar(avatarUrl);
      final refreshed = await repository.getProfile();
      final resolvedAvatar =
          (refreshed.avatarUrl?.trim().isNotEmpty ?? false)
              ? refreshed.avatarUrl
              : avatarUrl;
      state = AsyncData(refreshed.copyWith(avatarUrl: resolvedAvatar));
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

@riverpod
Future<AppVersion> appVersion(Ref ref) async {
  return ref.watch(profileRepositoryProvider).checkForUpdate();
}
