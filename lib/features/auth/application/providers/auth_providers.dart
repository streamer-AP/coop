import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/models/auth_exception.dart';
import '../../domain/models/user.dart';
import '../../domain/models/verification_result.dart';
import '../../domain/models/verification_status.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(apiClientProvider),
    TokenStorage(),
  );
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
    state = AsyncData(user);
  }

  Future<void> loginWithCode({
    required String phone,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .loginWithCode(phone: phone, code: code),
    );
  }

  Future<void> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .loginWithPassword(phone: phone, password: password),
    );
  }

  Future<void> register({
    required String phone,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .register(phone: phone, code: code),
    );
  }

  Future<void> setupPassword(String password) async {
    await ref.read(authRepositoryProvider).setupPassword(password: password);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(needsPasswordSetup: false));
    }
  }

  Future<void> logout() async {
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

  Future<void> sendVerificationCode(String phone) async {
    await ref.read(authRepositoryProvider).sendVerificationCode(phone);
  }

  /// 提取 AuthException 的展示信息
  String? get errorMessage {
    final error = state.error;
    if (error is AuthException) return error.displayMessage;
    if (error != null) return '操作失败，请重试';
    return null;
  }
}
