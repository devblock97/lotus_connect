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
      'https://ef21-2001-ee0-26e-7703-64c2-be98-cc71-71d6.ngrok-free.app/api/v1';
}
