import 'package:dio/dio.dart';

/// Interceptor to dynamically change the base URL based on settings.
class DynamicBaseUrlInterceptor extends Interceptor {
  /// Base URL getter.
  DynamicBaseUrlInterceptor({required this.getServerHost});

  /// Function to retrieve the current server host base URL.
  final String Function() getServerHost;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Override the request base URL with the dynamic server host from preferences
    options.baseUrl = getServerHost();
    handler.next(options);
  }
}
