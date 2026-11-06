import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/application/auth_notifier.dart';
import 'package:lotus_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/usecases/get_app_settings_use_case.dart';
import 'package:lotus_connect/features/settings/domain/usecases/update_app_setting_use_case.dart';
import 'package:lotus_connect/features/settings/presentation/views/settings_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAppSettingsUseCase extends Mock
    implements GetAppSettingsUseCase {}

class _MockUpdateAppSettingUseCase extends Mock
    implements UpdateAppSettingUseCase {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockRegisterUseCase extends Mock implements RegisterUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockGetCurrentUserUseCase extends Mock
    implements GetCurrentUserUseCase {}

void main() {
  late _MockGetAppSettingsUseCase mockGetSettingsUseCase;
  late _MockUpdateAppSettingUseCase mockUpdateSettingUseCase;
  late _MockLoginUseCase mockLoginUseCase;
  late _MockRegisterUseCase mockRegisterUseCase;
  late _MockLogoutUseCase mockLogoutUseCase;
  late _MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const sampleSettings = AppSettings(
    userId: 'user-1',
    username: 'thong_nguyen',
    fullName: 'Thong Nguyen',
    email: 'thong@lotus.io',
    languageCode: 'en',
    themeMode: AppThemeMode.dark,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const UpdateAppSettingParam(settings: AppSettings()),
    );
  });

  setUp(() {
    mockGetSettingsUseCase = _MockGetAppSettingsUseCase();
    mockUpdateSettingUseCase = _MockUpdateAppSettingUseCase();
    mockLoginUseCase = _MockLoginUseCase();
    mockRegisterUseCase = _MockRegisterUseCase();
    mockLogoutUseCase = _MockLogoutUseCase();
    mockGetCurrentUserUseCase = _MockGetCurrentUserUseCase();

    when(() => mockGetSettingsUseCase(any()))
        .thenAnswer((_) async => const Right(sampleSettings));
    when(() => mockUpdateSettingUseCase(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockGetCurrentUserUseCase(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockLogoutUseCase(any()))
        .thenAnswer((_) async => const Right(null));
  });

  SettingsNotifier buildSettingsNotifier([AppSettings? initial]) {
    if (initial != null) {
      when(() => mockGetSettingsUseCase(any()))
          .thenAnswer((_) async => Right(initial));
    }
    return SettingsNotifier(
      getAppSettingsUseCase: mockGetSettingsUseCase,
      updateAppSettingUseCase: mockUpdateSettingUseCase,
    );
  }

  Widget createLocalizedApp({
    required WidgetTester tester,
    required Widget home,
    required Locale locale,
    required SettingsNotifier settingsNotifier,
  }) {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    return ProviderScope(
      overrides: [
        settingsNotifierProvider.overrideWith((ref) => settingsNotifier),
        authStateProvider.overrideWith(
          (ref) => AuthNotifier(
            ref,
            loginUseCase: mockLoginUseCase,
            registerUseCase: mockRegisterUseCase,
            logoutUseCase: mockLogoutUseCase,
            getCurrentUserUseCase: mockGetCurrentUserUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  group('SettingsScreen Localization', () {
    testWidgets('renders SettingsScreen in English', (tester) async {
      final notifier = buildSettingsNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const SettingsScreen(),
          locale: const Locale('en'),
          settingsNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Thong Nguyen'), findsOneWidget);
      expect(find.text('thong@lotus.io'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('Theme Selection'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Sepia'), findsOneWidget);
      expect(find.text('INFORMATION'), findsOneWidget);
      expect(find.text('About LotusConnect'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('renders SettingsScreen in Vietnamese', (tester) async {
      final notifier = buildSettingsNotifier(
        sampleSettings.copyWith(languageCode: 'vi'),
      );

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const SettingsScreen(),
          locale: const Locale('vi'),
          settingsNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cá nhân & Cài đặt'), findsOneWidget);
      expect(find.text('CÀI ĐẶT CHUNG'), findsOneWidget);
      expect(find.text('Chỉnh sửa cá nhân'), findsOneWidget);
      expect(find.text('Cài đặt thông báo'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('GIAO DIỆN'), findsOneWidget);
      expect(find.text('Lựa chọn chủ đề'), findsOneWidget);
      expect(find.text('Sáng'), findsOneWidget);
      expect(find.text('Tối'), findsOneWidget);
      expect(find.text('Sepia'), findsOneWidget);
      expect(find.text('THÔNG TIN CHUNG'), findsOneWidget);
      expect(find.text('Giới thiệu LotusConnect'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
    });

    testWidgets('renders SettingsScreen in Japanese', (tester) async {
      final notifier = buildSettingsNotifier(
        sampleSettings.copyWith(languageCode: 'ja'),
      );

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const SettingsScreen(),
          locale: const Locale('ja'),
          settingsNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('プロフィールと設定'), findsOneWidget);
      expect(find.text('一般設定'), findsOneWidget);
      expect(find.text('プロフィール編集'), findsOneWidget);
      expect(find.text('通知設定'), findsOneWidget);
      expect(find.text('言語'), findsOneWidget);
      expect(find.text('日本語'), findsOneWidget);
      expect(find.text('外観設定'), findsOneWidget);
      expect(find.text('テーマ選択'), findsOneWidget);
      expect(find.text('ライト'), findsOneWidget);
      expect(find.text('ダーク'), findsOneWidget);
      expect(find.text('セピア'), findsOneWidget);
      expect(find.text('アプリ情報'), findsOneWidget);
      expect(find.text('LotusConnectについて'), findsOneWidget);
      expect(find.text('ログアウト'), findsOneWidget);
    });

    testWidgets('renders SettingsScreen in Chinese', (tester) async {
      final notifier = buildSettingsNotifier(
        sampleSettings.copyWith(languageCode: 'zh'),
      );

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const SettingsScreen(),
          locale: const Locale('zh'),
          settingsNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('个人资料与设置'), findsOneWidget);
      expect(find.text('通用设置'), findsOneWidget);
      expect(find.text('编辑资料'), findsOneWidget);
      expect(find.text('通知设置'), findsOneWidget);
      expect(find.text('语言'), findsOneWidget);
      expect(find.text('中文'), findsOneWidget);
      expect(find.text('外观'), findsOneWidget);
      expect(find.text('主题选择'), findsOneWidget);
      expect(find.text('浅色'), findsOneWidget);
      expect(find.text('深色'), findsOneWidget);
      expect(find.text('复古'), findsOneWidget);
      expect(find.text('信息'), findsOneWidget);
      expect(find.text('关于 LotusConnect'), findsOneWidget);
      expect(find.text('退出登录'), findsOneWidget);
    });

    testWidgets(
        'renders localized unknownUser fallback when fullName and username are empty',
        (tester) async {
      final notifier = buildSettingsNotifier(
        const AppSettings(
          userId: 'user-empty',
          email: 'anon@lotus.io',
          languageCode: 'vi',
        ),
      );

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const SettingsScreen(),
          locale: const Locale('vi'),
          settingsNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Người dùng không xác định'), findsOneWidget);
      expect(find.text('anon@lotus.io'), findsOneWidget);
    });

    testWidgets('updates language when dropdown option is selected',
        (tester) async {
      final notifier = buildSettingsNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const SettingsScreen(),
          locale: const Locale('en'),
          settingsNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tiếng Việt').last);
      await tester.pumpAndSettle();

      expect(notifier.state.settings.languageCode, 'vi');
    });

    testWidgets('updates themeMode when theme card is tapped', (tester) async {
      final notifier = buildSettingsNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const SettingsScreen(),
          locale: const Locale('en'),
          settingsNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sepia'));
      await tester.pumpAndSettle();

      expect(notifier.state.settings.themeMode, AppThemeMode.sepia);
    });
  });
}
