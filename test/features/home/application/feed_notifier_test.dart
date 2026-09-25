import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

void main() {
  late MockGetFeedUseCase mockGetFeedUseCase;

  const testPost = PostItem(
    id: 'post_1',
    author: PostAuthor(id: 'author_1', username: 'nnthong'),
    content: 'Exploring countryside',
    likeCount: 10,
    commentCount: 2,
  );

  setUp(() {
    mockGetFeedUseCase = MockGetFeedUseCase();
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
  });
}
