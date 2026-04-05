import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final void Function()? onForceLogout;

  /// Whether a force-logout has already been triggered this session,
  /// to avoid firing multiple times from concurrent requests.
  bool _logoutTriggered = false;

  AuthInterceptor(this._tokenStorage, {this.onForceLogout});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['satoken'] = token;
      options.headers['Cookie'] = 'satoken=$token';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isAuthRelatedRequest(response.requestOptions)) {
      handler.next(response);
      return;
    }
    // Check for server-side forced logout in response body.
    // The server may return HTTP 200 but with a business code indicating
    // the session was invalidated (e.g. logged in on another device).
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code == 401 || code == 1020) {
        _triggerForceLogout();
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 &&
        !_isAuthRelatedRequest(err.requestOptions)) {
      _tokenStorage.clearToken();
      _triggerForceLogout();
    }
    handler.next(err);
  }

  /// Returns true if the request is an auth-related call that should not
  /// trigger a force-logout. This prevents loops where logout/deactivate
  /// calls or pre-deactivation checks cause the interceptor to force a
  /// second logout.
  bool _isAuthRelatedRequest(RequestOptions options) {
    final path = options.path;
    return path.contains('/auth/');
  }

  void _triggerForceLogout() {
    if (_logoutTriggered) return;
    _logoutTriggered = true;
    _tokenStorage.clearToken();
    onForceLogout?.call();
  }
}
