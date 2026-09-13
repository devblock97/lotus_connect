import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/chat/data/datasources/private_chat_remote_data_source.dart';
import 'package:lotus_connect/features/chat/domain/entities/reaction_message_entity.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient dioClient;
  late PrivateChatRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(FormData());
  });

  setUp(() {
    dioClient = MockDioClient();
    dataSource = PrivateChatRemoteDataSourceImpl(dioClient);
  });

  const testFriendId = '01a03314-af86-72f3-b270-d5642b05fbdc';
  const testConvId = '01a0332c-b962-7991-afab-f1a94ba71350';
  const testTitle = 'Test title';
  const testUserId = '01a0332c-14e9-7ba2-b033-15dade02062b';

  const testConversation = {
    'id': '01a0332c-b962-7991-afab-f1a94ba71350',
    'title': 'Nguyen Nhu Thong',
    'isGroup': false,
    'peerId': '01a03314-af86-72f3-b270-d5642b05fbdc',
    'createdAt': '2026-08-24T09:49:24.194704Z',
    'updatedAt': '2026-09-11T13:30:07.193851Z',
  };

  const testContent = 'Check out this image!';
  const testMessageId = '01a070bf-e65b-7a41-89ab-a8b0934c309c';
  final testMessageWithoutMediaJson = {
    'id': testMessageId,
    'conversation_id': testConvId,
    'content': testContent,
    'sender_id': testFriendId,
    'created_at': '2026-09-12T10:05:00.000Z',
    'status': 'sent',
    'media_items': <Map<String, dynamic>>[],
  };

  const testMessage = {
    'id': testMessageId,
    'conversation_id': testConvId,
    'sender_id': testFriendId,
    'content': 'Check out this image!',
    'message_type': 'image',
    'reply_to_id': null,
    'media_url':
        'https://ef21-2001-ee0-26e-7703-64c2-be98-cc71-71d6.ngrok-free.app/uploads/01a070bb-7cbc-7100-b0d3-26be5c7e31c7-call.mov',
    'thumbnail_url':
        'https://ef21-2001-ee0-26e-7703-64c2-be98-cc71-71d6.ngrok-free.app/uploads/01a070bb-7cbc-7100-b0d3-26be5c7e31c7-call.mov',
    'file_name': 'call.mov',
    'file_size': 12667504,
    'mime_type': 'video/quicktime',
    'duration': null,
    'media_items': [
      {
        'url':
            'https://ef21-2001-ee0-26e-7703-64c2-be98-cc71-71d6.ngrok-free.app/uploads/01a070bb-7cbc-7100-b0d3-26be5c7e31c7-call.mov',
        'thumbnailUrl':
            'https://ef21-2001-ee0-26e-7703-64c2-be98-cc71-71d6.ngrok-free.app/uploads/01a070bb-7cbc-7100-b0d3-26be5c7e31c7-call.mov',
        'fileName': 'call.mov',
        'fileSize': 12667504,
        'mimeType': 'video/quicktime',
        'duration': null,
        'width': null,
        'height': null,
      },
      {
        'url':
            'https://ef21-2001-ee0-26e-7703-64c2-be98-cc71-71d6.ngrok-free.app/uploads/01a070bb-7ce8-7141-a19c-4edb32676caf-Simulator Screenshot - iPhone 17 - 2026-07-24 at 10.40.58.png',
        'thumbnailUrl': null,
        'fileName':
            'Simulator Screenshot - iPhone 17 - 2026-07-24 at 10.40.58.png',
        'fileSize': 217573,
        'mimeType': 'image/png',
        'duration': null,
        'width': null,
        'height': null,
      }
    ],
    'is_edited': false,
    'created_at': '2026-09-05T08:46:59.677078Z',
    'updated_at': '2026-09-05T08:46:59.677078Z',
    'reactions': null,
  };

  const testReactMessage = {
    'messageId': testMessageId,
    'userId': testUserId,
    'reaction': '❤️',
    'createdAt': '2026-08-25T14:50:02.365060Z',
  };

  group('createPrivateChat', () {
    test('should return Conversation when status code 200', () async {
      when(
        () => dioClient.post<dynamic>(
          '/chats/private',
          data: {'friendId': testFriendId},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/chats/private'),
          statusCode: 200,
          data: testConversation,
        ),
      );

      final result = await dataSource.createPrivateChat(testFriendId);

      expect(result, isA<Conversation>());
      expect(result.id, testConvId);
      expect(result.peerId, testFriendId);
      verify(
        () => dioClient.post<dynamic>(
          '/chats/private',
          data: {'friendId': testFriendId},
        ),
      ).called(1);
    });

    test('should throws ServerException when status code is not 200', () async {
      when(
        () => dioClient.post<dynamic>(
          '/chats/private',
          data: {'friendId': testFriendId},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/chats/private'),
          statusCode: 400,
          data: {'message': 'Bad request'},
        ),
      );

      expect(
        () => dataSource.createPrivateChat(testFriendId),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throws ServerException or NetworkException on network error',
        () async {
      when(
        () => dioClient.post<dynamic>(
          '/chats/private',
          data: {'friendId': testFriendId},
        ),
      ).thenThrow(const NetworkException('No internet'));

      expect(
        () => dataSource.createPrivateChat(testFriendId),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('sendMessage', () {
    test('should return Message when status code is 200', () async {
      when(
        () => dioClient.post<dynamic>(
          '/chats/$testConvId/messages',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: '/chats/$testConvId/messages',
          ),
          statusCode: 200,
          data: testMessageWithoutMediaJson,
        ),
      );

      final result = await dataSource.sendMessage(
        conversationId: testConvId,
        content: testContent,
      );

      expect(result, isA<Message>());
      expect(result.id, testMessageId);
      expect(result.content, testContent);
      verify(
        () => dioClient.post<dynamic>(
          '/chats/$testConvId/messages',
          data: any<dynamic>(named: 'data'),
        ),
      ).called(1);
    });

    test('should include optional fields and media item in request data',
        () async {
      const mediaItem = MediaModel(
        url: 'https://lotusconnect.com/uploads/thumbnail.png',
        fileName: 'thumbnail.png',
        fileSize: 1024,
        mimeType: 'image/png',
      );

      when(
        () => dioClient.post<dynamic>(
          '/chats/$testConvId/messages',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/chats/$testConvId/messages'),
          statusCode: 200,
          data: testMessageWithoutMediaJson,
        ),
      );

      await dataSource.sendMessage(
        conversationId: testConvId,
        content: testContent,
        replyToId: 'reply-1',
        thumbnailUrl: 'https://lotusconnect.com/uploads/thumbnail.png',
        mediaUrl: 'https://lotusconnect.com/uploads/image_1.png',
        messageType: 'image',
        mimeType: 'image/png',
        fileName: 'image_1.png',
        mediaItems: [mediaItem],
      );

      verifyNever(
        () => dioClient.post<dynamic>(
          '/chats/$testConvId/messages',
          data: {
            'content': testContent,
            'messageType': 'image',
            'replyToId': 'reply-1',
            'thumbnailUrl': 'https://lotusconnect.com/uploads/thumbnail.png',
            'mediaUrl': 'https://lotusconnect.com/uploads/image_1.png',
            'fileName': 'img.png',
            'mimeType': 'image/png',
            'mediaItems': [mediaItem.toJson()],
          },
        ),
      );
    });
  });

  group('reactionMessage', () {
    test('should return ReactMessageEntity when status code is 200', () async {
      when(
        () => dioClient.post<dynamic>(
          '/chats/messages/$testMessageId/reactions',
          data: {'reaction': '❤️'},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions:
              RequestOptions(path: '/chats/messages/$testMessageId/reactions'),
          statusCode: 200,
          data: testReactMessage,
        ),
      );

      final result = await dataSource.reactMessage(testMessageId, '❤️');

      expect(result, isA<ReactionMessageEntity>());
      expect(result.reaction, '❤️');
      expect(result.userId, testUserId);
      verify(
        () => dioClient.post<dynamic>(
          '/chats/messages/$testMessageId/reactions',
          data: {'reaction': '❤️'},
        ),
      ).called(1);
    });

    test('should throws Exception when reactMessage fails', () async {
      when(
        () => dioClient.post<dynamic>(
          '/chats/messages/$testMessageId/reactions',
          data: {'reaction': '❤️'},
        ),
      ).thenThrow(Exception('Reaction failed'));

      expect(
        () => dataSource.reactMessage(testMessageId, '❤️'),
        throwsA(isA<Exception>()),
      );
    });

    test('should return ServerException when status code is not 200', () async {
      when(
        () => dioClient.post<dynamic>(
          '/chats/messages/$testMessageId/reactions',
          data: {'reaction': '❤️'},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: '/chats/messages/$testMessageId/reactions',
          ),
          statusCode: 400,
          data: {'message': 'Bad request'},
        ),
      );

      expect(
        () => dataSource.reactMessage(testMessageId, '❤️'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getRemoteConversation', () {
    test('should return List<Conversation> when status code is 200', () async {
      when(
        () => dioClient.get<dynamic>('/chats'),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/chats'),
          statusCode: 200,
          data: [testConversation],
        ),
      );

      final result = await dataSource.getConversations();

      expect(result, isA<List<Conversation>>());
      expect(result.length, [testConversation].length);
      expect(result.first.id, testConvId);
      verify(
        () => dioClient.get<dynamic>('/chats'),
      ).called(1);
    });

    test('should return Exception when getConversation fails', () async {
      when(
        () => dioClient.get<dynamic>('/chats'),
      ).thenThrow((_) async => Exception('Failed to load conversation list'));

      expect(
        () => dataSource.getConversations(),
        throwsA(isA<Exception>()),
      );
    });

    test('should return ServerException when status code is not 200', () async {
      when(
        () => dioClient.get<dynamic>('/chats'),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 400,
          data: {'message': 'Bad request'},
        ),
      );

      expect(
        () => dataSource.getConversations(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fetchRemoteMessages', () {
    test('should return list of messages with appropriate roles', () async {
      final messagesData = [
        {
          'id': 'msg-1',
          'conversation_id': testConvId,
          'content': 'Hello from user',
          'sender_id': testUserId,
          'created_at': '2026-09-12T10:00:00.000Z',
          'media_items': <Map<String, dynamic>>[],
        },
        {
          'id': 'msg-2',
          'conversation_id': testConvId,
          'content': 'Hello from friend',
          'sender_id': testFriendId,
          'created_at': '2026-09-12T10:01:00.000Z',
          'media_items': <Map<String, dynamic>>[],
        },
      ];
      when(
        () => dioClient.get<dynamic>(
          '/chats/$testConvId/messages',
          queryParameters: {
            'cursor': 'cursor-token',
            'limit': 25,
          },
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/chats/$testConvId/messages'),
          statusCode: 200,
          data: messagesData,
        ),
      );
      final result = await dataSource.fetchRemoteMessages(
        conversationId: testConvId,
        currentUserId: testUserId,
        cursor: 'cursor-token',
      );
      expect(result, isA<List<Message>>());
      expect(result.length, equals(2));
      expect(result[0].id, equals('msg-1'));
      expect(result[0].role, equals(MessageRole.user));
      expect(result[1].id, equals('msg-2'));
      expect(result[1].role, equals(MessageRole.assistant));
    });
    test('should throw Exception when request fails', () async {
      when(
        () => dioClient.get<dynamic>(
          '/chats/$testConvId/messages',
          queryParameters: any<Map<String, dynamic>>(named: 'queryParameters'),
        ),
      ).thenThrow(Exception('Server error'));
      expect(
        () => dataSource.fetchRemoteMessages(
          conversationId: testConvId,
          currentUserId: testUserId,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteMessage', () {
    test('should return ResponseEntityBase when status code is 200', () async {
      const baseResponse = {
        'success': true,
        'message': 'Message deleted successfully',
      };

      when(
        () => dioClient.delete<dynamic>(
          '/chats/messages/$testMessageId',
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions:
              RequestOptions(path: '/chats/messages/$testMessageId'),
          statusCode: 200,
          data: baseResponse,
        ),
      );

      final result = await dataSource.deleteMessage(testMessageId);

      expect(result, isA<ResponseEntityBase>());
      expect(result.isSuccess, isTrue);
      expect(result.message, equals('Message deleted successfully'));
      verify(
        () => dioClient.delete<dynamic>('/chats/messages/$testMessageId'),
      ).called(1);
    });

    test('should return ServerException when deleteMessage fails', () async {
      when(
        () => dioClient.delete<dynamic>('/chats/messages/$testMessageId'),
      ).thenThrow(
        (_) async => Exception('Failed to delete message'),
      );

      expect(
        () => dataSource.deleteMessage(testMessageId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateMessage', () {
    test('should return ResponseEntityBase on success', () async {
      when(
        () => dioClient.put<dynamic>(
          '/chats/messages/$testMessageId',
          data: {'content': 'Updated text'},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: '/chats/messages/$testMessageId',
          ),
          statusCode: 200,
          data: {'success': true, 'message': 'Message updated successfully'},
        ),
      );
      final result = await dataSource.updateMessage(
        testMessageId,
        'Updated text',
      );
      expect(result, isA<ResponseEntityBase>());
      expect(result.isSuccess, isTrue);
      expect(result.message, equals('Message updated successfully'));
      verify(
        () => dioClient.put<dynamic>(
          '/chats/messages/$testMessageId',
          data: {'content': 'Updated text'},
        ),
      ).called(1);
    });
    test('should throw Exception when update fails', () async {
      when(
        () => dioClient.put<dynamic>(
          '/chats/messages/$testMessageId',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenThrow(Exception('Update error'));
      expect(
        () => dataSource.updateMessage(testMessageId, 'Updated text'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
