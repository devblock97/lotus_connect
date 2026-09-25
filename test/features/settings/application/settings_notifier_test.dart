import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/usecases/get_app_settings_use_case.dart';
import 'package:lotus_connect/features/settings/domain/usecases/update_app_setting_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAppSettingsUseCase extends Mock implements GetAppSettingsUseCase {}

class MockUpdateAppSettingUseCase extends Mock
    implements UpdateAppSettingUseCase {}

void main() {
  late MockGetAppSettingsUseCase mockGetUseCase;
  late MockUpdateAppSettingUseCase mockUpdateUseCase;
  late SettingsNotifier notifier;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const UpdateAppSettingParam(settings: AppSettings()),
    );
  });

  const initialSettings = AppSettings(
    userId: 'user_1',
    username: 'initial_user',
    email: 'initial@example.com',
    fullName: 'Initial User',
    avatarUrl: 'https://example.com/avatar.png',
  );

  setUp(() {
    mockGetUseCase = MockGetAppSettingsUseCase();
    mockUpdateUseCase = MockUpdateAppSettingUseCase();

    when(() => mockGetUseCase(any()))
        .thenAnswer((_) async => const Right(initialSettings));
    when(() => mockUpdateUseCase(any()))
        .thenAnswer((_) async => const Right(null));

    notifier = SettingsNotifier(
      getAppSettingsUseCase: mockGetUseCase,
      updateAppSettingUseCase: mockUpdateUseCase,
    );
  });

  group('SettingsNotifier', () {
    test('initial load should fetch settings and update state', () async {
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.settings, initialSettings);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, null);
      verify(() => mockGetUseCase(const NoParams())).called(1);
    });

    test('initial load failure should set errorMessage', () async {
      const failure = DatabaseFailure('Failed to load settings');
      when(() => mockGetUseCase(any()))
          .thenAnswer((_) async => const Left(failure));

      final failedNotifier = SettingsNotifier(
        getAppSettingsUseCase: mockGetUseCase,
        updateAppSettingUseCase: mockUpdateUseCase,
      );
      await Future<void>.delayed(Duration.zero);

      expect(failedNotifier.state.isLoading, false);
      expect(failedNotifier.state.errorMessage, 'Failed to load settings');
    });

    test('updateSettings should call update use case and update state',
        () async {
      const updated = AppSettings(
        userId: 'user_1',
        username: 'updated_user',
        fullName: 'Updated Name',
      );

      final success = await notifier.updateSettings(updated);

      expect(success, true);
      expect(notifier.state.settings, updated);
      expect(notifier.state.isSuccess, true);
      expect(notifier.state.isLoading, false);
      verify(
        () => mockUpdateUseCase(
          const UpdateAppSettingParam(settings: updated),
        ),
      ).called(1);
    });

    test('updateSettings failure should set errorMessage and return false',
        () async {
      const failure = DatabaseFailure('Write error');
      when(() => mockUpdateUseCase(any()))
          .thenAnswer((_) async => const Left(failure));

      const updated = AppSettings(userId: 'user_2');
      final success = await notifier.updateSettings(updated);

      expect(success, false);
      expect(notifier.state.isSuccess, false);
      expect(notifier.state.errorMessage, 'Write error');
    });

    test('setThemeMode should update theme mode', () async {
      await notifier.setThemeMode(AppThemeMode.sepia);

      expect(notifier.state.settings.themeMode, AppThemeMode.sepia);
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setLanguage should update language code', () async {
      await notifier.setLanguage('vi');

      expect(notifier.state.settings.languageCode, 'vi');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setAiProvider should update activeAiProvider', () async {
      await notifier.setAiProvider('gemini');

      expect(notifier.state.settings.activeAiProvider, 'gemini');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setAiModel should update activeAiModel', () async {
      await notifier.setAiModel('gemini-1.5-pro');

      expect(notifier.state.settings.activeAiModel, 'gemini-1.5-pro');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setGeminiApiKey should update apiKey and set provider to gemini',
        () async {
      await notifier.setGeminiApiKey('AIzaSyTestKey123');

      expect(notifier.state.settings.geminiApiKey, 'AIzaSyTestKey123');
      expect(notifier.state.settings.activeAiProvider, 'gemini');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setLocalLlmBaseUrl should update localLlmBaseUrl and provider',
        () async {
      await notifier.setLocalLlmBaseUrl('http://192.168.1.100:11434');

      expect(
        notifier.state.settings.localLlmBaseUrl,
        'http://192.168.1.100:11434',
      );
      expect(notifier.state.settings.activeAiProvider, 'local');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setTokens should update accessToken and refreshToken', () async {
      await notifier.setTokens('access_token_123', 'refresh_token_456');

      expect(notifier.state.settings.accessToken, 'access_token_123');
      expect(notifier.state.settings.refreshToken, 'refresh_token_456');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setSession should update all user session fields', () async {
      await notifier.setSession(
        accessToken: 'access_abc',
        refreshToken: 'refresh_def',
        userId: 'uid_99',
        username: 'john_doe',
        email: 'john@example.com',
        fullName: 'John Doe',
        avatarUrl: 'https://example.com/john.png',
      );

      final s = notifier.state.settings;
      expect(s.accessToken, 'access_abc');
      expect(s.refreshToken, 'refresh_def');
      expect(s.userId, 'uid_99');
      expect(s.username, 'john_doe');
      expect(s.email, 'john@example.com');
      expect(s.fullName, 'John Doe');
      expect(s.avatarUrl, 'https://example.com/john.png');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('setServerHost should update server host trimmed', () async {
      await notifier.setServerHost('  https://custom.server.com/api/v1  ');

      expect(
        notifier.state.settings.serverHost,
        'https://custom.server.com/api/v1',
      );
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('clearTokens should reset tokens and profile fields', () async {
      await notifier.clearTokens();

      final s = notifier.state.settings;
      expect(s.accessToken, '');
      expect(s.refreshToken, '');
      expect(s.userId, '');
      expect(s.username, '');
      expect(s.email, '');
      expect(s.fullName, '');
      expect(s.avatarUrl, '');
      verify(() => mockUpdateUseCase(any())).called(1);
    });
  });
}
