import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/application/comment_notifier.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comment_by_id_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comment_replies_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/pin_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/react_to_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_comment_usecase.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCommentsUseCase extends Mock implements GetCommentsUseCase {}

class MockCreateCommentUseCase extends Mock implements CreateCommentUseCase {}

class MockGetCommentByIdUseCase extends Mock implements GetCommentByIdUseCase {}

class MockGetCommentRepliesUseCase extends Mock
    implements GetCommentRepliesUseCase {}

class MockUpdateCommentUseCase extends Mock implements UpdateCommentUseCase {}

class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}

class MockReactToCommentUseCase extends Mock implements ReactToCommentUseCase {}

class MockPinCommentUseCase extends Mock implements PinCommentUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const GetCommentsParams(postId: 'fallback'),
    );
  });

  late MockGetCommentsUseCase mockGetCommentsUseCase;
  late MockCreateCommentUseCase mockCreateCommentUseCase;
  late MockGetCommentByIdUseCase mockGetCommentByIdUseCase;
  late MockGetCommentRepliesUseCase mockGetCommentRepliesUseCase;
  late MockUpdateCommentUseCase mockUpdateCommentUseCase;
  late MockDeleteCommentUseCase mockDeleteCommentUseCase;
  late MockReactToCommentUseCase mockReactToCommentUseCase;
  late MockPinCommentUseCase mockPinCommentUseCase;

  const testAuthor = PostAuthor(id: 'author_1', username: 'nnthong');

  List<CommentModel> buildCommentModels(int start, int count) {
    return List.generate(
      count,
      (i) => CommentModel(
        id: 'comment_${start + i}',
        postId: 'post_1',
        author: testAuthor,
        content: 'Comment content ${start + i}',
        likeCount: 100 - (start + i),
        createdAt: DateTime(2026, 10, 29, 7, start + i),
      ),
    );
  }

  CommentNotifier createNotifier({
    String? postId = 'post_1',
    Duration debounceDuration = Duration.zero,
  }) {
    return CommentNotifier(
      postId: postId,
      getCommentsUseCase: mockGetCommentsUseCase,
      createCommentUseCase: mockCreateCommentUseCase,
      getCommentByIdUseCase: mockGetCommentByIdUseCase,
      getCommentRepliesUseCase: mockGetCommentRepliesUseCase,
      updateCommentUseCase: mockUpdateCommentUseCase,
      deleteCommentUseCase: mockDeleteCommentUseCase,
      reactToCommentUseCase: mockReactToCommentUseCase,
      pinCommentUseCase: mockPinCommentUseCase,
      debounceDuration: debounceDuration,
    );
  }

  setUp(() {
    mockGetCommentsUseCase = MockGetCommentsUseCase();
    mockCreateCommentUseCase = MockCreateCommentUseCase();
    mockGetCommentByIdUseCase = MockGetCommentByIdUseCase();
    mockGetCommentRepliesUseCase = MockGetCommentRepliesUseCase();
    mockUpdateCommentUseCase = MockUpdateCommentUseCase();
    mockDeleteCommentUseCase = MockDeleteCommentUseCase();
    mockReactToCommentUseCase = MockReactToCommentUseCase();
    mockPinCommentUseCase = MockPinCommentUseCase();
  });

  group('CommentNotifier cursor pagination', () {
    test(
      'loadComments sets cursor to last comment id and hasReachedMax false when full page (10 items) returned',
      () async {
        final firstPage = buildCommentModels(1, 10);
        when(() => mockGetCommentsUseCase(any())).thenAnswer(
          (_) async => Right(firstPage),
        );

        final notifier = createNotifier();
        await notifier.loadComments(postId: 'post_1');

        expect(notifier.state.status, CommentStatus.success);
        expect(notifier.state.comments.length, 10);
        expect(notifier.state.cursor, 'comment_10');
        expect(notifier.state.hasReachedMax, isFalse);
        expect(notifier.state.isInitialized, isTrue);
      },
    );

    test(
      'loadComments handles empty list without throwing StateError',
      () async {
        when(() => mockGetCommentsUseCase(any())).thenAnswer(
          (_) async => const Right([]),
        );

        final notifier = createNotifier();
        await notifier.loadComments(postId: 'post_1');

        expect(notifier.state.status, CommentStatus.success);
        expect(notifier.state.comments, isEmpty);
        expect(notifier.state.cursor, isNull);
        expect(notifier.state.hasReachedMax, isTrue);
      },
    );

    test(
      'loadMoreComment passes current cursor and appends next page of comments',
      () async {
        final firstPage = buildCommentModels(1, 10);
        final secondPage = buildCommentModels(11, 3);

        when(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).thenAnswer((_) async => Right(firstPage));

        when(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              cursor: 'comment_10',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).thenAnswer((_) async => Right(secondPage));

        final notifier = createNotifier();
        await notifier.loadComments(postId: 'post_1');

        expect(notifier.state.cursor, 'comment_10');
        expect(notifier.state.hasReachedMax, isFalse);

        await notifier.loadMoreComment(
          sort: CommentSortOrder.popular,
        );

        verify(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              cursor: 'comment_10',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).called(1);

        expect(notifier.state.comments.length, 13);
        expect(notifier.state.cursor, 'comment_13');
        expect(notifier.state.hasReachedMax, isTrue);
        expect(notifier.state.status, CommentStatus.success);
      },
    );

    test(
      'loadMoreComment debounces rapid calls and only triggers API once',
      () async {
        final firstPage = buildCommentModels(1, 10);
        final secondPage = buildCommentModels(11, 3);

        when(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).thenAnswer((_) async => Right(firstPage));

        when(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              cursor: 'comment_10',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).thenAnswer((_) async => Right(secondPage));

        final notifier = createNotifier(
          debounceDuration: const Duration(milliseconds: 60),
        );
        await notifier.loadComments(postId: 'post_1');

        unawaited(notifier.loadMoreComment());
        expect(notifier.isDebouncing, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 20));
        unawaited(notifier.loadMoreComment());

        await Future<void>.delayed(const Duration(milliseconds: 20));
        unawaited(notifier.loadMoreComment());

        verifyNever(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              cursor: 'comment_10',
              sort: 'popular',
              limit: 10,
            ),
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 80));

        verify(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              cursor: 'comment_10',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).called(1);
        expect(notifier.state.comments.length, 13);
        expect(notifier.isDebouncing, isFalse);
      },
    );

    test('loadMoreComment does not fetch when hasReachedMax is true', () async {
      final shortPage = buildCommentModels(1, 3);
      when(() => mockGetCommentsUseCase(any())).thenAnswer(
        (_) async => Right(shortPage),
      );

      final notifier = createNotifier();
      await notifier.loadComments(postId: 'post_1');

      expect(notifier.state.hasReachedMax, isTrue);

      await notifier.loadMoreComment();

      verify(() => mockGetCommentsUseCase(any())).called(1);
    });

    test(
      'loadMoreComment sets failure state when usecase returns Left',
      () async {
        final firstPage = buildCommentModels(1, 10);
        when(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).thenAnswer((_) async => Right(firstPage));

        when(
          () => mockGetCommentsUseCase(
            const GetCommentsParams(
              postId: 'post_1',
              cursor: 'comment_10',
              sort: 'popular',
              limit: 10,
            ),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to fetch next page')),
        );

        final notifier = createNotifier();
        await notifier.loadComments(postId: 'post_1');
        await notifier.loadMoreComment();

        expect(notifier.state.status, CommentStatus.failure);
        expect(notifier.state.errorMessage, 'Failed to fetch next page');
        expect(notifier.state.comments.length, 10);
      },
    );
  });
}
