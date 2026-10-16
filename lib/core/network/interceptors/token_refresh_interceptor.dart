import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';

/// Interceptor to automatically refresh access tokens
/// using Refresh Token Rotation (RTR) on 401.
class TokenRefreshInterceptor extends Interceptor {
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

  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = err.requestOptions.path.contains('/auth');

    // Check if error is 401 and not related to auth endpoints themselves
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      if (_refreshCompleter != null) {
        try {
          final newAccessToken = await _refreshCompleter!.future;
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            final retried =
                await _retryRequest(err.requestOptions, newAccessToken);
            return handler.resolve(retried);
          }
        } on Object {
          return super.onError(err, handler);
        }

        final refreshToken = getRefreshToken();
        if (refreshToken.isEmpty) {
          onRefreshFailed();
          return super.onError(err, handler);
        }

        _refreshCompleter = Completer<String?>();

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
            '$baseUrl${ApiConstants.refreshToken}',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final data = response.data as Map<String, dynamic>;
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = data['refreshToken'] as String;

            // Save new tokens
            await onTokensRefreshed(newAccessToken, newRefreshToken);
            _refreshCompleter!.complete(newAccessToken);

            final retried =
                await _retryRequest(err.requestOptions, newAccessToken);
            return handler.resolve(retried);
          }
        } on Object catch (e) {
          _refreshCompleter?.complete(null);
          AppLogger.error('Token Refresh Rotation failed: $e');
          onRefreshFailed();
        } finally {
          _refreshCompleter = null;
        }
      }
    }
    super.onError(err, handler);
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String token,
  ) {
    final retryHeaders = Map<String, dynamic>.from(options.headers);
    retryHeaders['Authorization'] = 'Bearer $token';

    final cloneDio = Dio(
      BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
      ),
    );

    return cloneDio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: retryHeaders,
      ),
    );
  }
}
