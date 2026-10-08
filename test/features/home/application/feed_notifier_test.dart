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

  setUp(() {
    mockGetFeedUseCase = MockGetFeedUseCase();
    mockDeletePostUseCase = MockDeletePostUseCase();
  });

  group('FeedNotifier', () {
    test('loads posts successfully on initialization', () async {
      when(() => mockGetFeedUseCase(const NoParams())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(getFeedUseCase: mockGetFeedUseCase);
      await pumpEventQueue();

      expect(notifier.state.posts.length, 1);
      expect(notifier.state.posts.first.id, 'post_1');
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('sets error message on failure', () async {
      when(() => mockGetFeedUseCase(const NoParams())).thenAnswer(
        (_) async => const Left(ServerFailure('Server down')),
      );

      final notifier = FeedNotifier(getFeedUseCase: mockGetFeedUseCase);
      await pumpEventQueue();

      expect(notifier.state.posts, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, 'Server down');
    });

    test('toggleLike updates like status and counter optimistically', () async {
      when(() => mockGetFeedUseCase(const NoParams())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(getFeedUseCase: mockGetFeedUseCase);
      await pumpEventQueue();

      notifier.toggleLike('post_1', isLiked: true);

      expect(notifier.state.posts.first.userHasLiked, isTrue);
      expect(notifier.state.posts.first.likeCount, 11);

      notifier.toggleLike('post_1', isLiked: false);

      expect(notifier.state.posts.first.userHasLiked, isFalse);
      expect(notifier.state.posts.first.likeCount, 10);
    });

    test('toggleSave updates bookmark status', () async {
      when(() => mockGetFeedUseCase(const NoParams())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(getFeedUseCase: mockGetFeedUseCase);
      await pumpEventQueue();

      notifier.toggleSave('post_1', isSaved: true);
      expect(notifier.state.posts.first.isSaved, isTrue);

      notifier.toggleSave('post_1', isSaved: false);
      expect(notifier.state.posts.first.isSaved, isFalse);
    });

    test('updatePost replaces updated post in state', () async {
      when(() => mockGetFeedUseCase(const NoParams())).thenAnswer(
        (_) async => const Right([testPost]),
      );

      final notifier = FeedNotifier(getFeedUseCase: mockGetFeedUseCase);
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
      when(() => mockGetFeedUseCase(const NoParams())).thenAnswer(
        (_) async => const Right([testPost]),
      );
      when(() => mockDeletePostUseCase(any()))
          .thenAnswer((_) async => const Right(true));

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        deletePostUseCase: mockDeletePostUseCase,
      );
      await pumpEventQueue();

      expect(notifier.state.posts.length, 1);

      final result = await notifier.deletePost('post_1');

      expect(result, isTrue);
      expect(notifier.state.posts, isEmpty);
      verify(() => mockDeletePostUseCase(any())).called(1);
    });

    test('deletePost retains post and sets errorMessage on failure', () async {
      when(() => mockGetFeedUseCase(const NoParams())).thenAnswer(
        (_) async => const Right([testPost]),
      );
      when(() => mockDeletePostUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to delete')),
      );

      final notifier = FeedNotifier(
        getFeedUseCase: mockGetFeedUseCase,
        deletePostUseCase: mockDeletePostUseCase,
      );
      await pumpEventQueue();

      final result = await notifier.deletePost('post_1');

      expect(result, isFalse);
      expect(notifier.state.posts.length, 1);
      expect(notifier.state.errorMessage, 'Failed to delete');
    });
  });
}
