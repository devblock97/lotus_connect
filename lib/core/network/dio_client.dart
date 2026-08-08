import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/interceptors/auth_interceptor.dart';
import 'package:lotus_connect/core/network/interceptors/dynamic_base_url_interceptor.dart';
import 'package:lotus_connect/core/network/interceptors/logging_interceptor.dart';
import 'package:lotus_connect/core/network/interceptors/retry_interceptor.dart';
import 'package:lotus_connect/core/network/interceptors/token_refresh_interceptor.dart';

/// Customized Dio HTTP client for network operations.
class DioClient {
  /// Creates a configured [DioClient].
  DioClient({
    String? baseUrl,
    String? Function()? tokenGetter,
    String Function()? serverHostGetter,
    String Function()? refreshTokenGetter,
    Future<void> Function(String accessToken, String refreshToken)?
        onTokensRefreshed,
    VoidCallback? onRefreshFailed,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      if (serverHostGetter != null)
        DynamicBaseUrlInterceptor(getServerHost: serverHostGetter),
      if (tokenGetter != null) AuthInterceptor(getToken: tokenGetter),
      if (refreshTokenGetter != null &&
          onTokensRefreshed != null &&
          onRefreshFailed != null)
        TokenRefreshInterceptor(
          getRefreshToken: refreshTokenGetter,
          onTokensRefreshed: onTokensRefreshed,
          onRefreshFailed: onRefreshFailed,
        ),
      RetryInterceptor(dio: _dio),
    ]);
  }

  final Dio _dio;

  /// Exposes the underlying Dio instance.
  Dio get dio => _dio;

  /// Executes a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Executes a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Executes a POST request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Executes a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  NetworkException _handleDioException(DioException e) {
    return NetworkException(
      e.message ?? 'Network error occurred',
      statusCode: e.response?.statusCode,
      cause: e,
    );
  }
}
