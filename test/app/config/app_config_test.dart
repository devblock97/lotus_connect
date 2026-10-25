import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/app/config/app_config.dart';

void main() {
  group('AppConfig.normalizeHostForPlatform', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('maps 10.0.2.2 to localhost on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(
        AppConfig.normalizeHostForPlatform('https://10.0.2.2:8443/api/v1'),
        'https://localhost:8443/api/v1',
      );
      expect(
        AppConfig.normalizeHostForPlatform('http://10.0.2.2:8080/api/v1'),
        'http://localhost:8080/api/v1',
      );
    });

    test('retains localhost on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(
        AppConfig.normalizeHostForPlatform('https://localhost:8443/api/v1'),
        'https://localhost:8443/api/v1',
      );
    });

    test('maps localhost and 127.0.0.1 to 10.0.2.2 on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(
        AppConfig.normalizeHostForPlatform('https://localhost:8443/api/v1'),
        'https://10.0.2.2:8443/api/v1',
      );
      expect(
        AppConfig.normalizeHostForPlatform('http://127.0.0.1:8080/api/v1'),
        'http://10.0.2.2:8080/api/v1',
      );
    });

    test('retains 10.0.2.2 on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(
        AppConfig.normalizeHostForPlatform('https://10.0.2.2:8443/api/v1'),
        'https://10.0.2.2:8443/api/v1',
      );
    });

    test('preserves remote / ngrok URLs on all platforms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(
        AppConfig.normalizeHostForPlatform(
          'https://custom.ngrok-free.app/api/v1',
        ),
        'https://custom.ngrok-free.app/api/v1',
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(
        AppConfig.normalizeHostForPlatform(
          'https://api.lotusconnect.com/api/v1',
        ),
        'https://api.lotusconnect.com/api/v1',
      );
    });
  });
}
