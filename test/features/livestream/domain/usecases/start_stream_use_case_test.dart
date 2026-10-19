import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/start_stream_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockLiveStreamRepository extends Mock implements LiveStreamRepository {}

void main() {
  late MockLiveStreamRepository mockRepository;
  late StartStreamUseCase useCase;

  final sampleStream = LiveStream(
    id: '019fd810-74a0-7112-9840-001122334455',
    host: const PostAuthor(id: 'host-1', username: 'janedoe'),
    title: 'Morning Chill & Code',
    status: 'live',
    createdAt: DateTime(2026, 10, 19, 10),
    updatedAt: DateTime(2026, 10, 19, 10),
  );

  setUp(() {
    mockRepository = MockLiveStreamRepository();
    useCase = StartStreamUseCase(mockRepository);
  });

  group('StartStreamUseCase', () {
    test('returns ValidationFailure when streamId is empty', () async {
      const params = StartStreamParam(streamId: '');

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Stream ID cannot be empty');
        },
        (_) => fail('Should return Left(ValidationFailure)'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test(
      'returns ValidationFailure when streamId is only whitespace',
      () async {
        const params = StartStreamParam(streamId: '   ');

        final result = await useCase(params);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, 'Stream ID cannot be empty');
          },
          (_) => fail('Should return Left(ValidationFailure)'),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test('starts stream successfully with trimmed streamId', () async {
      const streamId = '019fd810-74a0-7112-9840-001122334455';
      const params = StartStreamParam(streamId: '  $streamId  ');

      when(
        () => mockRepository.startStream(streamId),
      ).thenAnswer((_) async => Right(sampleStream));

      final result = await useCase(params);

      expect(result, Right<Failure, LiveStream>(sampleStream));
      verify(() => mockRepository.startStream(streamId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns failure when repository fails', () async {
      const streamId = '019fd810-74a0-7112-9840-001122334455';
      const params = StartStreamParam(streamId: streamId);
      const serverFailure =
          ServerFailure('Stream already started or not found');

      when(
        () => mockRepository.startStream(streamId),
      ).thenAnswer((_) async => const Left(serverFailure));

      final result = await useCase(params);

      expect(result, const Left<Failure, LiveStream>(serverFailure));
      verify(() => mockRepository.startStream(streamId)).called(1);
    });
  });

  group('StartStreamParam Equatable', () {
    test('props equality works correctly', () {
      const param1 = StartStreamParam(streamId: 'stream-1');
      const param2 = StartStreamParam(streamId: 'stream-1');
      const param3 = StartStreamParam(streamId: 'stream-2');

      expect(param1, equals(param2));
      expect(param1 == param3, isFalse);
    });
  });
}
