import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/application/story_notifier.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:lotus_connect/features/home/presentation/view/home_screen.dart';
import 'package:lotus_connect/features/livestream/application/livestream_feed_notifier.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class _FakeFeedNotifier extends StateNotifier<FeedState>
    implements FeedNotifier {
  _FakeFeedNotifier([super.initialState = const FeedState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStoriesNotifier extends StateNotifier<StoriesState>
    implements StoriesNotifier {
  _FakeStoriesNotifier([super.initialState = const StoriesState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLiveStreamFeedNotifier extends StateNotifier<LiveStreamFeedState>
    implements LiveStreamFeedNotifier {
  _FakeLiveStreamFeedNotifier() : super(const LiveStreamFeedState());

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
    fullName: 'John Doe',
    username: 'johndoe',
  );

  Widget createHomeScreenWidget({
    Locale locale = const Locale('en'),
    List<PostItem> posts = const [],
    List<UserStory> stories = const [],
  }) {
    return ProviderScope(
      overrides: [
        settingsNotifierProvider.overrideWith(
          (_) => _FakeSettingsNotifier(testUser),
        ),
        feedNotifierProvider.overrideWith(
          (_) => _FakeFeedNotifier(
            FeedState(posts: posts),
          ),
        ),
        storiesNotifierProvider.overrideWith(
          (_) => _FakeStoriesNotifier(
            StoriesState(storyGroups: stories),
          ),
        ),
        liveStreamFeedProvider.overrideWith(
          (_) => _FakeLiveStreamFeedNotifier(),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen Localization Tests', () {
    testWidgets('renders English localized text by default', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createHomeScreenWidget());
      await tester.pumpAndSettle();

      // Tooltips in AppBar
      expect(find.byTooltip('Live streams'), findsOneWidget);
      expect(find.byTooltip('Create post'), findsOneWidget);
      expect(find.byTooltip('Chat'), findsOneWidget);

      // CreatePostBar in English
      expect(find.text("What's on your mind, John?"), findsOneWidget);
      expect(find.text('Photo'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Feeling'), findsOneWidget);

      // Empty posts state
      expect(find.text('No posts yet'), findsOneWidget);
    });

    testWidgets('renders Vietnamese localized text when locale is vi',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createHomeScreenWidget(locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      // Tooltips in AppBar
      expect(find.byTooltip('Phát trực tiếp'), findsOneWidget);
      expect(find.byTooltip('Tạo bài viết'), findsOneWidget);

      // CreatePostBar in Vietnamese
      expect(
        find.text('John ơi, bạn đang nghĩ gì thế?'),
        findsOneWidget,
      );
      expect(find.text('Ảnh'), findsOneWidget);
      expect(find.text('Máy ảnh'), findsOneWidget);
      expect(find.text('Cảm xúc'), findsOneWidget);

      // Empty posts state
      expect(find.text('Chưa có bài viết nào'), findsOneWidget);
    });

    testWidgets('renders Japanese localized text when locale is ja',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createHomeScreenWidget(locale: const Locale('ja')),
      );
      await tester.pumpAndSettle();

      // Tooltips in AppBar
      expect(find.byTooltip('ライブ配信'), findsOneWidget);
      expect(find.byTooltip('投稿を作成'), findsOneWidget);

      // CreatePostBar in Japanese
      expect(find.text('Johnさん、今何してる？'), findsOneWidget);
      expect(find.text('写真'), findsOneWidget);
      expect(find.text('カメラ'), findsOneWidget);
      expect(find.text('気分'), findsOneWidget);

      // Empty posts state
      expect(find.text('投稿はまだありません'), findsOneWidget);
    });

    testWidgets('renders Chinese localized text when locale is zh',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createHomeScreenWidget(locale: const Locale('zh')),
      );
      await tester.pumpAndSettle();

      // Tooltips in AppBar
      expect(find.byTooltip('直播'), findsOneWidget);
      expect(find.byTooltip('发布帖子'), findsOneWidget);

      // CreatePostBar in Chinese
      expect(find.text('John，在想些什么呢？'), findsOneWidget);
      expect(find.text('照片'), findsOneWidget);
      expect(find.text('相机'), findsOneWidget);
      expect(find.text('感受'), findsOneWidget);

      // Empty posts state
      expect(find.text('暂无帖子'), findsOneWidget);
    });

    testWidgets('renders localized stories tray and post card with likes',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const samplePost = PostItem(
        id: 'post_1',
        author: PostAuthor(id: 'author_1', username: 'alice'),
        content: 'Hello world from test!',
      );

      const sampleStory = UserStory(
        user: PostAuthor(id: 'user_1', username: 'johndoe'),
        isSelf: true,
      );

      await tester.pumpWidget(
        createHomeScreenWidget(
          locale: const Locale('vi'),
          posts: [samplePost],
          stories: [sampleStory],
        ),
      );
      await tester.pumpAndSettle();

      // Stories tray "Your story" in Vietnamese
      expect(find.text('Tin của bạn'), findsOneWidget);

      // PostCard "Be the first to like this" in Vietnamese
      expect(
        find.text('Hãy là người đầu tiên thích bài viết này'),
        findsOneWidget,
      );
    });

    testWidgets('opens PostOptionsSheet with localized strings in Vietnamese',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const samplePost = PostItem(
        id: 'post_1',
        author: PostAuthor(id: 'user_1', username: 'johndoe'),
        content: 'My author post',
      );

      await tester.pumpWidget(
        createHomeScreenWidget(
          locale: const Locale('vi'),
          posts: [samplePost],
        ),
      );
      await tester.pumpAndSettle();

      // Tap more options icon
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // PostOptionsSheet in Vietnamese
      expect(find.text('Tùy chọn bài viết'), findsOneWidget);
      expect(find.text('Chỉnh sửa bài viết'), findsOneWidget);
      expect(find.text('Xóa bài viết'), findsOneWidget);
      expect(find.text('Sao chép liên kết bài viết'), findsOneWidget);
    });
  });
}
