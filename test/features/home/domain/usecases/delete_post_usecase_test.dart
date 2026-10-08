import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;
  late DeletePostUseCase useCase;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    useCase = DeletePostUseCase(repository: mockFeedRepository);
  });

  group('DeletePostUseCase', () {
    test('returns ValidationFailure when postId is empty', () async {
      const params = DeletePostParams('');
      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should fail when postId is empty'),
      );
      verifyZeroInteractions(mockFeedRepository);
    });

    test('deletes post successfully via repository', () async {
      const params = DeletePostParams('post_123');

      when(() => mockFeedRepository.deletePost('post_123')).thenAnswer(
        (_) async => const Right<Failure, bool>(true),
      );

      final result = await useCase(params);

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockFeedRepository.deletePost('post_123')).called(1);
    });

    test('returns failure when repository fails to delete post', () async {
      const params = DeletePostParams('post_123');

      when(() => mockFeedRepository.deletePost('post_123')).thenAnswer(
        (_) async => const Left(ServerFailure('Unauthorized')),
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return ServerFailure'),
      );
      verify(() => mockFeedRepository.deletePost('post_123')).called(1);
    });
  });
}
