import 'package:logger/logger.dart';

/// Application-wide logger with remote log shipping.
class AppLogger {
  static final _instance = AppLogger._();
  factory AppLogger() => _instance;
  AppLogger._();

  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warning(String message) => _logger.w(message);
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  Future<void> shipLogs() async {
    // TODO: implement idempotent log shipping to backend
  }
}
