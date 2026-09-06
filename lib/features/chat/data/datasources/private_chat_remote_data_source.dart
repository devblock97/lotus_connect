import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/chat/data/models/file_upload_response_model.dart';
import 'package:lotus_connect/features/chat/data/models/reaction_message_model.dart';
import 'package:lotus_connect/features/chat/domain/entities/reaction_message_entity.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class PrivateChatRemoteDataSource {
  Future<Conversation> createPrivateChat(String friendId);

  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
    String? thumbnailUrl,
    String? mediaUrl,
    String? messageType,
    String? mimeType,
    String? fileName,
    List<MediaModel> mediaItems,
  });

  Future<void> deleteMessage(String messageId);

  Future<void> updateMessage(String messageId, String content);

  Future<List<Message>> fetchRemoteMessages({
    required String conversationId,
    required String currentUserId,
    String? cursor,
    int limit = 100,
  });

  Future<List<Conversation>> getConversations();

  Future<ReactionMessageEntity> reactMessage(String messageId, String reaction);

  Future<FileUploadResponseModel> uploadFile({required List<String> paths});
}

class PrivateChatRemoteDataSourceImpl implements PrivateChatRemoteDataSource {
  PrivateChatRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Conversation> createPrivateChat(String friendId) async {
    try {
      final response = await _dioClient.post(
        '/chats/private',
        data: {'friendId': friendId},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final conversation = Conversation.fromJson(data);
        return conversation;
      }
      throw const ServerException('Create chat failed. Please try again!');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to register: $e');
    }
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
    String? thumbnailUrl,
    String? mediaUrl,
    String? messageType,
    String? mimeType,
    String? fileName,
    List<MediaModel>? mediaItems,
  }) async {
    try {
      final response = await _dioClient.post(
        'chats/$conversationId/messages',
        data: {
          'content': content,
          if (messageType != null) 'messageType': messageType,
          if (replyToId != null) 'replyToId': replyToId,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          if (fileName != null) 'fileName': fileName,
          if (mimeType != null) 'mimeType': mimeType,
          'mediaItems': mediaItems
                  ?.map(
                    (m) => m.toJson(),
                  )
                  .toList() ??
              [],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final message = Message.fromJson(
          data,
          MessageRole.user,
        );
        return message;
      }

      throw const ServerException('Send message failed. Please try again!');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Message>> fetchRemoteMessages({
    required String conversationId,
    required String currentUserId,
    String? cursor,
    int limit = 25,
  }) async {
    try {
      debugPrint('fetch remote messages cursor: $cursor; limit: $limit');
      final response = await _dioClient.get(
        '/chats/$conversationId/messages',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      final data = response.data as List? ?? [];

      return data.map((item) {
        final jsonMap = item as Map<String, dynamic>;
        debugPrint('media message: ${jsonMap['media_items']}');
        final senderId =
            (jsonMap['sender_id'] ?? jsonMap['senderId']) as String? ?? '';
        final role = senderId == currentUserId
            ? MessageRole.user
            : MessageRole.assistant;

        return Message.fromJson(jsonMap, role);
      }).toList();
    } catch (e) {
      throw Exception('PrivateChatRemoteDataSource error: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dioClient.delete(
        '/chats/messages/$messageId',
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updateMessage(String messageId, String content) async {
    try {
      await _dioClient.put(
        '/chats/messages/$messageId',
        data: {
          'content': content,
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dioClient.get('/chats');
      final list = response.data as List;
      return list.map((c) {
        final id = c['id'] as String;
        final title = c['title'] as String;
        final isGroup = c['isGroup'] as bool;
        final peerId = c['peerId'] as String;
        final createdAt = DateTime.parse(c['createdAt'] as String);
        final conversation = Conversation(
          id: id,
          title: title,
          peerId: peerId,
          createdAt: createdAt,
          updatedAt: createdAt,
        );
        return conversation;
      }).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<ReactionMessageEntity> reactMessage(
    String messageId,
    String reaction,
  ) async {
    try {
      final response = await _dioClient.post(
        '/chats/messages/$messageId/reactions',
        data: {'reaction': reaction},
      );
      final data = ReactionMessageModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return data.toEntity();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<FileUploadResponseModel> uploadFile({
    required List<String> paths,
  }) async {
    try {
      final files = await Future.wait(
        paths.map((path) async {
          final fileName = path.split('/').last;
          return MultipartFile.fromFile(path, filename: fileName);
        }),
      );

      final formData = FormData.fromMap({
        'files': files,
      });

      final response = await _dioClient.post(
        '/uploads/multiple',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data as Map<String, dynamic>;
      return FileUploadResponseModel.fromJson(data);
    } catch (e) {
      throw ServerException('Failed to upload file: $e');
    }
  }
}
