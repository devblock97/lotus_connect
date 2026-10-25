import 'package:flutter/foundation.dart';

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
  /// `--dart-define-from-file=.env` (or `.env.ios` / `.env.android`).
  ///
  /// Falls back to local development URL if not specified.
  static const String defaultServerHost = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: String.fromEnvironment(
      'SERVER_HOST',
      defaultValue: 'http://localhost:8080/api/v1',
    ),
  );

  /// Normalizes a host URL for the target platform.
  ///
  /// - On iOS (simulator or device): Android emulator address `10.0.2.2` is
  ///   automatically mapped to `localhost`.
  /// - On Android: `localhost` and `127.0.0.1` are automatically mapped to
  ///   `10.0.2.2` so the Android emulator can reach the host development machine.
  /// - Remote URLs (e.g. ngrok or production domains) and web/desktop targets are
  ///   preserved as-is.
  static String normalizeHostForPlatform(String host) {
    if (kIsWeb) return host;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (host.contains('10.0.2.2')) {
        return host.replaceAll('10.0.2.2', 'localhost');
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      if (host.contains('localhost')) {
        return host.replaceAll('localhost', '10.0.2.2');
      } else if (host.contains('127.0.0.1')) {
        return host.replaceAll('127.0.0.1', '10.0.2.2');
      }
    }
    return host;
  }
}
