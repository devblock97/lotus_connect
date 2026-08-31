import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';

/// Interceptor to log outgoing requests, responses, and errors.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.debug('--> ${options.method} ${options.uri}');
      AppLogger.debug('Headers: ${options.headers}');
      if (options.data != null) {
        AppLogger.debug('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      AppLogger.debug(
        '<-- ${response.statusCode} ${response.requestOptions.uri}',
      );
      if (response.data != null) {
        AppLogger.debug('Response: ${response.data}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final errorDetail = err.response?.data ?? err.message;
      AppLogger.error(
        '<-- ERROR '
        '${err.response?.statusCode} '
        '${err.requestOptions.uri}: $errorDetail',
      );
    }
    handler.next(err);
  }
}
