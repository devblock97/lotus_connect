import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/chill/chill.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/usecases/get_app_settings_use_case.dart';
import 'package:lotus_connect/features/settings/domain/usecases/update_app_setting_use_case.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetChillFeedUseCase extends Mock implements GetChillFeedUseCase {}

class _MockToggleLikeChillUseCase extends Mock
    implements ToggleLikeChillUseCase {}

class _MockToggleSaveChillUseCase extends Mock
    implements ToggleSaveChillUseCase {}

class _MockShareChillUseCase extends Mock implements ShareChillUseCase {}

class _MockDeleteChillUseCase extends Mock implements DeleteChillUseCase {}

class _MockGetAppSettingsUseCase extends Mock
    implements GetAppSettingsUseCase {}

class _MockUpdateAppSettingUseCase extends Mock
    implements UpdateAppSettingUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockGetChillFeedUseCase mockGetChillFeedUseCase;
  late _MockToggleLikeChillUseCase mockToggleLikeChillUseCase;
  late _MockToggleSaveChillUseCase mockToggleSaveChillUseCase;
  late _MockShareChillUseCase mockShareChillUseCase;
  late _MockDeleteChillUseCase mockDeleteChillUseCase;
  late _MockGetAppSettingsUseCase mockGetSettingsUseCase;
  late _MockUpdateAppSettingUseCase mockUpdateSettingUseCase;

  const sampleSettings = AppSettings(
    userId: 'author-1',
    username: 'thong_nguyen',
    fullName: 'Thong Nguyen',
    email: 'thong@lotus.io',
  );

  final sampleChill = ChillItem(
    id: 'chill-1',
    author: const PostAuthor(
      id: 'author-1',
      username: 'thong_nguyen',
      fullName: 'Thong Nguyen',
    ),
    // Empty URL triggers _hasError synchronously in tests without platform
    // video channels.
    videoUrl: '',
    createdAt: DateTime(2026, 11, 7),
    caption: 'A very long caption that exceeds seventy characters so the '
        'expand and collapse toggle is visible in the UI.',
    tags: const ['flutter', 'chill'],
    likeCount: 12,
    commentCount: 3,
    shareCount: 1,
    viewCount: 250,
    isRemix: true,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const UpdateAppSettingParam(settings: AppSettings()),
    );
    registerFallbackValue(const GetChillFeedParams());
    registerFallbackValue(
      const ToggleLikeChillParams(chillId: '', isLiked: true),
    );
    registerFallbackValue(
      const ToggleSaveChillParams(chillId: '', isSaved: true),
    );
    registerFallbackValue(const ShareChillParams(chillId: ''));
    registerFallbackValue(const DeleteChillParams(chillId: ''));

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      return null;
    });
  });

  setUp(() {
    mockGetChillFeedUseCase = _MockGetChillFeedUseCase();
    mockToggleLikeChillUseCase = _MockToggleLikeChillUseCase();
    mockToggleSaveChillUseCase = _MockToggleSaveChillUseCase();
    mockShareChillUseCase = _MockShareChillUseCase();
    mockDeleteChillUseCase = _MockDeleteChillUseCase();
    mockGetSettingsUseCase = _MockGetAppSettingsUseCase();
    mockUpdateSettingUseCase = _MockUpdateAppSettingUseCase();

    when(() => mockGetSettingsUseCase(any()))
        .thenAnswer((_) async => const Right(sampleSettings));
    when(() => mockUpdateSettingUseCase(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockToggleLikeChillUseCase(any()))
        .thenAnswer((_) async => const Right(true));
    when(() => mockToggleSaveChillUseCase(any()))
        .thenAnswer((_) async => const Right(true));
    when(() => mockShareChillUseCase(any()))
        .thenAnswer((_) async => Right(sampleChill.copyWith(shareCount: 2)));
  });

  ChillNotifier buildChillNotifier() {
    return ChillNotifier(
      getChillFeedUseCase: mockGetChillFeedUseCase,
      toggleLikeChillUseCase: mockToggleLikeChillUseCase,
      toggleSaveChillUseCase: mockToggleSaveChillUseCase,
      shareChillUseCase: mockShareChillUseCase,
      deleteChillUseCase: mockDeleteChillUseCase,
    );
  }

  SettingsNotifier buildSettingsNotifier() {
    return SettingsNotifier(
      getAppSettingsUseCase: mockGetSettingsUseCase,
      updateAppSettingUseCase: mockUpdateSettingUseCase,
    );
  }

  Widget createLocalizedApp({
    required WidgetTester tester,
    required Widget home,
    required Locale locale,
    required ChillNotifier chillNotifier,
  }) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final settingsNotifier = buildSettingsNotifier();

    return ProviderScope(
      overrides: [
        chillNotifierProvider.overrideWith((ref) => chillNotifier),
        settingsNotifierProvider.overrideWith((ref) => settingsNotifier),
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

  group('Chill Presentation Localization', () {
    testWidgets('renders empty state and tag filter in Vietnamese',
        (tester) async {
      when(() => mockGetChillFeedUseCase(any()))
          .thenAnswer((_) async => const Right([]));

      final notifier = buildChillNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const ChillViewerScreen(isModal: true),
          locale: const Locale('vi'),
          chillNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chills'), findsOneWidget);
      expect(find.text('Chưa có Chills nào'), findsOneWidget);

      await notifier.setTagFilter('music');
      await tester.pumpAndSettle();

      expect(
        find.text('Không tìm thấy Chills nào cho #music'),
        findsOneWidget,
      );
      expect(find.text('Xóa bộ lọc thẻ'), findsOneWidget);
    });

    testWidgets('renders empty state and tag filter in Japanese',
        (tester) async {
      when(() => mockGetChillFeedUseCase(any()))
          .thenAnswer((_) async => const Right([]));

      final notifier = buildChillNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const ChillViewerScreen(isModal: true),
          locale: const Locale('ja'),
          chillNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('まだChillsがありません'), findsOneWidget);

      await notifier.setTagFilter('tokyo');
      await tester.pumpAndSettle();

      expect(
        find.text('#tokyo のChillsが見つかりませんでした'),
        findsOneWidget,
      );
      expect(find.text('タグフィルターを解除'), findsOneWidget);
    });

    testWidgets('renders failure state with retry button in Chinese',
        (tester) async {
      when(() => mockGetChillFeedUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('')),
      );

      final notifier = buildChillNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: const ChillViewerScreen(isModal: true),
          locale: const Locale('zh'),
          chillNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      // Empty string failure message uses message; test null fallback via state
      notifier.state = notifier.state.copyWith(
        status: ChillStatus.failure,
      );
      await tester.pumpAndSettle();

      expect(find.text('无法加载 Chills'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('renders VideoItem labels and actions in English',
        (tester) async {
      final notifier = buildChillNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: ChillViewerScreen(
            initialChills: [sampleChill],
            isModal: true,
          ),
          locale: const Locale('en'),
          chillNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to play video'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Original Audio - Thong Nguyen'), findsOneWidget);
      expect(find.text('Remix'), findsOneWidget);

      // Expand caption -> shows 'Less'
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Less'), findsOneWidget);

      // Toggle save -> shows 'Saved'
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('renders VideoItem labels and actions in Vietnamese',
        (tester) async {
      final notifier = buildChillNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: ChillViewerScreen(
            initialChills: [sampleChill],
            isModal: true,
          ),
          locale: const Locale('vi'),
          chillNotifier: notifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không thể phát video'), findsOneWidget);
      expect(find.text('Lưu'), findsOneWidget);
      expect(find.text('Xem thêm'), findsOneWidget);
      expect(find.text('Âm thanh gốc - Thong Nguyen'), findsOneWidget);
      expect(find.text('Phối lại'), findsOneWidget);

      // Expand caption -> shows 'Ẩn bớt'
      await tester.tap(find.text('Xem thêm'));
      await tester.pumpAndSettle();
      expect(find.text('Ẩn bớt'), findsOneWidget);

      // Toggle save -> shows 'Đã lưu'
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();
      expect(find.text('Đã lưu'), findsOneWidget);

      // Share -> shows localized snackbar
      await tester.tap(
        find.byIcon(CupertinoIcons.arrowshape_turn_up_right_fill),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Đã sao chép liên kết Chill vào bộ nhớ tạm!'),
        findsOneWidget,
      );
    });

    testWidgets('renders VideoItem labels in Japanese and Chinese',
        (tester) async {
      final jaNotifier = buildChillNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: ChillViewerScreen(
            initialChills: [sampleChill.copyWith(userHasSaved: true)],
            isModal: true,
          ),
          locale: const Locale('ja'),
          chillNotifier: jaNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('動画を再生できません'), findsOneWidget);
      expect(find.text('保存済み'), findsOneWidget);
      expect(find.text('もっと見る'), findsOneWidget);
      expect(find.text('オリジナル音源 - Thong Nguyen'), findsOneWidget);
      expect(find.text('リミックス'), findsOneWidget);

      final zhNotifier = buildChillNotifier();

      await tester.pumpWidget(
        createLocalizedApp(
          tester: tester,
          home: ChillViewerScreen(
            initialChills: [sampleChill.copyWith(userHasSaved: true)],
            isModal: true,
          ),
          locale: const Locale('zh'),
          chillNotifier: zhNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('无法播放视频'), findsOneWidget);
      expect(find.text('已保存'), findsOneWidget);
      expect(find.text('更多'), findsOneWidget);
      expect(find.text('原声 - Thong Nguyen'), findsOneWidget);
      expect(find.text('混音'), findsOneWidget);
    });
  });
}
