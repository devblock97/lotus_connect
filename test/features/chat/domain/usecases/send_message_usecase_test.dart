import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements PrivateChatRepository {}

void main() {
  late MockChatRepository mockChatRepo;
  late SendMessageUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatRepository();
    useCase = SendMessageUseCase(privateChatRepository: mockChatRepo);
  });

  const testConvId = '01a0332c-b962-7991-afab-f1a94ba71350';
  const testMessageId = '01a075be-de0a-7900-91d8-b3448423195e';
  const testContent = 'Hello friend :)';

  final testTextMessage = Message(
    id: testMessageId,
    conversationId: testConvId,
    role: MessageRole.user,
    content: testContent,
    timestamp: DateTime.parse('2026-09-07T12:00:00.000Z'),
  );
  final testMediaItems = [
    const MediaModel(
      url: 'https://lotusconnect.com/uploads/image_1.png',
      thumbnailUrl: 'https://lotusconnect.com/uploads/thumbnail_1.png',
      mimeType: 'image/png',
      fileName: 'image_1.png',
    ),
    const MediaModel(
      url: 'https://lotusconnect.com/uploads/video_1.mov',
      thumbnailUrl: 'https://lotusconnect.com/uploads/video_thumb.png',
      mimeType: 'video/quicktime',
      fileName: 'video_1.mov',
    ),
  ];
  final testMediaMessage = Message(
    id: testMessageId,
    conversationId: testConvId,
    role: MessageRole.user,
    content: testContent,
    timestamp: DateTime.parse('2026-09-07T12:00:00.000Z'),
    messageType: 'image',
    medias: testMediaItems,
  );

  group('SendMessageUseCase', () {
    test('should return Message when send message success without media',
        () async {
      const params = SendMessageParams(
        conversationId: testConvId,
        text: testContent,
        messageType: 'text',
      );

      when(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          messageType: 'text',
          mediaItems: [],
        ),
      ).thenAnswer((_) async => Right(testTextMessage));

      final result = await useCase(params);

      expect(result, Right<Failure, Message>(testTextMessage));
      verify(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          messageType: 'text',
          mediaItems: [],
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test(
        'should return Message when sending message '
        'with media attachments succeeds', () async {
      final params = SendMessageParams(
        conversationId: testConvId,
        text: testContent,
        messageType: 'image',
        mediaUrl: 'https://lotusconnect.com/uploads/image_1.png',
        thumbnailUrl: 'https://lotusconnect.com/uploads/thumbnail_1.png',
        fileName: 'image_1.png',
        mimeType: 'image/png',
        mediaItems: testMediaItems,
      );

      when(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          thumbnailUrl: 'https://lotusconnect.com/uploads/thumbnail_1.png',
          mediaUrl: 'https://lotusconnect.com/uploads/image_1.png',
          fileName: 'image_1.png',
          messageType: 'image',
          mimeType: 'image/png',
          mediaItems: testMediaItems,
        ),
      ).thenAnswer((_) async => Right(testMediaMessage));

      final result = await useCase(params);

      expect(result, Right<Failure, Message>(testMediaMessage));
      verify(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          thumbnailUrl: 'https://lotusconnect.com/uploads/thumbnail_1.png',
          mediaUrl: 'https://lotusconnect.com/uploads/image_1.png',
          fileName: 'image_1.png',
          messageType: 'image',
          mimeType: 'image/png',
          mediaItems: testMediaItems,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should forward replyToId when replying to another message', () async {
      const testReplyToId = '01a06cc7-b276-7ac3-8a39-1b01d69ccc13';
      const params = SendMessageParams(
        conversationId: testConvId,
        text: testContent,
        replyToId: testReplyToId,
      );

      final testReplyMessage = Message(
        id: testMessageId,
        conversationId: testReplyToId,
        role: MessageRole.user,
        content: testContent,
        timestamp: DateTime.now(),
      );

      when(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          replyToId: testReplyToId,
          mediaItems: const [],
        ),
      ).thenAnswer((_) async => Right(testReplyMessage));

      final result = await useCase(params);

      expect(result, Right<Failure, Message>(testReplyMessage));
      verify(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          replyToId: testReplyToId,
          mediaItems: const [],
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return ServerFailure when remote repository fails', () async {
      const serverFailure = ServerFailure('Failed to send message over server');
      const params = SendMessageParams(
        conversationId: testConvId,
        text: testContent,
      );

      when(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          mediaItems: const [],
        ),
      ).thenAnswer((_) async => const Left(serverFailure));

      final result = await useCase(params);

      expect(result, const Left<Failure, Message>(serverFailure));
      verify(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          mediaItems: const [],
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return NetworkFailure when offline', () async {
      const networkFailure = NetworkFailure('No internet connection');
      const params = SendMessageParams(
        conversationId: testConvId,
        text: testContent,
      );

      when(
        () => mockChatRepo.sendMessage(
          conversationId: any(named: 'conversationId'),
          content: any(named: 'content'),
          replyToId: any(named: 'replyToId'),
          thumbnailUrl: any(named: 'thumbnailUrl'),
          mediaUrl: any(named: 'mediaUrl'),
          fileName: any(named: 'fileName'),
          messageType: any(named: 'messageType'),
          mimeType: any(named: 'mimeType'),
          mediaItems: any(named: 'mediaItems'),
        ),
      ).thenAnswer((_) async => const Left(networkFailure));

      final result = await useCase(params);

      expect(result, const Left<Failure, Message>(networkFailure));
      verify(
        () => mockChatRepo.sendMessage(
          conversationId: testConvId,
          content: testContent,
          mediaItems: const [],
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });
  });
}
