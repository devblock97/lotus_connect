/// Normalizes a media URL against the active server host if it points to an
/// `/uploads/` resource on a backend instance.
///
/// This ensures that if the database contains media saved with an expired or
/// different tunnel/localhost host, the client seamlessly redirects requests
/// to the currently active server host.
String normalizeMediaUrl(String url, {required String serverHost}) {
  if (url.isEmpty || serverHost.isEmpty) return url;
  if (!url.contains('/uploads/')) return url;

  final uploadIndex = url.indexOf('/uploads/');
  final uploadPath = url.substring(uploadIndex);

  var baseHost = serverHost;
  if (baseHost.endsWith('/api/v1')) {
    baseHost = baseHost.substring(0, baseHost.length - '/api/v1'.length);
  } else if (baseHost.endsWith('/api/v1/')) {
    baseHost = baseHost.substring(0, baseHost.length - '/api/v1/'.length);
  }

  while (baseHost.endsWith('/')) {
    baseHost = baseHost.substring(0, baseHost.length - 1);
  }

  if (baseHost.isEmpty) return url;
  return '$baseHost$uploadPath';
}
