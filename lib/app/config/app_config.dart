/// Application configuration and environment variables.
class AppConfig {
  const AppConfig._();

  /// Environment name.
  static const String environment = 'development';

  /// App display name.
  static const String appName = 'Lotus Connect';

  /// App version string.
  static const String appVersion = 'v1.0.0';

  /// Default backend server host URL.
  /// Configurable via `--dart-define=API_BASE_URL=...` or
  /// `--dart-define-from-file=.env`.
  ///
  /// Falls back to local development URL if not specified.
  static const String defaultServerHost = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: String.fromEnvironment(
      'SERVER_HOST',
      defaultValue: 'http://localhost:8080/api/v1',
    ),
  );
}
