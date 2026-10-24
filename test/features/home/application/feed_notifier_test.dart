import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

class MockDeletePostUseCase extends Mock implements DeletePostUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const DeletePostParams('fallback'));
    registerFallbackValue(const GetFeedParam());
    registerFallbackValue(const NoParams());
  });

  late MockGetFeedUseCase mockGetFeedUseCase;
  late MockDeletePostUseCase mockDeletePostUseCase;

  const testPost = PostItem(
    id: 'post_1',
    author: PostAuthor(id: 'author_1', username: 'nnthong'),
    content: 'Exploring countryside',
    likeCount: 10,
    commentCount: 2,
  );

  const testPost2 = PostItem(
    id: 'post_2',
    author: PostAuthor(id: 'author_2', username: 'janedoe'),
    content: 'Second post in feed',
    likeCount: 5,
    commentCount: 1,
  );

  setUp(() {
    mockGetFeedUseCase = MockGetFeedUseCase();
    mockDeletePostUseCase = MockDeletePostUseCase();
  });

  group('FeedNotifier', () {
    test('loads posts successfully on initialization', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: Duration.zero,
      );
      await pumpEventQueue();

      expect(notifier.state.posts.length, 1);
      expect(notifier.state.posts.first.id, 'post_1');
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('sets error message on failure', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Server down')),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: Duration.zero,
      );
      await pumpEventQueue();

      expect(notifier.state.posts, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, 'Server down');
    });

    test('toggleLike updates like status and counter optimistically', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: Duration.zero,
      );
      await pumpEventQueue();

      notifier.toggleLike('post_1', isLiked: true);

      expect(notifier.state.posts.first.userHasLiked, isTrue);
      expect(notifier.state.posts.first.likeCount, 11);

      notifier.toggleLike('post_1', isLiked: false);

      expect(notifier.state.posts.first.userHasLiked, isFalse);
      expect(notifier.state.posts.first.likeCount, 10);
    });

    test('toggleSave updates bookmark status', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: Duration.zero,
      );
      await pumpEventQueue();

      notifier.toggleSave('post_1', isSaved: true);
      expect(notifier.state.posts.first.isSaved, isTrue);

      notifier.toggleSave('post_1', isSaved: false);
      expect(notifier.state.posts.first.isSaved, isFalse);
    });

    test('updatePost replaces updated post in state', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: Duration.zero,
      );
      await pumpEventQueue();

      const updated = PostItem(
        id: 'post_1',
        author: PostAuthor(id: 'author_1', username: 'nnthong'),
        content: 'New content after editing',
      );

      notifier.updatePost(updated);

      expect(notifier.state.posts.first.content, 'New content after editing');
    });

    test('deletePost removes post from state on success', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );
      when(() => mockDeletePostUseCase(any()))
          .thenAnswer((_) async => const Right(true));

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        deletePostUseCase: mockDeletePostUseCase,
        debounceDuration: Duration.zero,
      );
      await pumpEventQueue();

      expect(notifier.state.posts.length, 1);

      final result = await notifier.deletePost('post_1');

      expect(result, isTrue);
      expect(notifier.state.posts, isEmpty);
      verify(() => mockDeletePostUseCase(any())).called(1);
    });

    test('deletePost retains post and sets errorMessage on failure', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );
      when(() => mockDeletePostUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to delete')),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        deletePostUseCase: mockDeletePostUseCase,
        debounceDuration: Duration.zero,
      );
      await pumpEventQueue();

      final result = await notifier.deletePost('post_1');

      expect(result, isFalse);
      expect(notifier.state.posts.length, 1);
      expect(notifier.state.errorMessage, 'Failed to delete');
    });

    test(
      'loadMoreFeed debounces rapid calls and only triggers API once',
      () async {
        when(() => mockGetFeedUseCase(any())).thenAnswer(
          (_) async => const Right([testPost]),
        );

        final notifier = FeedNotifier(
          getFeedUseCase: mockGetFeedUseCase,
          debounceDuration: const Duration(milliseconds: 60),
        );
        await pumpEventQueue();

        // Initial load called once
        verify(() => mockGetFeedUseCase(any())).called(1);

        when(() => mockGetFeedUseCase(any())).thenAnswer(
          (_) async => const Right([testPost2]),
        );

        // Simulate rapid scroll triggers
        unawaited(notifier.loadMoreFeed());
        expect(notifier.isDebouncing, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 20));
        unawaited(notifier.loadMoreFeed()); // resets debounce timer

        await Future<void>.delayed(const Duration(milliseconds: 20));
        unawaited(notifier.loadMoreFeed()); // resets debounce timer again

        // 40ms since first call, only 20ms since last call -> no API yet
        verifyNever(
          () => mockGetFeedUseCase(
            const GetFeedParam(cursor: 'post_1', limit: 1),
          ),
        );

        // Await enough for the 60ms debounce duration to complete
        await Future<void>.delayed(const Duration(milliseconds: 80));

        // Now the API should have been called exactly once for loadMoreFeed
        verify(
          () => mockGetFeedUseCase(
            const GetFeedParam(cursor: 'post_1', limit: 1),
          ),
        ).called(1);
        expect(notifier.state.posts.length, 2);
        expect(notifier.state.posts.last.id, 'post_2');
        expect(notifier.isDebouncing, isFalse);
      },
    );

    test('loadMoreFeed executes immediately when immediate is true', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: const Duration(milliseconds: 100),
      );
      await pumpEventQueue();

      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost2]),
      );

      await notifier.loadMoreFeed(immediate: true);

      expect(notifier.state.posts.length, 2);
      expect(notifier.state.posts.last.id, 'post_2');
    });

    test('loadMoreFeed does not fetch if hasReachedMax is true', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right(<PostItem>[]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: const Duration(milliseconds: 40),
      );
      await pumpEventQueue();

      expect(notifier.state.hasReachedMax, isTrue);

      unawaited(notifier.loadMoreFeed());
      expect(notifier.isDebouncing, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      // Only the initial call was made
      verify(() => mockGetFeedUseCase(any())).called(1);
    });

    test('refreshFeed cancels pending debounce timer', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: const Duration(milliseconds: 60),
      );
      await pumpEventQueue();

      unawaited(notifier.loadMoreFeed());
      expect(notifier.isDebouncing, isTrue);

      await notifier.refreshFeed();
      expect(notifier.isDebouncing, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      // Verify loadMoreFeed was cancelled and only refresh was executed
      verifyNever(
        () => mockGetFeedUseCase(
          const GetFeedParam(cursor: 'post_1', limit: 1),
        ),
      );
    });

    test('dispose cancels active debounce timer', () async {
      when(() => mockGetFeedUseCase(any())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        debounceDuration: const Duration(milliseconds: 60),
      );
      await pumpEventQueue();

      unawaited(notifier.loadMoreFeed());
      expect(notifier.isDebouncing, isTrue);

      notifier.dispose();
      expect(notifier.isDebouncing, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      verifyNever(
        () => mockGetFeedUseCase(
          const GetFeedParam(cursor: 'post_1', limit: 1),
        ),
      );
    });
  });
}
