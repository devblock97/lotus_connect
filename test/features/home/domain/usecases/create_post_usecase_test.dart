import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/domain/entities/create_post_params.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_post_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;
  late CreatePostUseCase useCase;

  const samplePost = PostItem(
    id: 'post_100',
    author: PostAuthor(id: 'author_1', username: 'alex'),
    content: 'Exploring mountains! 🏔️',
  );

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    useCase = CreatePostUseCase(repository: mockFeedRepository);
  });

  group('CreatePostUseCase', () {
    test('returns ValidationFailure when params has no content or media',
        () async {
      const emptyParams = CreatePostParams();
      final result = await useCase(emptyParams);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should fail on empty post'),
      );
      verifyZeroInteractions(mockFeedRepository);
    });

    test('creates text-only post successfully without uploading files',
        () async {
      const params = CreatePostParams(
        content: 'Exploring mountains! 🏔️',
      );

      when(
        () => mockFeedRepository.createPost(
          content: 'Exploring mountains! 🏔️',
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, PostItem>(samplePost),
      );

      final result = await useCase(params);

      expect(result, const Right<Failure, PostItem>(samplePost));
      verify(
        () => mockFeedRepository.createPost(
          content: 'Exploring mountains! 🏔️',
        ),
      ).called(1);
      verifyNever(() => mockFeedRepository.uploadFiles(any()));
    });

    test('uploads files first and then creates post with uploaded media',
        () async {
      const filePaths = ['/temp/photo1.jpg'];
      const uploadedMedia = [
        PostMediaItem(url: 'http://localhost:8080/uploads/photo1.jpg'),
      ];

      const params = CreatePostParams(
        content: 'Photo post',
        filePaths: filePaths,
        visibility: 'friends',
      );

      when(() => mockFeedRepository.uploadFiles(filePaths)).thenAnswer(
        (_) async => const Right<Failure, List<PostMediaItem>>(uploadedMedia),
      );

      when(
        () => mockFeedRepository.createPost(
          content: 'Photo post',
          mediaItems: uploadedMedia,
          visibility: 'friends',
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, PostItem>(samplePost),
      );

      final result = await useCase(params);

      expect(result, const Right<Failure, PostItem>(samplePost));
      verify(() => mockFeedRepository.uploadFiles(filePaths)).called(1);
      verify(
        () => mockFeedRepository.createPost(
          content: 'Photo post',
          mediaItems: uploadedMedia,
          visibility: 'friends',
        ),
      ).called(1);
    });

    test('returns failure if uploadFiles fails', () async {
      const filePaths = ['/temp/fail.jpg'];
      const params = CreatePostParams(
        content: 'Test fail',
        filePaths: filePaths,
      );

      when(() => mockFeedRepository.uploadFiles(filePaths)).thenAnswer(
        (_) async => const Left<Failure, List<PostMediaItem>>(
          ServerFailure('Upload failed'),
        ),
      );

      final result = await useCase(params);

      expect(
        result,
        const Left<Failure, PostItem>(ServerFailure('Upload failed')),
      );
      verifyNever(
        () => mockFeedRepository.createPost(
          content: any(named: 'content'),
          mediaItems: any(named: 'mediaItems'),
          visibility: any(named: 'visibility'),
        ),
      );
    });
  });
}
