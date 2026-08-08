import 'package:dio/dio.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';

/// Interceptor to automatically retry failed network requests.
class RetryInterceptor extends Interceptor {
  /// Constructor taking dio instance and maxRetries configuration.
  RetryInterceptor({
    required this.dio,
    this.maxRetries = ApiConstants.maxRetries,
  });

  /// Dio instance used to retry requests.
  final Dio dio;

  /// Maximum retry attempts.
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retry_count'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      extra['retry_count'] = retryCount + 1;
      try {
        final options = err.requestOptions;
        final response = await dio.request<dynamic>(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: Options(
            method: options.method,
            headers: options.headers,
            extra: extra,
          ),
        );
        return handler.resolve(response);
      } on Object catch (_) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
