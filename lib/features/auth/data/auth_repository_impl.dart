import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../domain/models/user.dart';
import '../domain/models/verification_result.dart';
import '../domain/models/verification_status.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<User> login({required String phone, required String code}) async {
    // TODO(api): replace mock with real API call before release
    assert(() {
      AppLogger().warning('AuthRepositoryImpl.login() using mock data');
      return true;
    }());
    return User(
      id: 'demo',
      phone: phone,
      nickname: '昵称3934',
    );
  }

  @override
  Future<void> register({required String phone, required String code}) async {
    // TODO: implement
  }

  @override
  Future<VerificationResult> verifyIdentity({
    required String name,
    required String idNumber,
  }) async {
    // TODO(api): replace mock with real API call before release
    assert(() {
      AppLogger().warning('AuthRepositoryImpl.verifyIdentity() using mock data');
      return true;
    }());
    return const VerificationResult(
      status: VerificationStatus.verified,
    );
  }

  @override
  Future<void> sendVerificationCode(String phone) async {
    // TODO(api): replace mock with real API call before release
    assert(() {
      AppLogger().warning('AuthRepositoryImpl.sendVerificationCode() is a no-op mock');
      return true;
    }());
  }

  @override
  Future<void> logout() async {
    // TODO: implement
  }

  @override
  Future<User?> getCurrentUser() async {
    // TODO: implement
    return null;
  }
}
