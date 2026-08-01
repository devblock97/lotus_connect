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
  static const String defaultServerHost = 'https://be10-2001-ee0-1b38-2b4c-2838-129a-ce08-7508.ngrok-free.app/api/v1';
}
