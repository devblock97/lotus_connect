import 'package:dio/dio.dart';
import 'package:lotus_connect/core/network/network_security_utils.dart';

/// Interceptor to inject Authorization headers when authenticated,
/// strictly scoped to requests targeting the trusted backend origin.
class AuthInterceptor extends Interceptor {
  /// Token getter callback and optional trusted server host getter.
  AuthInterceptor({
    required this.getToken,
    this.getTrustedServerHost,
  });

  /// Function to retrieve current auth token.
  final String? Function() getToken;

  /// Optional function to retrieve the active trusted server host URL.
  final String Function()? getTrustedServerHost;

  static const String _authInjectedExtraKey = '_auth_interceptor_injected';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isTrusted = NetworkSecurityUtils.isTrustedOrigin(
      options.uri,
      serverHost: getTrustedServerHost?.call(),
      fallbackBaseUrl: options.baseUrl,
    );

    if (!isTrusted) {
      // Clear previously injected Bearer token if a retry targets an untrusted
      // host.
      if (options.extra[_authInjectedExtraKey] == true) {
        options.headers.removeWhere(
          (key, _) => key.toLowerCase() == 'authorization',
        );
        options.extra.remove(_authInjectedExtraKey);
      }
      handler.next(options);
      return;
    }

    final token = getToken();
    if (token != null && token.isNotEmpty) {
      options.headers.removeWhere(
        (key, _) => key.toLowerCase() == 'authorization',
      );
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_authInjectedExtraKey] = true;
    }
    handler.next(options);
  }
}
