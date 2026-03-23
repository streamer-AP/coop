import 'package:dio/dio.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
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
    final json = await _postWithQuery(ApiEndpoints.loginByCode, {
      'mobile': phone,
      'code': code,
    });
    final user = _parseUserResponse(json);
    if (user.token != null) {
      await _tokenStorage.saveToken(user.token!);
    }
    await _persistCurrentUserId(user.id);
    return user;
  }

  @override
  Future<User> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    final json = await _postWithQuery(ApiEndpoints.loginByPassword, {
      'mobile': phone,
      'password': password,
    });
    final user = _parseUserResponse(json);
    if (user.token != null) {
      await _tokenStorage.saveToken(user.token!);
    }
    await _persistCurrentUserId(user.id);
    return user;
  }

  @override
  Future<User> register({
    required String phone,
    required String code,
    String? password,
  }) async {
    final json = await _postWithQuery(ApiEndpoints.register, {
      'mobile': phone,
      'code': code,
      if (password != null) 'password': password,
      if (password != null) 'veryPassword': password,
    });
    final user = _parseUserResponse(
      json,
    ).copyWith(needsPasswordSetup: password == null);
    if (user.token != null) {
      await _tokenStorage.saveToken(user.token!);
    }
    await _persistCurrentUserId(user.id);
    return user;
  }

  @override
  Future<void> setupPassword({required String password}) async {
    await _postWithQuery(ApiEndpoints.setupPassword, {
      'password': password,
      'veryPassword': password,
    });
  }

  @override
  Future<void> sendVerificationCode(
    String phone, {
    bool isRegister = false,
  }) async {
    final endpoint =
        isRegister ? ApiEndpoints.sendRegisterCode : ApiEndpoints.sendLoginCode;
    await _postWithQuery(endpoint, {'mobile': phone});
  }

  @override
  Future<VerificationResult> verifyIdentity({
    required String name,
    required String idNumber,
  }) async {
    final json = await _postWithQuery(ApiEndpoints.realNameVerify, {
      'residentIdCard': idNumber,
      'residentIdCardName': name,
    });

    final code = json['code'] as int?;
    final data = json['data'] as Map<String, dynamic>?;

    if (code == 200 && data != null) {
      final isAdult = data['isAdult'] as bool? ?? false;
      return VerificationResult(
        status:
            isAdult ? VerificationStatus.verified : VerificationStatus.underage,
        message: data['message'] as String?,
      );
    }

    // Error codes from docs
    return switch (code) {
      1007 => const VerificationResult(
        status: VerificationStatus.underage,
        message: '您仍然未成年',
      ),
      1000 => const VerificationResult(
        status: VerificationStatus.verified,
        message: '您实名验证已成功',
      ),
      _ => VerificationResult(
        status: VerificationStatus.failed,
        message: json['message'] as String? ?? '认证失败',
      ),
    };
  }

  @override
  Future<void> logout() async {
    try {
      await _postWithQuery(ApiEndpoints.logout, {});
    } catch (_) {
      // Logout locally even if server call fails
    }
    await _tokenStorage.clearToken();
    await _tokenStorage.clearCurrentUserId();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;

    try {
      final json = await _apiClient.get(ApiEndpoints.getCurrentUserInfo);
      final code = json['code'] as int?;
      if (code == 200 && json['data'] != null) {
        final data = json['data'] as Map<String, dynamic>;
        final residentStatus = data['residentStatus'] as String? ?? '0';
        final user = User(
          id: _extractUserId(data),
          phone: data['mobile'] as String? ?? '',
          nickname: _normalizeOptionalString(data['userName']),
          token: token,
          verificationStatus: switch (residentStatus) {
            '1' => VerificationStatus.verified,
            '2' => VerificationStatus.underage,
            _ => VerificationStatus.unverified,
          },
          isVerified: residentStatus == '1',
        );
        await _persistCurrentUserId(user.id);
        return user;
      }
    } catch (e) {
      AppLogger().warning('getCurrentUser failed: $e');
      // Token might be expired
      if (e is DioException && e.response?.statusCode == 401) {
        await _tokenStorage.clearToken();
        await _tokenStorage.clearCurrentUserId();
        return null;
      }
    }

    // Fallback: return minimal user from token
    return User(
      id: (await _tokenStorage.getCurrentUserId()) ?? '',
      phone: '',
      token: token,
    );
  }

  @override
  Future<void> saveToken(String token) => _tokenStorage.saveToken(token);

  @override
  Future<void> clearToken() => _tokenStorage.clearToken();

  @override
  Future<String?> getToken() => _tokenStorage.getToken();

  // ── Helpers ──

  Future<Map<String, dynamic>> _postWithQuery(
    String path,
    Map<String, dynamic> params,
  ) async {
    try {
      final json = await _apiClient.post(path, queryParameters: params);
      final code = json['code'] as int?;

      if (code == 200 || code == 0) return json;

      // Map server error codes to AuthException
      throw AuthException.fromServerError({
        'code': _mapServerCode(code),
        'message': json['message'] as String? ?? '请求失败',
        'error_count': json['errorCount'],
        'retry_after': json['retryAfter'],
      });
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const AuthException(
          code: AuthErrorCode.networkError,
          message: '网络连接失败',
        );
      }
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw AuthException.fromServerError({
          'code': _mapServerCode(data['code'] as int?),
          'message': data['message'] as String? ?? '请求失败',
        });
      }
      throw AuthException(
        code: AuthErrorCode.unknown,
        message: e.message ?? '请求失败',
      );
    }
  }

  String? _mapServerCode(int? code) {
    return switch (code) {
      1001 => 'ACCOUNT_NOT_REGISTERED',
      1002 => 'INVALID_PHONE',
      1003 => 'INVALID_CODE',
      1004 => 'INVALID_PASSWORD',
      1005 => 'ACCOUNT_ALREADY_REGISTERED',
      1006 => 'INVALID_PHONE',
      1008 => 'ACCOUNT_LOCKED',
      1009 => 'TOO_MANY_REQUESTS',
      1010 => 'PASSWORD_MISMATCH',
      1011 => 'NEEDS_PASSWORD_SETUP',
      _ => null,
    };
  }

  User _parseUserResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final token =
        data['token'] as String? ??
        data['accessToken'] as String? ??
        data['tokenValue'] as String? ??
        data['satoken'] as String?;
    final residentStatus = data['residentStatus'] as String? ?? '0';

    return User(
      id: _extractUserId(data),
      phone: data['mobile'] as String? ?? '',
      nickname: _normalizeOptionalString(data['userName']),
      token: token,
      needsPasswordSetup: data['needsPasswordSetup'] as bool? ?? false,
      verificationStatus: switch (residentStatus) {
        '1' => VerificationStatus.verified,
        '2' => VerificationStatus.underage,
        _ => VerificationStatus.unverified,
      },
      isVerified: residentStatus == '1',
    );
  }

  Future<void> _persistCurrentUserId(String userId) async {
    if (userId.trim().isEmpty) return;
    await _tokenStorage.saveCurrentUserId(userId);
  }

  String _extractUserId(Map<String, dynamic> data) {
    final id = data['id'];
    final userId = data['userId'];
    final loginId = data['loginId'];
    AppLogger().info(
      '[Auth] _extractUserId: id=$id, userId=$userId, loginId=$loginId',
    );
    // userId 是真正的用户标识，id 可能是会话/记录 id
    final raw = userId ?? loginId ?? id;
    if (raw == null) return '';
    return '$raw'.trim();
  }

  String? _normalizeOptionalString(Object? value) {
    final normalized = '$value'.trim();
    if (value == null || normalized.isEmpty || normalized == 'null') {
      return null;
    }
    return normalized;
  }
}
