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
      'https://56bf-2001-ee0-192-c669-502a-5600-4ab7-98a3.ngrok-free.app/api/v1';
}
