import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/auth/application/auth_notifier.dart';
import 'package:lotus_connect/features/auth/presentation/views/login_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier([super.initialState = const AuthState()]);

  bool loginResult = true;
  bool registerResult = true;

  @override
  Future<bool> login({required String email, required String password}) async {
    return loginResult;
  }

  @override
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    return registerResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createLoginScreenWidget({
    Locale locale = const Locale('en'),
    AuthState authState = const AuthState(),
    _FakeAuthNotifier? notifier,
  }) {
    final fakeNotifier = notifier ?? _FakeAuthNotifier(authState);
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => fakeNotifier),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Localization Tests', () {
    testWidgets('renders English localized text by default in Login mode',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createLoginScreenWidget());
      await tester.pumpAndSettle();

      expect(find.text('Lotus Connect'), findsOneWidget);
      expect(
        find.text('Sign in to continue your secure conversations.'),
        findsOneWidget,
      );
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('name@company.com'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('•••••••••'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('OR CONTINUE WITH'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(find.byTooltip('Show password'), findsOneWidget);
    });

    testWidgets('renders Vietnamese localized text when locale is vi',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createLoginScreenWidget(locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lotus Connect'), findsOneWidget);
      expect(
        find.text(
          'Đăng nhập để tiếp tục các cuộc trò chuyện bảo mật của bạn.',
        ),
        findsOneWidget,
      );
      expect(find.text('ĐỊA CHỈ EMAIL'), findsOneWidget);
      expect(find.text('MẬT KHẨU'), findsOneWidget);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('HOẶC TIẾP TỤC VỚI'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Chưa có tài khoản? '), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.byTooltip('Hiện mật khẩu'), findsOneWidget);
    });

    testWidgets('renders Japanese localized text when locale is ja',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createLoginScreenWidget(locale: const Locale('ja')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lotus Connect'), findsOneWidget);
      expect(
        find.text('サインインして安全なチャットを再開します。'),
        findsOneWidget,
      );
      expect(find.text('メールアドレス'), findsOneWidget);
      expect(find.text('パスワード'), findsOneWidget);
      expect(find.text('パスワードをお忘れですか？'), findsOneWidget);
      expect(find.text('ログイン'), findsOneWidget);
      expect(find.text('または以下で継続'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('アカウントをお持ちでないですか？ '), findsOneWidget);
      expect(find.text('新規登録'), findsOneWidget);
      expect(find.byTooltip('パスワードを表示'), findsOneWidget);
    });

    testWidgets('renders Chinese localized text when locale is zh',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createLoginScreenWidget(locale: const Locale('zh')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lotus Connect'), findsOneWidget);
      expect(
        find.text('登录以继续您的安全对话。'),
        findsOneWidget,
      );
      expect(find.text('电子邮箱'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
      expect(find.text('忘记密码？'), findsOneWidget);
      expect(find.text('登录'), findsOneWidget);
      expect(find.text('或通过以下方式继续'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('还没有账户？'), findsOneWidget);
      expect(find.text('注册'), findsOneWidget);
      expect(find.byTooltip('显示密码'), findsOneWidget);
    });

    testWidgets(
        'switching to Registration mode renders localized register fields',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createLoginScreenWidget());
      await tester.pumpAndSettle();

      // Tap Register toggle
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(
        find.text('Join the future of secure communication.'),
        findsOneWidget,
      );
      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('Enter your full name'), findsOneWidget);
      expect(find.text('USERNAME'), findsOneWidget);
      expect(find.text('Choose a unique username'), findsOneWidget);
      expect(find.text('Create a strong password'), findsOneWidget);
      expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
      expect(find.text('Repeat your password'), findsOneWidget);
      expect(
        find.textContaining('Terms of Service', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Privacy Policy', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('password visibility toggle updates icon and tooltip',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createLoginScreenWidget());
      await tester.pumpAndSettle();

      final toggleFinder = find.byTooltip('Show password');
      expect(toggleFinder, findsOneWidget);

      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('shows validation errors in current locale on empty submit',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createLoginScreenWidget());
      await tester.pumpAndSettle();

      // Tap Log In button with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email address'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets(
        'registration terms checkbox validation shows localized snackbar',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createLoginScreenWidget());
      await tester.pumpAndSettle();

      // Switch to Register mode
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Enter valid fields without checking terms
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your full name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Choose a unique username'),
        'johndoe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'name@company.com'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Create a strong password'),
        'Secret123!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repeat your password'),
        'Secret123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('You must agree to the Terms of Service & Privacy Policy.'),
        findsOneWidget,
      );
    });

    testWidgets('passwords mismatch validation shows localized snackbar',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createLoginScreenWidget());
      await tester.pumpAndSettle();

      // Switch to Register mode
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Agree to terms
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your full name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Choose a unique username'),
        'johndoe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'name@company.com'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Create a strong password'),
        'Secret123!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repeat your password'),
        'Mismatch123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Passwords do not match'),
        findsOneWidget,
      );
    });

    testWidgets('successful registration shows localized success snackbar',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeNotifier = _FakeAuthNotifier()..registerResult = true;

      await tester.pumpWidget(
        createLoginScreenWidget(notifier: fakeNotifier),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your full name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Choose a unique username'),
        'johndoe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'name@company.com'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Create a strong password'),
        'Secret123!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repeat your password'),
        'Secret123!',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Registration successful! Please login.'),
        findsOneWidget,
      );
    });

    testWidgets('failed login shows localized error message fallback',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeNotifier = _FakeAuthNotifier()..loginResult = false;

      await tester.pumpWidget(
        createLoginScreenWidget(notifier: fakeNotifier),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'name@company.com'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '•••••••••'),
        'secret123',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to log in'), findsOneWidget);
    });

    testWidgets('renders Vietnamese localized error on failed login',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeNotifier = _FakeAuthNotifier()..loginResult = false;

      await tester.pumpWidget(
        createLoginScreenWidget(
          locale: const Locale('vi'),
          notifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'ten@congty.com'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '•••••••••'),
        'secret123',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Đăng nhập thất bại'), findsOneWidget);
    });
  });
}
