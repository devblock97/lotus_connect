import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_post_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;
  late UpdatePostUseCase useCase;

  const samplePost = PostItem(
    id: 'post_100',
    author: PostAuthor(id: 'author_1', username: 'alex'),
    content: 'Updated content! 🏔️',
  );

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    useCase = UpdatePostUseCase(repository: mockFeedRepository);
  });

  group('UpdatePostUseCase', () {
    test('returns ValidationFailure when postId is empty', () async {
      const emptyParams = UpdatePostParams(
        postId: '',
        content: 'Some content',
      );
      final result = await useCase(emptyParams);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should fail when postId is empty'),
      );
      verifyZeroInteractions(mockFeedRepository);
    });

    test('returns ValidationFailure when post has no content and no media',
        () async {
      const emptyParams = UpdatePostParams(
        postId: 'post_100',
        content: '',
      );
      final result = await useCase(emptyParams);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should fail when post is completely empty'),
      );
      verifyZeroInteractions(mockFeedRepository);
    });

    test('updates text-only post successfully without uploading files',
        () async {
      const params = UpdatePostParams(
        postId: 'post_100',
        content: 'Updated content! 🏔️',
        visibility: 'friends',
      );

      when(
        () => mockFeedRepository.updatePost(
          postId: 'post_100',
          content: 'Updated content! 🏔️',
          visibility: 'friends',
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, PostItem>(samplePost),
      );

      final result = await useCase(params);

      expect(result, const Right<Failure, PostItem>(samplePost));
      verify(
        () => mockFeedRepository.updatePost(
          postId: 'post_100',
          content: 'Updated content! 🏔️',
          visibility: 'friends',
        ),
      ).called(1);
      verifyNever(() => mockFeedRepository.uploadFiles(any()));
    });

    test('uploads files and merges with existing media items', () async {
      const existingMedia = [
        PostMediaItem(url: 'http://localhost:8080/uploads/old.jpg'),
      ];
      const filePaths = ['/temp/new_photo.jpg'];
      const newlyUploaded = [
        PostMediaItem(url: 'http://localhost:8080/uploads/new.jpg'),
      ];

      const params = UpdatePostParams(
        postId: 'post_100',
        content: 'Updated with more photos',
        mediaItems: existingMedia,
        filePaths: filePaths,
        visibility: 'public',
      );

      when(() => mockFeedRepository.uploadFiles(filePaths)).thenAnswer(
        (_) async => const Right<Failure, List<PostMediaItem>>(newlyUploaded),
      );

      when(
        () => mockFeedRepository.updatePost(
          postId: 'post_100',
          content: 'Updated with more photos',
          mediaItems: [...existingMedia, ...newlyUploaded],
          visibility: 'public',
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, PostItem>(samplePost),
      );

      final result = await useCase(params);

      expect(result, const Right<Failure, PostItem>(samplePost));
      verify(() => mockFeedRepository.uploadFiles(filePaths)).called(1);
      verify(
        () => mockFeedRepository.updatePost(
          postId: 'post_100',
          content: 'Updated with more photos',
          mediaItems: [...existingMedia, ...newlyUploaded],
          visibility: 'public',
        ),
      ).called(1);
    });

    test('returns failure if uploadFiles fails during update', () async {
      const filePaths = ['/temp/corrupted.jpg'];
      const params = UpdatePostParams(
        postId: 'post_100',
        content: 'New content',
        filePaths: filePaths,
      );

      when(() => mockFeedRepository.uploadFiles(filePaths)).thenAnswer(
        (_) async => const Left(ServerFailure('Upload failed')),
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      verify(() => mockFeedRepository.uploadFiles(filePaths)).called(1);
      verifyNever(
        () => mockFeedRepository.updatePost(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
          mediaItems: any(named: 'mediaItems'),
          visibility: any(named: 'visibility'),
        ),
      );
    });
  });
}
