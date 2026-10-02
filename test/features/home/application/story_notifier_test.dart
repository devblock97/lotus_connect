import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/application/story_notifier.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_stories_tray_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/mark_story_viewed_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/react_to_story_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/reply_to_story_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGetStoriesTrayUseCase extends Mock implements GetStoriesTrayUseCase {}

class MockMarkStoryViewedUseCase extends Mock
    implements MarkStoryViewedUseCase {}

class MockReactToStoryUseCase extends Mock implements ReactToStoryUseCase {}

class MockReplyToStoryUseCase extends Mock implements ReplyToStoryUseCase {}

void main() {
  late MockGetStoriesTrayUseCase mockGetStoriesTrayUseCase;
  late MockMarkStoryViewedUseCase mockMarkStoryViewedUseCase;
  late MockReactToStoryUseCase mockReactToStoryUseCase;
  late MockReplyToStoryUseCase mockReplyToStoryUseCase;

  const testAuthor = PostAuthor(
    id: 'user_1',
    username: 'johnnguyen',
    fullName: 'John Nguyen',
  );

  final testStory = Story(
    id: 'story_1',
    author: testAuthor,
    mediaType: 'image',
    mediaUrl: 'https://example.com/story.jpg',
    createdAt: DateTime.now(),
    duration: 12,
  );

  final testUserStory = UserStory(
    user: testAuthor,
    stories: [testStory],
    hasUnseen: true,
    totalStories: 1,
  );

  setUpAll(() {
    registerFallbackValue(
      const ReactToStoryParams(storyId: 'fallback', reaction: '❤️'),
    );
    registerFallbackValue(
      const ReplyToStoryParams(storyId: 'fallback', message: 'hello'),
    );
  });

  setUp(() {
    mockGetStoriesTrayUseCase = MockGetStoriesTrayUseCase();
    mockMarkStoryViewedUseCase = MockMarkStoryViewedUseCase();
    mockReactToStoryUseCase = MockReactToStoryUseCase();
    mockReplyToStoryUseCase = MockReplyToStoryUseCase();
  });

  StoriesNotifier createNotifier() {
    return StoriesNotifier(
      getStoriesTrayUseCase: mockGetStoriesTrayUseCase,
      markStoryViewedUseCase: mockMarkStoryViewedUseCase,
      reactToStoryUseCase: mockReactToStoryUseCase,
      replyToStoryUseCase: mockReplyToStoryUseCase,
    );
  }

  group('StoriesNotifier', () {
    test('loads stories tray successfully on initialization', () async {
      when(() => mockGetStoriesTrayUseCase(const NoParams())).thenAnswer(
        (_) async => Right([testUserStory]),
      );

      final notifier = createNotifier();
      await pumpEventQueue();

      expect(notifier.state.storyGroups.length, 1);
      expect(notifier.state.storyGroups.first.user.username, 'johnnguyen');
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('sets error message on failure', () async {
      when(() => mockGetStoriesTrayUseCase(const NoParams())).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to load stories')),
      );

      final notifier = createNotifier();
      await pumpEventQueue();

      expect(notifier.state.storyGroups, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, 'Failed to load stories');
    });

    test(
        'markStoryViewed updates hasViewed and clears hasUnseen '
        'when all viewed', () async {
      when(() => mockGetStoriesTrayUseCase(const NoParams())).thenAnswer(
        (_) async => Right([testUserStory]),
      );
      when(() => mockMarkStoryViewedUseCase('story_1')).thenAnswer(
        (_) async => const Right(null),
      );

      final notifier = createNotifier();
      await pumpEventQueue();

      expect(notifier.state.storyGroups.first.hasUnseen, isTrue);

      await notifier.markStoryViewed('story_1', 'user_1');

      expect(notifier.state.storyGroups.first.hasUnseen, isFalse);
      expect(notifier.state.storyGroups.first.stories.first.hasViewed, isTrue);
      verify(() => mockMarkStoryViewedUseCase('story_1')).called(1);
    });

    test('reactToStory dispatches to ReactToStoryUseCase', () async {
      when(() => mockGetStoriesTrayUseCase(const NoParams())).thenAnswer(
        (_) async => Right([testUserStory]),
      );
      when(() => mockReactToStoryUseCase(any())).thenAnswer(
        (_) async => const Right(null),
      );

      final notifier = createNotifier();
      await pumpEventQueue();

      await notifier.reactToStory('story_1', '🔥');

      verify(
        () => mockReactToStoryUseCase(
          const ReactToStoryParams(storyId: 'story_1', reaction: '🔥'),
        ),
      ).called(1);
    });

    test('replyToStory dispatches to ReplyToStoryUseCase', () async {
      when(() => mockGetStoriesTrayUseCase(const NoParams())).thenAnswer(
        (_) async => Right([testUserStory]),
      );
      when(() => mockReplyToStoryUseCase(any())).thenAnswer(
        (_) async => const Right(null),
      );

      final notifier = createNotifier();
      await pumpEventQueue();

      await notifier.replyToStory('story_1', 'Great photo!');

      verify(
        () => mockReplyToStoryUseCase(
          const ReplyToStoryParams(
            storyId: 'story_1',
            message: 'Great photo!',
          ),
        ),
      ).called(1);
    });
  });
}
