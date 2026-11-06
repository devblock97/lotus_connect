import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chill/chill_data.dart';
import 'package:lotus_connect/features/chill/chill_domain.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:mocktail/mocktail.dart';

class MockChillRemoteDataSource extends Mock implements ChillRemoteDataSource {}

void main() {
  late MockChillRemoteDataSource mockRemoteDataSource;
  late ChillRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockChillRemoteDataSource();
    repository = ChillRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final testChill = ChillItem(
    id: 'chill_1',
    author: const PostAuthor(id: 'author_1', username: 'user1'),
    videoUrl: 'http://localhost/video1.mp4',
    createdAt: DateTime.now(),
    caption: 'Test Chill Reel',
  );

  group('ChillRepositoryImpl Tests', () {
    test(
        'getChillFeed returns Right(List<ChillItem>) on success with optional tag',
        () async {
      when(
        () => mockRemoteDataSource.getChillFeed(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          tag: any(named: 'tag'),
        ),
      ).thenAnswer((_) async => [testChill]);

      final result = await repository.getChillFeed(tag: 'travel');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (items) {
          expect(items.length, 1);
          expect(items.first.id, 'chill_1');
        },
      );
      verify(() => mockRemoteDataSource.getChillFeed(tag: 'travel')).called(1);
    });

    test('getChillFeed returns Left(ServerFailure) on ServerException',
        () async {
      when(
        () => mockRemoteDataSource.getChillFeed(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          tag: any(named: 'tag'),
        ),
      ).thenThrow(const ServerException('Server offline'));

      final result = await repository.getChillFeed();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Server offline'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('toggleLikeChill calls remoteDataSource and returns success',
        () async {
      when(
        () => mockRemoteDataSource.toggleLikeChill(
          'chill_1',
          isLiked: true,
          reaction: 'like',
        ),
      ).thenAnswer((_) async => true);

      final result = await repository.toggleLikeChill(
        'chill_1',
        isLiked: true,
        reaction: 'like',
      );

      expect(result, const Right<Failure, bool>(true));
      verify(
        () => mockRemoteDataSource.toggleLikeChill(
          'chill_1',
          isLiked: true,
          reaction: 'like',
        ),
      ).called(1);
    });

    // test('recordChillView returns Right(ChillViewResult) on success', () async {
    //   const viewResult = ChillViewResult(
    //     postId: 'chill_1',
    //     viewCount: 150,
    //     watchTimeSeconds: 12.5,
    //     isCompleted: true,
    //   );
    //
    //   when(() => mockRemoteDataSource.recordChillView(any()))
    //       .thenAnswer((_) async => viewResult);
    //
    //   final result = await repository.recordChillView(
    //     const RecordChillViewParams(
    //       chillId: 'chill_1',
    //       watchTimeSeconds: 12.5,
    //       isCompleted: true,
    //     ),
    //   );
    //
    //   expect(result.isRight(), isTrue);
    //   result.fold(
    //     (failure) => fail('Expected Right'),
    //     (data) {
    //       expect(data.postId, 'chill_1');
    //       expect(data.viewCount, 150);
    //       expect(data.isCompleted, isTrue);
    //     },
    //   );
    // });

    test('shareChill returns updated ChillItem on success', () async {
      final updatedChill =
          testChill.copyWith(shareCount: testChill.shareCount + 1);

      when(() => mockRemoteDataSource.shareChill('chill_1'))
          .thenAnswer((_) async => updatedChill);

      final result = await repository.shareChill('chill_1');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (data) {
          expect(data.shareCount, 1);
        },
      );
    });
  });
}
