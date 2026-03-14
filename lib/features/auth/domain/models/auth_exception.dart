/// 认证相关异常类型
enum AuthErrorCode {
  accountNotRegistered,
  accountAlreadyRegistered,
  invalidPhone,
  invalidCode,
  invalidPassword,
  passwordMismatch,
  accountLocked,
  tooManyRequests,
  needsPasswordSetup,
  networkError,
  unknown,
}

class AuthException implements Exception {
  final AuthErrorCode code;
  final String message;
  final int? retryAfterSeconds;
  final int? errorCount;

  const AuthException({
    required this.code,
    required this.message,
    this.retryAfterSeconds,
    this.errorCount,
  });

  factory AuthException.fromServerError(Map<String, dynamic> json) {
    final code = json['code'] as String?;
    final msg = json['message'] as String? ?? '未知错误';
    final retryAfter = json['retry_after'] as int?;
    final errorCount = json['error_count'] as int?;

    return AuthException(
      code: _parseCode(code),
      message: msg,
      retryAfterSeconds: retryAfter,
      errorCount: errorCount,
    );
  }

  static AuthErrorCode _parseCode(String? code) {
    return switch (code) {
      'ACCOUNT_NOT_REGISTERED' => AuthErrorCode.accountNotRegistered,
      'ACCOUNT_ALREADY_REGISTERED' => AuthErrorCode.accountAlreadyRegistered,
      'INVALID_PHONE' => AuthErrorCode.invalidPhone,
      'INVALID_CODE' => AuthErrorCode.invalidCode,
      'INVALID_PASSWORD' => AuthErrorCode.invalidPassword,
      'PASSWORD_MISMATCH' => AuthErrorCode.passwordMismatch,
      'ACCOUNT_LOCKED' => AuthErrorCode.accountLocked,
      'TOO_MANY_REQUESTS' => AuthErrorCode.tooManyRequests,
      'NEEDS_PASSWORD_SETUP' => AuthErrorCode.needsPasswordSetup,
      _ => AuthErrorCode.unknown,
    };
  }

  String get displayMessage {
    return switch (code) {
      AuthErrorCode.accountNotRegistered => '账号未注册',
      AuthErrorCode.accountAlreadyRegistered => '该手机号已注册',
      AuthErrorCode.invalidPhone => '手机号格式不正确',
      AuthErrorCode.invalidCode => errorCount != null
          ? '验证码错误，错误${errorCount}次，5次以上将锁定账号'
          : '验证码错误',
      AuthErrorCode.invalidPassword => errorCount != null
          ? '密码错误，错误${errorCount}次，5次以上将锁定账号'
          : '密码错误',
      AuthErrorCode.passwordMismatch => '两次密码不一致',
      AuthErrorCode.accountLocked => retryAfterSeconds != null
          ? '账号已被锁定，请${(retryAfterSeconds! / 60).ceil()}分钟后重试'
          : '账号已被锁定，请稍后重试',
      AuthErrorCode.tooManyRequests => '请求过于频繁，请稍后重试',
      AuthErrorCode.needsPasswordSetup => '请先设置密码',
      AuthErrorCode.networkError => '网络连接失败，请检查网络',
      AuthErrorCode.unknown => message,
    };
  }

  @override
  String toString() => 'AuthException($code): $message';
}
