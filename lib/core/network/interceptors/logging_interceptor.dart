import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('''
    ${options.method} ${options.uri}
    query=${options.queryParameters}
    data=${options.data}
        ''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('''
    ${response.statusCode} ${response.requestOptions.uri}
    ${response.data}
    ''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('''
    ${err.message}
    ${err.requestOptions.method} ${err.requestOptions.uri}
    query=${err.requestOptions.queryParameters}
    data=${err.requestOptions.data}
    status=${err.response?.statusCode}
    response=${err.response?.data}
    ''', error: err);
    handler.next(err);
  }
}
