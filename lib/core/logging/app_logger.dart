import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // number of method calls to be displayed
      lineLength: 80, // width of the output
      dateTimeFormat: DateTimeFormat.dateAndTime, // Show date and time
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error is StackTrace && stackTrace == null) {
      _logger.d(message, stackTrace: error);
    } else {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error is StackTrace && stackTrace == null) {
      _logger.i(message, stackTrace: error);
    } else {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error is StackTrace && stackTrace == null) {
      _logger.w(message, stackTrace: error);
    } else {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error is StackTrace && stackTrace == null) {
      _logger.e(message, stackTrace: error);
    } else {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
}
