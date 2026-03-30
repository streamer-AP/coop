import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/storage/user_storage_service.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/models/auth_exception.dart';
import '../../domain/models/user.dart';
import '../../domain/models/verification_result.dart';
import '../../domain/models/verification_status.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../resonance/application/providers/player_providers.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider), TokenStorage());
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() {
    _init();
    return const AsyncLoading();
  }

  Future<void> _init() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    // switchUser 已经在 UserStorageNotifier._tryRestoreFromCache() 中
    // 用缓存的 userId 快速完成了。这里只在 userId 不同时才切换。
    if (user != null && user.id.trim().isNotEmpty) {
      await ref
          .read(userStorageNotifierProvider.notifier)
          .switchUser(user.id.trim(), force: true);
    }
    state = AsyncData(user);
  }

  Future<void> loginWithCode({
    required String phone,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .loginWithCode(phone: phone, code: code);
      await _onUserAuthenticated(user);
      return user;
    });
  }

  Future<void> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .loginWithPassword(phone: phone, password: password);
      await _onUserAuthenticated(user);
      return user;
    });
  }

  Future<void> register({
    required String phone,
    required String code,
    String? password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .register(phone: phone, code: code, password: password);
      await _onUserAuthenticated(user);
      return user;
    });
  }

  /// 登录/注册成功后，初始化用户存储空间。
  Future<void> _onUserAuthenticated(User user) async {
    if (user.id.trim().isNotEmpty) {
      await ref
          .read(userStorageNotifierProvider.notifier)
          .switchUser(user.id.trim(), force: true);
    }
  }

  Future<void> setupPassword(String password) async {
    await ref.read(authRepositoryProvider).setupPassword(password: password);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(needsPasswordSetup: false));
    }
  }

  void updateNicknameLocally(String nickname) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(nickname: nickname));
  }

  Future<void> logout({bool purgeLocalData = false}) async {
    // 停止播放器
    ref.read(playerStateNotifierProvider.notifier).clearPlaylist();

    // 清理用户存储；账号注销场景需要连同本地用户目录一起清除。
    await ref
        .read(userStorageNotifierProvider.notifier)
        .clear(deleteCurrentUserData: purgeLocalData);

    // 调用后端登出 + 清除 token
    await ref.read(authRepositoryProvider).logout();

    state = const AsyncData(null);
  }

  Future<VerificationResult> verifyIdentity({
    required String name,
    required String idNumber,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .verifyIdentity(name: name, idNumber: idNumber);

    if (result.status == VerificationStatus.verified) {
      final currentUser = state.valueOrNull;
      if (currentUser != null) {
        state = AsyncData(
          currentUser.copyWith(
            isVerified: true,
            verificationStatus: VerificationStatus.verified,
          ),
        );
      }
    }

    return result;
  }

  Future<void> sendVerificationCode(
    String phone, {
    bool isRegister = false,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .sendVerificationCode(phone, isRegister: isRegister);
  }

  /// 提取 AuthException 的展示信息
  String? get errorMessage {
    final error = state.error;
    if (error is AuthException) return error.displayMessage;
    if (error != null) return '操作失败，请重试';
    return null;
  }
}
