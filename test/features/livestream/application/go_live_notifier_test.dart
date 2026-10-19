import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/application/go_live_notifier.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/create_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/start_stream_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateStreamUseCase extends Mock implements CreateStreamUseCase {}

class MockStartStreamUseCase extends Mock implements StartStreamUseCase {}

void main() {
  late MockCreateStreamUseCase mockCreateStreamUseCase;
  late MockStartStreamUseCase mockStartStreamUseCase;
  late GoLiveNotifier notifier;

  setUpAll(() {
    registerFallbackValue(const StartStreamParam(streamId: 'stream-id'));
  });

  final sampleStream = LiveStream(
    id: 'stream-123',
    host: const PostAuthor(id: 'host-1', username: 'janedoe'),
    title: 'Test Live Stream',
    createdAt: DateTime(2026, 10, 19, 10),
    updatedAt: DateTime(2026, 10, 19, 10),
  );

  final liveStream = LiveStream(
    id: 'stream-123',
    host: const PostAuthor(id: 'host-1', username: 'janedoe'),
    title: 'Test Live Stream',
    status: 'live',
    createdAt: DateTime(2026, 10, 19, 10),
    updatedAt: DateTime(2026, 10, 19, 10),
  );

  setUp(() {
    mockCreateStreamUseCase = MockCreateStreamUseCase();
    mockStartStreamUseCase = MockStartStreamUseCase();
    notifier = GoLiveNotifier(
      createStreamUseCase: mockCreateStreamUseCase,
      startStreamUseCase: mockStartStreamUseCase,
    );
  });

  group('GoLiveNotifier', () {
    test('initial state has isLoading false and error null', () {
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('createStream succeeds and returns LiveStream', () async {
      when(
        () => mockCreateStreamUseCase(
          const CreateStreamParam(title: 'Test Live Stream'),
        ),
      ).thenAnswer((_) async => Right(sampleStream));

      final result = await notifier.createStream(title: 'Test Live Stream');

      expect(result, equals(sampleStream));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('createStream handles failure and sets error message', () async {
      when(
        () => mockCreateStreamUseCase(
          const CreateStreamParam(title: 'Fail Stream'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to create stream')),
      );

      final result = await notifier.createStream(title: 'Fail Stream');

      expect(result, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, equals('Failed to create stream'));
    });

    test('startStream succeeds and returns LiveStream', () async {
      when(
        () => mockStartStreamUseCase(
          const StartStreamParam(streamId: 'stream-123'),
        ),
      ).thenAnswer((_) async => Right(liveStream));

      final result = await notifier.startStream('stream-123');

      expect(result, equals(liveStream));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('goLive creates stream and then starts it', () async {
      when(
        () => mockCreateStreamUseCase(
          const CreateStreamParam(title: 'Test Live Stream'),
        ),
      ).thenAnswer((_) async => Right(sampleStream));

      when(
        () => mockStartStreamUseCase(
          const StartStreamParam(streamId: 'stream-123'),
        ),
      ).thenAnswer((_) async => Right(liveStream));

      final result = await notifier.goLive(title: 'Test Live Stream');

      expect(result, equals(liveStream));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
      verify(
        () => mockCreateStreamUseCase(
          const CreateStreamParam(title: 'Test Live Stream'),
        ),
      ).called(1);
      verify(
        () => mockStartStreamUseCase(
          const StartStreamParam(streamId: 'stream-123'),
        ),
      ).called(1);
    });

    test('goLive does not start stream if creation fails', () async {
      when(
        () => mockCreateStreamUseCase(
          const CreateStreamParam(title: 'Fail Stream'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Creation failed')));

      final result = await notifier.goLive(title: 'Fail Stream');

      expect(result, isNull);
      expect(notifier.state.error, equals('Creation failed'));
      verifyNever(() => mockStartStreamUseCase(any()));
    });

    test('does not throw Bad state if disposed', () async {
      when(
        () => mockCreateStreamUseCase(
          const CreateStreamParam(title: 'Disposed Stream'),
        ),
      ).thenAnswer((_) async {
        notifier.dispose();
        return Right(sampleStream);
      });

      final result = await notifier.createStream(title: 'Disposed Stream');

      expect(result, isNull);
    });
  });
}
