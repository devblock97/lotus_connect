import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/create_stream_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockLiveStreamRepository extends Mock implements LiveStreamRepository {}

void main() {
  late MockLiveStreamRepository mockRepository;
  late CreateStreamUseCase useCase;

  final sampleStream = LiveStream(
    id: '019fd810-74a0-7112-9840-001122334455',
    host: const PostAuthor(id: 'host-1', username: 'janedoe'),
    title: 'Morning Chill & Code',
    description: 'Come hang out and code!',
    createdAt: DateTime(2026, 10, 19, 10),
    updatedAt: DateTime(2026, 10, 19, 10),
  );

  setUp(() {
    mockRepository = MockLiveStreamRepository();
    useCase = CreateStreamUseCase(mockRepository);
  });

  group('CreateStreamUseCase', () {
    test('returns ValidationFailure when title is empty', () async {
      const params = CreateStreamParam(title: '');

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Stream title cannot be empty');
        },
        (_) => fail('Should return Left(ValidationFailure)'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('returns ValidationFailure when title is only whitespace', () async {
      const params = CreateStreamParam(title: '    ');

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Stream title cannot be empty');
        },
        (_) => fail('Should return Left(ValidationFailure)'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('creates stream successfully with trimmed values', () async {
      const params = CreateStreamParam(
        title: '  Morning Chill & Code  ',
        description: '  Come hang out and code!  ',
        thumbnailUrl: 'http://localhost:8080/uploads/thumb.jpg',
        privacy: 'public',
      );

      when(
        () => mockRepository.createStream(
          title: 'Morning Chill & Code',
          description: 'Come hang out and code!',
          thumbnailUrl: 'http://localhost:8080/uploads/thumb.jpg',
          privacy: 'public',
        ),
      ).thenAnswer((_) async => Right(sampleStream));

      final result = await useCase(params);

      expect(result, Right<Failure, LiveStream>(sampleStream));
      verify(
        () => mockRepository.createStream(
          title: 'Morning Chill & Code',
          description: 'Come hang out and code!',
          thumbnailUrl: 'http://localhost:8080/uploads/thumb.jpg',
          privacy: 'public',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('passes null description if description is whitespace only', () async {
      const params = CreateStreamParam(
        title: 'Live Chat',
        description: '   ',
      );

      when(
        () => mockRepository.createStream(
          title: 'Live Chat',
        ),
      ).thenAnswer((_) async => Right(sampleStream));

      final result = await useCase(params);

      expect(result, Right<Failure, LiveStream>(sampleStream));
      verify(
        () => mockRepository.createStream(
          title: 'Live Chat',
        ),
      ).called(1);
    });

    test('returns failure when repository fails', () async {
      const params = CreateStreamParam(title: 'Morning Chill & Code');
      const serverFailure = ServerFailure('Server unavailable');

      when(
        () => mockRepository.createStream(
          title: 'Morning Chill & Code',
        ),
      ).thenAnswer((_) async => const Left(serverFailure));

      final result = await useCase(params);

      expect(result, const Left<Failure, LiveStream>(serverFailure));
      verify(
        () => mockRepository.createStream(
          title: 'Morning Chill & Code',
        ),
      ).called(1);
    });
  });

  group('CreateStreamParam Equatable', () {
    test('props equality works correctly', () {
      const param1 = CreateStreamParam(title: 'Title', privacy: 'public');
      const param2 = CreateStreamParam(title: 'Title', privacy: 'public');
      const param3 = CreateStreamParam(title: 'Other', privacy: 'public');

      expect(param1, equals(param2));
      expect(param1 == param3, isFalse);
    });
  });
}
