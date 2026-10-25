import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings.serverHost', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns localhost when running on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const settings = AppSettings();

      expect(settings.serverHost, contains('localhost'));
      expect(settings.serverHost, isNot(contains('10.0.2.2')));
    });

    test('returns 10.0.2.2 when running on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      const settings = AppSettings();

      expect(settings.serverHost, contains('10.0.2.2'));
      expect(settings.serverHost, isNot(contains('localhost')));
    });

    test('preserves custom remote host across platforms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const settings =
          AppSettings(serverHost: 'https://custom.backend.com/api/v1');

      expect(settings.serverHost, 'https://custom.backend.com/api/v1');
    });
  });
}
