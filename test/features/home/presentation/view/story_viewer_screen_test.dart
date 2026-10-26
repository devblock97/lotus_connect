import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/story_notifier.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:lotus_connect/features/home/presentation/view/story_viewer_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class _FakeStoriesNotifier extends StateNotifier<StoriesState>
    implements StoriesNotifier {
  _FakeStoriesNotifier([super.state = const StoriesState()]);

  String? lastReactedStoryId;
  String? lastReactedReaction;
  String? lastRepliedStoryId;
  String? lastRepliedMessage;

  @override
  Future<void> markStoryViewed(String storyId, String userId) async {}

  @override
  Future<void> reactToStory(String storyId, String reaction) async {
    lastReactedStoryId = storyId;
    lastReactedReaction = reaction;
  }

  @override
  Future<void> replyToStory(String storyId, String message) async {
    lastRepliedStoryId = storyId;
    lastRepliedMessage = message;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const author = PostAuthor(
    id: 'u_100',
    username: 'alex',
    fullName: 'Alex Vance',
  );

  final sampleStory = Story(
    id: 's_100',
    author: author,
    mediaType: 'image',
    mediaUrl: 'https://example.com/story.png',
    createdAt: DateTime.now(),
    visibility: 'close_friends',
  );

  final sampleUserStory = UserStory(
    user: author,
    stories: [sampleStory],
    hasUnseen: true,
    totalStories: 1,
  );

  late _FakeStoriesNotifier fakeStoriesNotifier;

  setUp(() {
    fakeStoriesNotifier = _FakeStoriesNotifier();
  });

  Widget buildTestWidget({
    Locale locale = const Locale('en'),
    List<UserStory>? storyGroups,
  }) {
    return ProviderScope(
      overrides: [
        storiesNotifierProvider.overrideWith((_) => fakeStoriesNotifier),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StoryViewerScreen(
          storyGroups: storyGroups ?? [sampleUserStory],
        ),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('StoryViewerScreen Localization Tests', () {
    testWidgets('renders in English (en) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('alex'), findsOneWidget);
      expect(find.text('Just now'), findsOneWidget);
      expect(find.text('Close Friends'), findsOneWidget);
      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.text('Send message...'), findsOneWidget);
      expect(find.byTooltip('Like'), findsOneWidget);
    });

    testWidgets('renders in Vietnamese (vi) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pump();

      expect(find.text('alex'), findsOneWidget);
      expect(find.text('Vừa xong'), findsOneWidget);
      expect(find.text('Bạn thân'), findsOneWidget);
      expect(find.byTooltip('Đóng'), findsOneWidget);
      expect(find.text('Gửi tin nhắn...'), findsOneWidget);
      expect(find.byTooltip('Thích'), findsOneWidget);
    });

    testWidgets('renders in Japanese (ja) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('ja')),
      );
      await tester.pump();

      expect(find.text('alex'), findsOneWidget);
      expect(find.text('たった今'), findsOneWidget);
      expect(find.text('親しい友達'), findsOneWidget);
      expect(find.byTooltip('閉じる'), findsOneWidget);
      expect(find.text('メッセージを送信...'), findsOneWidget);
      expect(find.byTooltip('いいね！'), findsOneWidget);
    });

    testWidgets('renders in Chinese (zh) correctly', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('zh')),
      );
      await tester.pump();

      expect(find.text('alex'), findsOneWidget);
      expect(find.text('刚刚'), findsOneWidget);
      expect(find.text('密友'), findsOneWidget);
      expect(find.byTooltip('关闭'), findsOneWidget);
      expect(find.text('发送消息...'), findsOneWidget);
      expect(find.byTooltip('赞'), findsOneWidget);
    });

    testWidgets('sends reply and shows localized snackbar in Vietnamese',
        (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pump();

      // Enter text into reply field
      await tester.enterText(find.byType(TextField), 'Xin chao!');
      await tester.pump();

      // Send button with localized tooltip
      expect(find.byTooltip('Gửi'), findsOneWidget);
      await tester.tap(find.byTooltip('Gửi'));
      await tester.pump();

      expect(fakeStoriesNotifier.lastRepliedStoryId, equals('s_100'));
      expect(fakeStoriesNotifier.lastRepliedMessage, equals('Xin chao!'));
      expect(find.text('Đã gửi tin nhắn!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('sends heart reaction when tapping reaction button',
        (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        buildTestWidget(locale: const Locale('vi')),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Thích'));
      await tester.pump();

      expect(fakeStoriesNotifier.lastReactedStoryId, equals('s_100'));
      expect(fakeStoriesNotifier.lastReactedReaction, equals('❤️'));

      await tester.pump(const Duration(milliseconds: 1300));
    });
  });
}
