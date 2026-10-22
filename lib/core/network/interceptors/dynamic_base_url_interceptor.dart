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
    final host = getServerHost();

    // If requesting an /uploads/ resource, rebase to the active server host
    if (path.contains('/uploads/')) {
      final uploadIndex = path.indexOf('/uploads/');
      final uploadPath = path.substring(uploadIndex);
      var baseHost = host;
      if (baseHost.endsWith('/api/v1')) {
        baseHost = baseHost.substring(0, baseHost.length - '/api/v1'.length);
      }
      while (baseHost.endsWith('/')) {
        baseHost = baseHost.substring(0, baseHost.length - 1);
      }
      if (baseHost.isNotEmpty) {
        options
          ..path = '$baseHost$uploadPath'
          ..baseUrl = '';
        handler.next(options);
        return;
      }
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      options.baseUrl = '';
      handler.next(options);
      return;
    }

    var base = host;
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    if (base.endsWith('/api/v1') && path.startsWith('/api/v1')) {
      path = path.substring('/api/v1'.length);
    }
    options
      ..path = '$base$path'
      ..baseUrl = '';
    handler.next(options);
  }
}
