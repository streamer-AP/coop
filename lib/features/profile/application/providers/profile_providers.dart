import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/user_storage_service.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../data/profile_repository_impl.dart';
import '../../domain/models/app_version.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final userStorage = ref.watch(userStorageNotifierProvider).requireValue;
  return ProfileRepositoryImpl(
    ref.watch(apiClientProvider),
    avatarDirectory: userStorage.avatarDirectory,
  );
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<Profile> build() async {
    ref.watch(authNotifierProvider.select((value) => value.valueOrNull?.id));
    return ref.watch(profileRepositoryProvider).getProfile();
  }

  Future<void> updateNickname(String nickname) async {
    final value = nickname.trim();
    final previous = state;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        current.copyWith(nickname: value.isEmpty ? null : value),
      );
    }
    try {
      await ref.read(profileRepositoryProvider).updateNickname(value);
      ref.read(authNotifierProvider.notifier).updateNicknameLocally(value);
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
      // Re-read profile to get the resolved local avatar path
      final refreshed = await repository.getProfile();
      final resolvedAvatar =
          (refreshed.avatarUrl?.trim().isNotEmpty ?? false)
              ? refreshed.avatarUrl
              : current?.avatarUrl ?? avatarUrl;

      final nextProfile =
          current != null && refreshed.userId.trim().isEmpty
              ? current.copyWith(
                avatarUrl: resolvedAvatar,
                isVerified: refreshed.isVerified || current.isVerified,
              )
              : refreshed.copyWith(avatarUrl: resolvedAvatar);

      state = AsyncData(nextProfile);
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
