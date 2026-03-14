import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/auth_exception.dart';
import '../domain/models/user.dart';
import '../domain/models/verification_result.dart';
import '../domain/models/verification_status.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._apiClient, this._tokenStorage);

  @override
  Future<User> loginWithCode({
    required String phone,
    required String code,
  }) async {
    // TODO(api): replace mock with real API call
    _logMock('loginWithCode');
    await Future.delayed(const Duration(milliseconds: 500));

    if (code != '123456' && code != '000000') {
      throw const AuthException(
        code: AuthErrorCode.invalidCode,
        message: '验证码错误',
        errorCount: 1,
      );
    }

    final user = User(
      id: 'demo_${phone.hashCode}',
      phone: phone,
      nickname: '昵称${phone.substring(phone.length - 4)}',
      token: 'mock_token_$phone',
      needsPasswordSetup: false,
    );
    await _tokenStorage.saveToken(user.token!);
    return user;
  }

  @override
  Future<User> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    // TODO(api): replace mock with real API call
    _logMock('loginWithPassword');
    await Future.delayed(const Duration(milliseconds: 500));

    if (password.length < 6) {
      throw const AuthException(
        code: AuthErrorCode.invalidPassword,
        message: '密码错误',
        errorCount: 1,
      );
    }

    final user = User(
      id: 'demo_${phone.hashCode}',
      phone: phone,
      nickname: '昵称${phone.substring(phone.length - 4)}',
      token: 'mock_token_$phone',
    );
    await _tokenStorage.saveToken(user.token!);
    return user;
  }

  @override
  Future<User> register({
    required String phone,
    required String code,
  }) async {
    // TODO(api): replace mock with real API call
    _logMock('register');
    await Future.delayed(const Duration(milliseconds: 500));

    if (code != '123456' && code != '000000') {
      throw const AuthException(
        code: AuthErrorCode.invalidCode,
        message: '验证码错误',
      );
    }

    final user = User(
      id: 'new_${phone.hashCode}',
      phone: phone,
      nickname: '昵称${phone.substring(phone.length - 4)}',
      token: 'mock_token_$phone',
      needsPasswordSetup: true,
    );
    await _tokenStorage.saveToken(user.token!);
    return user;
  }

  @override
  Future<void> setupPassword({required String password}) async {
    // TODO(api): replace mock with real API call
    _logMock('setupPassword');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> sendVerificationCode(String phone) async {
    // TODO(api): replace mock with real API call
    _logMock('sendVerificationCode');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<VerificationResult> verifyIdentity({
    required String name,
    required String idNumber,
  }) async {
    // TODO(api): replace mock with real API call
    _logMock('verifyIdentity');
    await Future.delayed(const Duration(milliseconds: 500));
    return const VerificationResult(
      status: VerificationStatus.verified,
    );
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;

    // TODO(api): validate token with server, return user profile
    _logMock('getCurrentUser (from token)');
    return User(
      id: 'restored',
      phone: '***',
      nickname: '已登录用户',
      token: token,
    );
  }

  @override
  Future<void> saveToken(String token) => _tokenStorage.saveToken(token);

  @override
  Future<void> clearToken() => _tokenStorage.clearToken();

  @override
  Future<String?> getToken() => _tokenStorage.getToken();

  void _logMock(String method) {
    assert(() {
      AppLogger().warning('AuthRepositoryImpl.$method() using mock data');
      return true;
    }());
  }
}
