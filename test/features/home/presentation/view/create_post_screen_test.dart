import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/create_post_params.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_post_usecase.dart';
import 'package:lotus_connect/features/home/presentation/view/create_post_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

class MockUpdatePostUseCase extends Mock implements UpdatePostUseCase {}

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

class FakeSettingsNotifier extends StateNotifier<SettingsState>
    implements SettingsNotifier {
  FakeSettingsNotifier(AppSettings settings)
      : super(SettingsState(settings: settings));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockCreatePostUseCase mockCreatePostUseCase;
  late MockUpdatePostUseCase mockUpdatePostUseCase;
  late MockGetFeedUseCase mockGetFeedUseCase;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const GetFeedParam());
    registerFallbackValue(const CreatePostParams());
    registerFallbackValue(
      const UpdatePostParams(postId: 'fallback', content: 'fallback'),
    );
  });

  setUp(() {
    mockCreatePostUseCase = MockCreatePostUseCase();
    mockUpdatePostUseCase = MockUpdatePostUseCase();
    mockGetFeedUseCase = MockGetFeedUseCase();

    when(() => mockGetFeedUseCase(any()))
        .thenAnswer((_) async => const Right(<PostItem>[]));
  });

  Widget buildTestWidget({
    Locale locale = const Locale('en'),
    PostItem? postToEdit,
    String fullName = 'Alice Smith',
    String username = 'alice',
  }) {
    return ProviderScope(
      overrides: [
        createPostUseCaseProvider.overrideWithValue(mockCreatePostUseCase),
        updatePostUseCaseProvider.overrideWithValue(mockUpdatePostUseCase),
        settingsNotifierProvider.overrideWith(
          (_) => FakeSettingsNotifier(
            AppSettings(fullName: fullName, username: username),
          ),
        ),
        feedNotifierProvider.overrideWith(
          (ref) => FeedNotifier(getFeedUseCase: mockGetFeedUseCase),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CreatePostScreen(
          postToEdit: postToEdit,
        ),
      ),
    );
  }

  testWidgets(
      'CreatePostScreen displays author, textfield, and enables Post button',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());

    // Verify initial layout
    expect(find.text('Create post'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Alice Smith'),
      ),
      findsOneWidget,
    );
    expect(find.text('Public'), findsOneWidget);
    expect(find.text("What's on your mind, Alice?"), findsOneWidget);
    expect(find.text('Add to your post'), findsOneWidget);

    // Initial state: Post button is present and disabled
    final postButtonFinder = find.widgetWithText(FilledButton, 'Post');
    expect(postButtonFinder, findsOneWidget);
    var button = tester.widget<FilledButton>(postButtonFinder);
    expect(button.onPressed, isNull);

    // Enter text
    await tester.enterText(
      find.byType(TextField).first,
      'Hello Lotus Connect!',
    );
    await tester.pump();

    // Now button should be enabled
    button = tester.widget<FilledButton>(postButtonFinder);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('CreatePostScreen submits post and pops on success',
      (tester) async {
    const createdPost = PostItem(
      id: 'p_101',
      author: PostAuthor(id: 'a_1', username: 'alice'),
      content: 'Hello Lotus Connect!',
    );

    when(() => mockCreatePostUseCase(any()))
        .thenAnswer((_) async => const Right(createdPost));

    await tester.pumpWidget(buildTestWidget());

    await tester.enterText(
      find.byType(TextField).first,
      'Hello Lotus Connect!',
    );
    await tester.pump();

    final postButtonFinder = find.widgetWithText(FilledButton, 'Post');
    await tester.tap(postButtonFinder);
    await tester.pump();

    verify(() => mockCreatePostUseCase(any())).called(1);
  });

  testWidgets('CreatePostScreen initializes in edit mode and submits update',
      (tester) async {
    const postToEdit = PostItem(
      id: 'p_200',
      author: PostAuthor(id: 'a_1', username: 'alice'),
      content: 'Original message',
    );
    const updatedPost = PostItem(
      id: 'p_200',
      author: PostAuthor(id: 'a_1', username: 'alice'),
      content: 'Updated message',
    );

    when(() => mockUpdatePostUseCase(any()))
        .thenAnswer((_) async => const Right(updatedPost));

    await tester.pumpWidget(
      buildTestWidget(postToEdit: postToEdit),
    );

    await tester.pumpAndSettle();

    // Verify Edit post title and prefilled content
    expect(find.text('Edit post'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Original message'), findsOneWidget);

    // Edit text
    await tester.enterText(
      find.byType(TextField).first,
      'Updated message',
    );
    await tester.pump();

    // Tap Save
    final saveButtonFinder = find.widgetWithText(FilledButton, 'Save');
    await tester.tap(saveButtonFinder);
    await tester.pump();

    verify(() => mockUpdatePostUseCase(any())).called(1);
  });

  testWidgets(
      'CreatePostScreen bottom toolbar renders without overflow on 390px',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildTestWidget(fullName: 'John Nguyen', username: 'john'),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add to your post'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('CreatePostScreen Localization', () {
    testWidgets('renders in English (en) correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create post'), findsOneWidget);
      expect(find.text('Post'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.text("What's on your mind, Alice?"), findsOneWidget);
      expect(find.text('Add to your post'), findsOneWidget);
      expect(find.byTooltip('Photo / Video'), findsOneWidget);
      expect(find.byTooltip('Camera'), findsOneWidget);
      expect(find.byTooltip('Feeling / Activity'), findsOneWidget);
      expect(find.byTooltip('Location'), findsOneWidget);
      expect(find.byTooltip('Background Color'), findsOneWidget);
    });

    testWidgets('renders in Vietnamese (vi) correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tạo bài viết'), findsOneWidget);
      expect(find.text('Đăng'), findsOneWidget);
      expect(find.text('Công khai'), findsOneWidget);
      expect(
        find.text('Alice ơi, bạn đang nghĩ gì thế?'),
        findsOneWidget,
      );
      expect(find.text('Thêm vào bài viết của bạn'), findsOneWidget);
      expect(find.byTooltip('Ảnh / Video'), findsOneWidget);
      expect(find.byTooltip('Máy ảnh'), findsOneWidget);
      expect(find.byTooltip('Cảm xúc / Hoạt động'), findsOneWidget);
      expect(find.byTooltip('Vị trí'), findsOneWidget);
      expect(find.byTooltip('Màu nền'), findsOneWidget);
    });

    testWidgets('renders in Japanese (ja) correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('ja')),
      );
      await tester.pumpAndSettle();

      expect(find.text('投稿を作成'), findsOneWidget);
      expect(find.text('投稿'), findsOneWidget);
      expect(find.text('公開'), findsOneWidget);
      expect(find.text('Aliceさん、今何してる？'), findsOneWidget);
      expect(find.text('投稿に追加'), findsOneWidget);
      expect(find.byTooltip('写真 / 動画'), findsOneWidget);
      expect(find.byTooltip('カメラ'), findsOneWidget);
      expect(find.byTooltip('気分 / アクティビティ'), findsOneWidget);
      expect(find.byTooltip('位置情報'), findsOneWidget);
      expect(find.byTooltip('背景色'), findsOneWidget);
    });

    testWidgets('renders in Chinese (zh) correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('zh')),
      );
      await tester.pumpAndSettle();

      expect(find.text('发布帖子'), findsOneWidget);
      expect(find.text('发布'), findsOneWidget);
      expect(find.text('公开'), findsOneWidget);
      expect(find.text('Alice，在想些什么呢？'), findsOneWidget);
      expect(find.text('添加到你的帖子'), findsOneWidget);
      expect(find.byTooltip('照片 / 视频'), findsOneWidget);
      expect(find.byTooltip('相机'), findsOneWidget);
      expect(find.byTooltip('感受 / 活动'), findsOneWidget);
      expect(find.byTooltip('位置'), findsOneWidget);
      expect(find.byTooltip('背景颜色'), findsOneWidget);
    });

    testWidgets('shows localized discard dialog when closing with content',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Bản nháp đang viết',
      );
      await tester.pump();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hủy bài viết?'), findsOneWidget);
      expect(
        find.text(
          'Nếu quay lại bây giờ, bản nháp bài viết và tệp đính kèm hiện '
          'tại sẽ bị mất.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tiếp tục chỉnh sửa'), findsOneWidget);
      expect(find.text('Hủy bỏ'), findsOneWidget);
    });

    testWidgets('renders edit mode in Japanese correctly', (tester) async {
      const postToEdit = PostItem(
        id: 'p_999',
        author: PostAuthor(id: 'a_1', username: 'alice'),
        content: '編集前の内容',
      );

      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ja'),
          postToEdit: postToEdit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('投稿を編集'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
      expect(find.text('編集前の内容'), findsOneWidget);
    });

    testWidgets('opens localized PostPrivacySheet from CreatePostScreen',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      // Tap privacy pill (currently 'Công khai')
      await tester.tap(find.text('Công khai'));
      await tester.pumpAndSettle();

      expect(find.text('Đối tượng xem bài viết'), findsOneWidget);
      expect(
        find.text(
          'Bất kỳ ai trên hoặc ngoài Lotus Connect đều có thể xem bài viết này',
        ),
        findsOneWidget,
      );
      expect(find.text('Bạn bè'), findsOneWidget);
      expect(
        find.text(
          'Chỉ những người trong danh sách bạn bè đã chấp nhận của bạn',
        ),
        findsOneWidget,
      );
      expect(find.text('Chỉ mình tôi'), findsOneWidget);
      expect(
        find.text(
          'Chỉ bạn mới có thể xem bài viết này trên dòng thời gian của mình',
        ),
        findsOneWidget,
      );
    });

    testWidgets('opens localized PostFeelingSheet from CreatePostScreen',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      // Tap feeling icon in bottom toolbar
      await tester.tap(find.byTooltip('Cảm xúc / Hoạt động'));
      await tester.pumpAndSettle();

      expect(find.text('Bạn đang cảm thấy thế nào?'), findsOneWidget);
      expect(find.text('Tìm kiếm cảm xúc...'), findsOneWidget);
    });

    testWidgets('opens localized PostLocationSheet from CreatePostScreen',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      // Tap location icon in bottom toolbar
      await tester.tap(find.byTooltip('Vị trí'));
      await tester.pumpAndSettle();

      expect(find.text('Thêm vị trí'), findsOneWidget);
      expect(find.text('Bạn đang ở đâu?'), findsOneWidget);
    });
  });
}
