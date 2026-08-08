import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';

/// Interceptor to automatically refresh access tokens
/// using Refresh Token Rotation (RTR) on 401.
class TokenRefreshInterceptor extends Interceptor {
  /// Constructor.
  TokenRefreshInterceptor({
    required this.getRefreshToken,
    required this.onTokensRefreshed,
    required this.onRefreshFailed,
  });

  /// Getter to retrieve current refresh token.
  final String Function() getRefreshToken;

  /// Callback called when tokens are successfully rotated.
  final Future<void> Function(String accessToken, String refreshToken)
      onTokensRefreshed;

  /// Callback called when token refresh fails (requiring logout/re-authentication).
  final VoidCallback onRefreshFailed;

  bool _isRefreshing = false;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if error is 401 and not related to auth endpoints themselves
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/')) {
      final refreshToken = getRefreshToken();
      if (refreshToken.isEmpty) {
        onRefreshFailed();
        return super.onError(err, handler);
      }

      if (_isRefreshing) {
        // Prevent concurrent refresh storms.
        return super.onError(err, handler);
      }

      _isRefreshing = true;

      try {
        final dio = Dio(
          BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        );

        var baseUrl = err.requestOptions.path;
        if (baseUrl.contains('/api/v1')) {
          baseUrl = baseUrl.substring(0, baseUrl.indexOf('/api/v1') + 7);
        } else if (err.requestOptions.baseUrl.isNotEmpty) {
          baseUrl = err.requestOptions.baseUrl;
        }
        if (baseUrl.endsWith('/')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 1);
        }

        final response = await dio.post(
          '$baseUrl/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final newAccessToken = data['accessToken'] as String;
          final newRefreshToken = data['refreshToken'] as String;

          // Save new tokens
          await onTokensRefreshed(newAccessToken, newRefreshToken);

          // Clone and retry original request
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          final cloneDio = Dio(
            BaseOptions(
              baseUrl: options.baseUrl,
              headers: options.headers,
              connectTimeout: options.connectTimeout,
              receiveTimeout: options.receiveTimeout,
            ),
          );

          final retryResponse = await cloneDio.request(
            options.path,
            data: options.data,
            queryParameters: options.queryParameters,
            options: Options(method: options.method),
          );

          return handler.resolve(retryResponse);
        }
      } on Object catch (e) {
        AppLogger.error('Token Refresh Rotation failed: $e');
        onRefreshFailed();
      } finally {
        _isRefreshing = false;
      }
    }
    super.onError(err, handler);
  }
}
