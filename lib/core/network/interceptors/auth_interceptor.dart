import 'package:dio/dio.dart';

/// Interceptor to inject Authorization headers when authenticated.
class AuthInterceptor extends Interceptor {
  /// Token getter callback.
  AuthInterceptor({required this.getToken});

  /// Function to retrieve current auth token.
  final String? Function() getToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
