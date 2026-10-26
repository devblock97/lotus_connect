import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/create_story_notifier.dart';
import 'package:lotus_connect/features/home/application/create_story_state.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/presentation/view/create_story_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class _FakeCreateStoryNotifier extends StateNotifier<CreateStoryState>
    implements CreateStoryNotifier {
  _FakeCreateStoryNotifier([super.initialState = const CreateStoryState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettingsNotifier extends StateNotifier<SettingsState>
    implements SettingsNotifier {
  _FakeSettingsNotifier([AppSettings settings = const AppSettings()])
      : super(SettingsState(settings: settings));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testUser = AppSettings(
    userId: 'user_1',
    fullName: 'Lotus User',
    username: 'lotususer',
  );

  Widget createTestWidget({
    Locale locale = const Locale('en'),
    CreateStoryState initialState = const CreateStoryState(),
  }) {
    return ProviderScope(
      overrides: [
        settingsNotifierProvider.overrideWith(
          (_) => _FakeSettingsNotifier(testUser),
        ),
        createStoryNotifierProvider.overrideWith(
          (_) => _FakeCreateStoryNotifier(initialState),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CreateStoryScreen(),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('CreateStoryScreen Localization', () {
    testWidgets('renders in English (en) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tap to type'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Your story'), findsOneWidget);
      expect(find.text('Close Friends'), findsOneWidget);
      expect(find.byTooltip('Text'), findsOneWidget);
      expect(find.byTooltip('Background gradient'), findsOneWidget);
      expect(find.byTooltip('Photo filter'), findsOneWidget);
      expect(find.byTooltip('Stickers'), findsOneWidget);
    });

    testWidgets('renders in Vietnamese (vi) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createTestWidget(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      expect(find.text('Nhấn để nhập'), findsOneWidget);
      expect(find.text('Tạo'), findsOneWidget);
      expect(find.text('Thư viện'), findsOneWidget);
      expect(find.text('Máy ảnh'), findsOneWidget);
      expect(find.text('Tin của bạn'), findsOneWidget);
      expect(find.text('Bạn thân'), findsOneWidget);
      expect(find.byTooltip('Văn bản'), findsOneWidget);
      expect(find.byTooltip('Màu nền dải chuyển màu'), findsOneWidget);
      expect(find.byTooltip('Bộ lọc ảnh'), findsOneWidget);
      expect(find.byTooltip('Nhãn dán'), findsOneWidget);
    });

    testWidgets('renders in Japanese (ja) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createTestWidget(locale: const Locale('ja')));
      await tester.pumpAndSettle();

      expect(find.text('タップして入力'), findsOneWidget);
      expect(find.text('作成'), findsOneWidget);
      expect(find.text('ギャラリー'), findsOneWidget);
      expect(find.text('カメラ'), findsOneWidget);
      expect(find.text('あなたのストーリーズ'), findsOneWidget);
      expect(find.text('親しい友達'), findsOneWidget);
      expect(find.byTooltip('テキスト'), findsOneWidget);
      expect(find.byTooltip('背景グラデーション'), findsOneWidget);
      expect(find.byTooltip('写真フィルター'), findsOneWidget);
      expect(find.byTooltip('スタンプ'), findsOneWidget);
    });

    testWidgets('renders in Chinese (zh) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createTestWidget(locale: const Locale('zh')));
      await tester.pumpAndSettle();

      expect(find.text('点击输入'), findsOneWidget);
      expect(find.text('创建'), findsOneWidget);
      expect(find.text('图库'), findsOneWidget);
      expect(find.text('相机'), findsOneWidget);
      expect(find.text('你的快拍'), findsOneWidget);
      expect(find.text('密友'), findsOneWidget);
      expect(find.byTooltip('文字'), findsOneWidget);
      expect(find.byTooltip('背景渐变'), findsOneWidget);
      expect(find.byTooltip('照片滤镜'), findsOneWidget);
      expect(find.byTooltip('贴纸'), findsOneWidget);
    });

    testWidgets('shows localized discard dialog when closing with content',
        (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('vi'),
          initialState: const CreateStoryState(caption: 'Story edit'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap close button (Icons.close)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Hủy tin?'), findsOneWidget);
      expect(
        find.text(
          'Nếu quay lại bây giờ, bạn sẽ mất các chỉnh sửa đã thực hiện.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tiếp tục chỉnh sửa'), findsOneWidget);
      expect(find.text('Hủy bỏ'), findsOneWidget);
    });

    testWidgets('shows localized media picker sheet', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createTestWidget(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      // Tap Gallery chip
      await tester.tap(find.text('Thư viện'));
      await tester.pumpAndSettle();

      expect(find.text('Chọn ảnh'), findsOneWidget);
      expect(find.text('Chọn video'), findsOneWidget);
    });

    testWidgets('shows localized publishing overlay when publishing',
        (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('vi'),
          initialState: const CreateStoryState(isPublishing: true),
        ),
      );
      await tester.pump();

      expect(find.text('Đang chia sẻ tin...'), findsOneWidget);
    });
  });
}
