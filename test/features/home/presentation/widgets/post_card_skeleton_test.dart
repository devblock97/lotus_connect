import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/story_notifier.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card_skeleton.dart';
import 'package:lotus_connect/features/home/presentation/widgets/stories_tray.dart';

class _FakeStoriesNotifier extends StateNotifier<StoriesState>
    implements StoriesNotifier {
  _FakeStoriesNotifier() : super(const StoriesState());

  @override
  Future<void> loadStories() async {}

  @override
  Future<void> refreshStories() async {}

  @override
  Future<void> markStoryViewed(String storyId, String userId) async {}

  @override
  Future<void> reactToStory(String storyId, String reaction) async {}

  @override
  Future<void> replyToStory(String storyId, String message) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PostCardSkeleton Widget Tests', () {
    testWidgets('renders all skeleton placeholder sections inside Shimmer',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shimmer(
              child: SingleChildScrollView(
                child: PostCardSkeleton(),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PostCardSkeleton), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(ShimmerBox), findsWidgets);
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('SliverPostListSkeleton renders inside CustomScrollView',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storiesNotifierProvider.overrideWith(
              (ref) => _FakeStoriesNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverPostListSkeleton(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SliverPostListSkeleton), findsOneWidget);
      expect(find.byType(PostCardSkeleton), findsNWidgets(3));
    });

    testWidgets('PostListSkeleton renders stories tray and post skeletons',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storiesNotifierProvider.overrideWith(
              (ref) => _FakeStoriesNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PostListSkeleton(itemCount: 2),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(StoriesTray), findsOneWidget);
      expect(find.byType(PostCardSkeleton), findsNWidgets(2));
    });
  });
}
