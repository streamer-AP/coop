import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'profile_providers.dart';

part 'account_providers.g.dart';

@riverpod
class ChangePasswordNotifier extends _$ChangePasswordNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
          );
    });
    return !state.hasError;
  }

  Future<bool> changePasswordByCode({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).changePasswordByCode(
            phone: phone,
            code: code,
            newPassword: newPassword,
          );
    });
    return !state.hasError;
  }
}

@riverpod
class ChangePhoneNotifier extends _$ChangePhoneNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> changePhone({
    required String oldPhone,
    required String oldCode,
    required String newPhone,
    required String newCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).changePhone(
            oldPhone: oldPhone,
            oldCode: oldCode,
            newPhone: newPhone,
            newCode: newCode,
          );
    });
    return !state.hasError;
  }
}

@riverpod
class DeactivateAccountNotifier extends _$DeactivateAccountNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> deactivate({
    required String phone,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).deactivateAccount(
            phone: phone,
            code: code,
          );
    });
    return !state.hasError;
  }
}
