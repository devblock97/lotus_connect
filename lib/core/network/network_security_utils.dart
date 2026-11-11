/// Shared HTTP origin and endpoint validation helpers to prevent
/// credential leakage.
class NetworkSecurityUtils {
  const NetworkSecurityUtils._();

  /// Parses [rawUrl] into an HTTP/HTTPS [Uri] with a valid host and no userinfo.
  static Uri? parseHttpOriginUri(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !isValidHttpUri(uri)) return null;
    return uri;
  }

  /// Validates that [uri] uses `http` or `https`, has a non-empty host,
  /// and carries no embedded userinfo.
  static bool isValidHttpUri(Uri uri) {
    if (!uri.hasScheme || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      return false;
    }
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }

  /// Resolves the authoritative backend base URL from [serverHost] or
  /// [fallbackBaseUrl].
  static String? resolveTrustedBaseUrl({
    String? serverHost,
    String? fallbackBaseUrl,
  }) {
    final hostCandidate = serverHost?.trim() ?? '';
    if (hostCandidate.isNotEmpty) {
      return parseHttpOriginUri(hostCandidate) != null ? hostCandidate : null;
    }

    final fallbackCandidate = fallbackBaseUrl?.trim() ?? '';
    if (fallbackCandidate.isNotEmpty) {
      return parseHttpOriginUri(fallbackCandidate) != null
          ? fallbackCandidate
          : null;
    }

    return null;
  }

  /// Returns `true` only if [requestUri] matches the scheme, host, and port
  /// of the configured trusted backend base URL.
  static bool isTrustedOrigin(
    Uri requestUri, {
    String? serverHost,
    String? fallbackBaseUrl,
  }) {
    if (!isValidHttpUri(requestUri)) return false;

    final trustedBase = resolveTrustedBaseUrl(
      serverHost: serverHost,
      fallbackBaseUrl: fallbackBaseUrl,
    );
    final trustedUri = parseHttpOriginUri(trustedBase);
    if (trustedUri == null) return false;

    return requestUri.scheme.toLowerCase() == trustedUri.scheme.toLowerCase() &&
        requestUri.host.toLowerCase() == trustedUri.host.toLowerCase() &&
        requestUri.port == trustedUri.port;
  }

  /// Builds a full URL for [endpointPath] anchored strictly to the trusted base
  /// URL.
  static String? buildTrustedEndpointUrl({
    required String endpointPath,
    String? serverHost,
    String? fallbackBaseUrl,
  }) {
    final resolvedBase = resolveTrustedBaseUrl(
      serverHost: serverHost,
      fallbackBaseUrl: fallbackBaseUrl,
    );
    if (resolvedBase == null) return null;

    var base = resolvedBase;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    final normalizedPath =
        endpointPath.startsWith('/') ? endpointPath : '/$endpointPath';
    return '$base$normalizedPath';
  }
}
