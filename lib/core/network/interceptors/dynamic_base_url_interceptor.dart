import 'package:dio/dio.dart';

/// Interceptor to dynamically change the base URL based on settings.
class DynamicBaseUrlInterceptor extends Interceptor {
  /// Base URL getter.
  DynamicBaseUrlInterceptor({required this.getServerHost});

  /// Function to retrieve the current server host base URL.
  final String Function() getServerHost;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    var path = options.path;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      options.baseUrl = '';
      handler.next(options);
      return;
    }

    var host = getServerHost();
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    if (host.endsWith('/api/v1') && path.startsWith('/api/v1')) {
      path = path.substring('/api/v1'.length);
    }
    options
      ..path = '$host$path'
      ..baseUrl = '';
    handler.next(options);
  }
}
