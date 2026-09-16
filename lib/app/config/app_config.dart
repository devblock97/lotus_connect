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
  static const String defaultServerHost =
      'https://988d-2001-ee0-1b08-ffd0-25be-640e-98fe-1197.ngrok-free.app/api/v1';
}
