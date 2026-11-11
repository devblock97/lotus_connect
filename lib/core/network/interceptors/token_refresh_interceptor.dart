import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/network/network_security_utils.dart';

typedef DioFactory = Dio Function(BaseOptions options);

/// Interceptor to automatically refresh access tokens
/// using Refresh Token Rotation (RTR) on 401 responses from trusted origins.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required this.getRefreshToken,
    required this.onTokensRefreshed,
    required this.onRefreshFailed,
    this.getAccessToken,
    this.getServerHost,
    DioFactory? dioFactory,
  }) : _dioFactory = dioFactory ?? Dio.new;

  /// Getter to retrieve current refresh token.
  final String Function() getRefreshToken;

  /// Optional getter to retrieve current access token to avoid redundant
  /// refreshes.
  final String? Function()? getAccessToken;

  /// Optional getter to retrieve the active trusted server host URL.
  final String Function()? getServerHost;

  /// Callback called when tokens are successfully rotated.
  final Future<void> Function(String accessToken, String refreshToken)
      onTokensRefreshed;

  /// Callback called when token refresh fails (requiring logout/re-authentication).
  final VoidCallback onRefreshFailed;

  final DioFactory _dioFactory;

  static const String _isTokenRetryExtraKey = '_is_token_retry';

  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried =
        err.requestOptions.extra[_isTokenRetryExtraKey] == true;

    if (statusCode != 401 ||
        alreadyRetried ||
        _isAuthEndpoint(err.requestOptions.uri)) {
      handler.next(err);
      return;
    }

    final serverHost = getServerHost?.call();
    final isTrusted = NetworkSecurityUtils.isTrustedOrigin(
      err.requestOptions.uri,
      serverHost: serverHost,
      fallbackBaseUrl: err.requestOptions.baseUrl,
    );
    if (!isTrusted) {
      handler.next(err);
      return;
    }

    // Wait for an in-flight token refresh if one is already running.
    final inFlightRefresh = _refreshCompleter;
    if (inFlightRefresh != null) {
      final newAccessToken = await inFlightRefresh.future;
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _retryAndResolve(err, newAccessToken, handler);
        return;
      }
      handler.next(err);
      return;
    }

    // If another request already rotated the access token after this request
    // was dispatched, retry directly with the latest token.
    final latestAccessToken = getAccessToken?.call();
    final sentAuthHeader = _findAuthorizationHeader(err.requestOptions.headers);
    if (latestAccessToken != null &&
        latestAccessToken.isNotEmpty &&
        sentAuthHeader != null &&
        sentAuthHeader != 'Bearer $latestAccessToken') {
      await _retryAndResolve(err, latestAccessToken, handler);
      return;
    }

    final refreshToken = getRefreshToken();
    if (refreshToken.isEmpty) {
      onRefreshFailed();
      handler.next(err);
      return;
    }

    final refreshUrl = NetworkSecurityUtils.buildTrustedEndpointUrl(
      endpointPath: ApiConstants.refreshToken,
      serverHost: serverHost,
      fallbackBaseUrl: err.requestOptions.baseUrl,
    );
    if (refreshUrl == null) {
      onRefreshFailed();
      handler.next(err);
      return;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    String? newAccessToken;
    try {
      final refreshDio = _dioFactory(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post<dynamic>(
        refreshUrl,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final rotatedAccessToken = data['accessToken'];
        final rotatedRefreshToken = data['refreshToken'];

        if (rotatedAccessToken is String &&
            rotatedAccessToken.isNotEmpty &&
            rotatedRefreshToken is String &&
            rotatedRefreshToken.isNotEmpty) {
          await onTokensRefreshed(rotatedAccessToken, rotatedRefreshToken);
          newAccessToken = rotatedAccessToken;
          if (!completer.isCompleted) {
            completer.complete(rotatedAccessToken);
          }
        } else {
          throw const FormatException(
            'Refresh response missing valid accessToken or refreshToken',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on Object catch (e) {
      AppLogger.error('Token Refresh Rotation failed: $e');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      onRefreshFailed();
      handler.next(err);
      return;
    } finally {
      if (identical(_refreshCompleter, completer)) {
        _refreshCompleter = null;
      }
    }

    await _retryAndResolve(err, newAccessToken, handler);
  }

  bool _isAuthEndpoint(Uri uri) {
    final path = uri.path;
    return path.contains('/auth/') || path.endsWith('/auth');
  }

  String? _findAuthorizationHeader(Map<String, dynamic> headers) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization') {
        return entry.value?.toString();
      }
    }
    return null;
  }

  Future<void> _retryAndResolve(
    DioException originalErr,
    String newAccessToken,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final retried =
          await _retryRequest(originalErr.requestOptions, newAccessToken);
      handler.resolve(retried);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    } on Object catch (e) {
      AppLogger.error('Retrying request after token refresh failed: $e');
      handler.next(originalErr);
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String token,
  ) {
    final retryHeaders = Map<String, dynamic>.from(options.headers)
      ..removeWhere((key, _) => key.toLowerCase() == 'authorization')
      ..['Authorization'] = 'Bearer $token';

    final retryExtra = Map<String, dynamic>.from(options.extra)
      ..[_isTokenRetryExtraKey] = true;

    final cloneDio = _dioFactory(
      BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
      ),
    );

    var retryData = options.data;
    if (retryData is FormData) {
      retryData = retryData.clone();
    }

    return cloneDio.request<dynamic>(
      options.path,
      data: retryData,
      queryParameters: options.queryParameters,
      cancelToken: options.cancelToken,
      onSendProgress: options.onSendProgress,
      onReceiveProgress: options.onReceiveProgress,
      options: Options(
        method: options.method,
        headers: retryHeaders,
        extra: retryExtra,
        responseType: options.responseType,
        followRedirects: options.followRedirects,
        maxRedirects: options.maxRedirects,
        validateStatus: options.validateStatus,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
      ),
    );
  }
}
