import 'dart:developer';

class AppLogger {
  static void info(String message) {
    log(message, name: 'INFO');
  }

  static void debug(String message) {
    log(message, name: 'DEBUG');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }
}
