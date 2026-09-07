import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements PrivateChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;
  late GetRemoteMessageUseCase useCase;

  setUp(() {
    mockChatRepository = MockChatRepository();
    useCase = GetRemoteMessageUseCase(repository: mockChatRepository);
  });

  const testConvId = '01a0332c-b962-7991-afab-f1a94ba71350';
  const testCurrentUserId = '01a0332c-14e9-7ba2-b033-15dade02062b';
  const testLimit = 25;
  const testCursor = 'cursor';

  final testMessages = [
    Message(
      id: '01a06cc7-b276-7ac3-8a39-1b01d69ccc13',
      conversationId: '01a0332c-b962-7991-afab-f1a94ba71350',
      role: MessageRole.user,
      content:
          'That kind of corporate myopia almost inevitably invites long-term obsolescence.',
      timestamp: DateTime.now(),
    ),
    Message(
      id: '01a075be-de0a-7900-91d8-b3448423195e',
      conversationId: '01a0332c-b962-7991-afab-f1a94ba71350',
      role: MessageRole.user,
      content: 'Hello friend',
      timestamp: DateTime.now(),
      medias: const [
        MediaModel(
          url: 'https://devblock.tech/uploads/image_1.png',
          thumbnailUrl: 'https://devblock.tech/uploads/thumbnail_1.png',
          mimeType: 'image/png',
        ),
        MediaModel(
          url: 'https://devblock.tech/uploads/video.mov',
          thumbnailUrl: 'https://devblock.tech/uploads/thumbnail_2.png',
          mimeType: 'video/quicktime',
        ),
      ],
    ),
  ];

  const testParams = GetRemoteMessageParam(
    conversationId: testConvId,
    userId: testCurrentUserId,
    cursor: testCursor,
  );

  group('GetRemoteMessageUseCase', () {
    test(
        'should return List<Message> when fetchRemoteMessages succeeds '
        'with cursor', () async {
      when(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          cursor: 'cursor',
          limit: 25,
        ),
      ).thenAnswer((_) async => Right(testMessages));

      final result = await useCase(testParams);

      expect(result, Right<Failure, List<Message>>(testMessages));
      verify(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          cursor: testCursor,
          limit: testLimit,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test('should forward null cursor and default limit (25) when not provided',
        () async {
      const defaultParams = GetRemoteMessageParam(
        conversationId: testConvId,
        userId: testCurrentUserId,
      );

      when(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          limit: 25,
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase(defaultParams);

      expect(result, const Right<Failure, List<Message>>([]));
      verify(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          limit: 25,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test(
        'should return ServerFailure when remote fetch fails with server error',
        () async {
      const serverFailure =
          ServerFailure('Failed to fetch message from server');

      when(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          cursor: testCursor,
          limit: testLimit,
        ),
      ).thenAnswer((_) async => const Left(serverFailure));

      final result = await useCase(testParams);

      expect(result, const Left<Failure, List<Message>>(serverFailure));
      verify(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          cursor: testCursor,
          limit: testLimit,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });

    test('should return NetworkFailure when device has no internet connection ',
        () async {
      const networkFailure = NetworkFailure('No internet connection');

      when(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          cursor: testCursor,
          limit: testLimit,
        ),
      ).thenAnswer((_) async => const Left(networkFailure));

      final result = await useCase(testParams);

      expect(result, const Left<Failure, List<Message>>(networkFailure));
      verify(
        () => mockChatRepository.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testCurrentUserId,
          cursor: testCursor,
          limit: testLimit,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });
  });

  group('GetRemoteMessageParam', () {
    test('should support value equality', () {
      const param1 = GetRemoteMessageParam(
        conversationId: testConvId,
        userId: testCurrentUserId,
      );
      const param2 = GetRemoteMessageParam(
        conversationId: testConvId,
        userId: testCurrentUserId,
      );
      const param3 = GetRemoteMessageParam(
        conversationId: 'different-conv',
        userId: testCurrentUserId,
      );

      expect(param1, equals(param2));
      expect(param1, isNot(equals(param3)));
    });

    test('props should contain conversationId and userid', () {
      expect(testParams.props, [testConvId, testCurrentUserId]);
    });

    test('default limit should be 25 and cursor should be null', () {
      const params = GetRemoteMessageParam(
        conversationId: testConvId,
        userId: testCurrentUserId,
      );

      expect(params.limit, 25);
      expect(params.cursor, isNull);
    });
  });
}
