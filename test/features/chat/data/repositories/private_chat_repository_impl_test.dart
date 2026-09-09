import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/data/datasources/private_chat_local_data_source.dart';
import 'package:lotus_connect/features/chat/data/datasources/private_chat_remote_data_source.dart';
import 'package:lotus_connect/features/chat/data/models/file_upload_response_model.dart';
import 'package:lotus_connect/features/chat/data/repositories/private_chat_repository_impl.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:lotus_connect/features/chat/domain/entities/reaction_message_entity.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock
    implements PrivateChatRemoteDataSource {}

class MockChatLocalDataSource extends Mock
    implements PrivateChatLocalDataSource {}

void main() {
  late MockChatRemoteDataSource mockChatRemoteDataSource;
  late MockChatLocalDataSource mockChatLocalDataSource;
  late PrivateChatRepositoryImpl repository;

  setUp(() {
    mockChatRemoteDataSource = MockChatRemoteDataSource();
    mockChatLocalDataSource = MockChatLocalDataSource();
    repository = PrivateChatRepositoryImpl(
      remoteDataSource: mockChatRemoteDataSource,
      localDataSource: mockChatLocalDataSource,
    );
  });

  const testConvId = '01a0332c-b962-7991-afab-f1a94ba71350';
  const testTitle = 'Test conversation';
  const testUserId = '01a03314-af86-72f3-b270-d5642b05fbdc';
  const testMessageId = '01a075be-de0a-7900-91d8-b3448423195e';
  const testFriendId = '01a0332c-14e9-7ba2-b033-15dade02062b';
  const testContent = 'Hello friend';

  final testConversation = Conversation(
    id: testConvId,
    title: testTitle,
    createdAt: DateTime.parse('2026-08-24T16:27:56.697875Z'),
    updatedAt: DateTime.parse('2026-08-24T16:27:56.697875Z'),
    isUserToUser: true,
    peerId: testFriendId,
  );

  final testMessages = Message(
    id: testMessageId,
    conversationId: testConvId,
    role: MessageRole.user,
    content: testContent,
    timestamp: DateTime.now(),
  );

  const testMessageResponse = ResponseEntityBase(
    isSuccess: true,
    message: 'Message updated',
  );

  group('createPrivateChat', () {
    test('should return Right(Conversation) when createPrivateChat succeeds',
        () async {
      when(
        () => mockChatRemoteDataSource.createPrivateChat(testFriendId),
      ).thenAnswer((_) async => testConversation);

      when(
        () => mockChatLocalDataSource.saveLocalConversation(
          id: testConvId,
          title: testTitle,
          isUserToUser: true,
          peerId: testFriendId,
        ),
      ).thenAnswer((_) async => testConversation);

      final result = await repository.createPrivateChat(
        friendId: testFriendId,
        title: testTitle,
      );

      expect(result, Right<Failure, Conversation>(testConversation));
      verify(() => mockChatRemoteDataSource.createPrivateChat(testFriendId))
          .called(1);
      verify(
        () => mockChatLocalDataSource.saveLocalConversation(
          id: testConvId,
          title: testTitle,
          isUserToUser: true,
          peerId: testFriendId,
        ),
      ).called(1);
    });

    test(
        'should return Left(DatabaseFailure) when remote '
        'or local creation fails', () async {
      when(() => mockChatRemoteDataSource.createPrivateChat(testFriendId))
          .thenThrow(Exception('Network error'));

      final result = await repository.createPrivateChat(
        friendId: testFriendId,
        title: testTitle,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Should not be Right'),
      );
      verify(() => mockChatRemoteDataSource.createPrivateChat(testFriendId))
          .called(1);
      verifyNoMoreInteractions(mockChatLocalDataSource);
    });
  });

  group('fetchRemoteMessages', () {
    test('should return Right(List<Message>) when fetchRemoteMessages succeeds',
        () async {
      when(
        () => mockChatRemoteDataSource.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testUserId,
          limit: 25,
          cursor: 'cursor',
        ),
      ).thenAnswer((_) async => [testMessages]);

      final result = await repository.fetchRemoteMessages(
        conversationId: testConvId,
        currentUserId: testUserId,
        limit: 25,
        cursor: 'cursor',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (messages) => expect(messages, [testMessages]),
      );
      verify(
        () => mockChatRemoteDataSource.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testUserId,
          limit: 25,
          cursor: 'cursor',
        ),
      ).called(1);
    });

    test('should return Left(ServerFailure) when fetchRemoteMessage fails',
        () async {
      when(
        () => mockChatRemoteDataSource.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testUserId,
          limit: 25,
          cursor: 'cursor',
        ),
      ).thenThrow(Exception('Fetch failed'));

      final result = await repository.fetchRemoteMessages(
        conversationId: testConvId,
        currentUserId: testUserId,
        limit: 25,
        cursor: 'cursor',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be right'),
      );
    });
  });

  group('reactMessage', () {
    test('should return Right(ReactMessageEntity) when reaction succeeds',
        () async {
      final testReactionEntity = ReactionMessageEntity(
        messageId: testMessageId,
        userId: testUserId,
        reaction: '❤️',
        createdAt: DateTime.now(),
      );

      when(
        () => mockChatRemoteDataSource.reactMessage(testMessageId, '❤️'),
      ).thenAnswer((_) async => testReactionEntity);

      final result = await repository.reactMessage(testMessageId, '❤️');

      expect(
        result,
        Right<Failure, ReactionMessageEntity>(testReactionEntity),
      );
      verify(() => mockChatRemoteDataSource.reactMessage(testMessageId, '❤️'))
          .called(1);
    });

    test('should return Left(ServerFailure) when reaction fails', () async {
      when(() => mockChatRemoteDataSource.reactMessage(testMessageId, '❤️'))
          .thenThrow(Exception('React failed'));

      final result = await repository.reactMessage(testMessageId, '❤️');

      expect(
        result.isLeft(),
        isTrue,
      );
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be right'),
      );
    });
  });

  group('sendMessage', () {
    test('should return Right(Message) when sending message succeeds',
        () async {
      when(
        () => mockChatRemoteDataSource.sendMessage(
          conversationId: testConvId,
          content: testContent,
          messageType: 'text',
          mediaItems: const [],
        ),
      ).thenAnswer((_) async => testMessages);

      final result = await repository.sendMessage(
        conversationId: testConvId,
        content: testContent,
        messageType: 'text',
        mediaItems: const [],
      );

      expect(result, Right<Failure, Message>(testMessages));
      verify(
        () => mockChatRemoteDataSource.sendMessage(
          conversationId: testConvId,
          content: testContent,
          messageType: 'text',
          mediaItems: [],
        ),
      ).called(1);
    });

    test('should return Left(ServerFailure) when sending message fails',
        () async {
      when(
        () => mockChatRemoteDataSource.sendMessage(
          conversationId: testConvId,
          content: testContent,
          replyToId: any(named: 'replyToId'),
          thumbnailUrl: any(named: 'thumbnailUrl'),
          mediaUrl: any(named: 'mediaUrl'),
          messageType: any(named: 'messageType'),
          fileName: any(named: 'fileName'),
          mimeType: any(named: 'mimeType'),
          mediaItems: any(named: 'mediaItems'),
        ),
      ).thenThrow(Exception('Server error'));

      final result = await repository.sendMessage(
        conversationId: testConvId,
        content: testContent,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be Right'),
      );
    });
  });

  group('deleteMessage', () {
    test('should return Right(null) when deleteMessage succeeds', () async {
      when(
        () => mockChatRemoteDataSource.deleteMessage(testMessageId),
      ).thenAnswer((_) async => testMessageResponse);

      final result = await repository.deleteMessage(testMessageId);

      expect(
        result,
        const Right<Failure, ResponseEntityBase>(testMessageResponse),
      );
      verify(() => mockChatRemoteDataSource.deleteMessage(testMessageId))
          .called(1);
    });

    test('should return Left(ServerFailure) when deleteMessage fails',
        () async {
      when(
        () => mockChatRemoteDataSource.deleteMessage(testMessageId),
      ).thenThrow(Exception('Delete failed'));

      final result = await repository.deleteMessage(testMessageId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be right'),
      );
    });
  });

  group('updateMessage', () {
    test('should return Right(ResponseEntityBase) when updateMessage succeeds',
        () async {
      when(
        () =>
            mockChatRemoteDataSource.updateMessage(testMessageId, testContent),
      ).thenAnswer((_) async => testMessageResponse);

      final result = await repository.updateMessage(
        messageId: testMessageId,
        content: testContent,
      );

      expect(
        result,
        const Right<Failure, ResponseEntityBase>(testMessageResponse),
      );
      verify(
        () =>
            mockChatRemoteDataSource.updateMessage(testMessageId, testContent),
      ).called(1);
    });

    test('should return Left(ServerFailure) when updateMessage fails',
        () async {
      when(
        () =>
            mockChatRemoteDataSource.updateMessage(testMessageId, testContent),
      ).thenThrow(Exception('Failed to update message from server'));

      final result = await repository.updateMessage(
        messageId: testMessageId,
        content: testContent,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be right'),
      );
    });
  });

  group('uploadFiles', () {
    const testUploadResponse = FileUploadResponseModel(
      files: [
        MediaEntity(
          url: 'https://lotusconnect.com/file1.png',
          fileName: 'file1.png',
        ),
      ],
      fileUrls: ['https://lotusconnect.com/file1.png'],
    );

    test('should return Right(FileUploadResponseModel) when upload succeeds',
        () async {
      when(
        () =>
            mockChatRemoteDataSource.uploadFile(paths: ['/path/to/file1.png']),
      ).thenAnswer((_) async => testUploadResponse);

      final result = await repository.uploadFiles(['/path/to/file1.png']);

      expect(
        result,
        const Right<Failure, FileUploadResponseModel>(testUploadResponse),
      );
      verify(
        () =>
            mockChatRemoteDataSource.uploadFile(paths: ['/path/to/file1.png']),
      ).called(1);
    });

    test('should return Left(ServerFailure) when upload files fails', () async {
      when(
        () => mockChatRemoteDataSource.uploadFile(paths: ['/path/to/file.png']),
      ).thenThrow((_) async => Exception('Failed to upload files from server'));

      final result = await repository.uploadFiles(['/path/to/file.png']);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be Right'),
      );
    });
  });
}
