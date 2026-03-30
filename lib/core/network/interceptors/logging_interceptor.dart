import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('''
    ${options.method} ${options.uri}
    query: ${options.queryParameters}
    body: ${_formatRequestData(options.data)}
    headers: ${options.headers}
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

  Object? _formatRequestData(dynamic data) {
    if (data is FormData) {
      return {
        'fields': Map<String, String>.fromEntries(
          data.fields.map((field) => MapEntry(field.key, field.value)),
        ),
        'files': data.files.map((file) => file.key).toList(),
      };
    }
    return data;
  }
}
