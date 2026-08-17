import 'package:flutter/cupertino.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class PrivateChatRemoteDataSource {
  Future<Conversation> createPrivateChat(String friendId);
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
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
  }) async {
    try {
      final response = await _dioClient.post(
        'chats/$conversationId/messages',
        data: {
          'content': content,
          if (replyToId != null) 'replyToId': replyToId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final messageId = data['id'] as String? ?? '';
        final createdAtStr =
            (data['created_at'] ?? data['createdAt']) as String?;
        final timestamp = createdAtStr != null
            ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
            : DateTime.now();

        return Message(
          id: messageId,
          conversationId: conversationId,
          role: MessageRole.user,
          content: content,
          timestamp: timestamp,
          replyToId: replyToId,
        );
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
    int limit = 100,
  }) async {
    try {
      final response = await _dioClient.get(
        '/chats/$conversationId/messages',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      final data = response.data as List? ?? [];

      return data.map((item) {
        final id = item['id'] as String? ?? '';
        final senderId =
            (item['sender_id'] ?? item['senderId']) as String? ?? '';
        final content = item['content'] as String? ?? '';
        final createdAtStr =
            (item['created_at'] ?? item['createdAt']) as String?;
        final timestamp = createdAtStr != null
            ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
            : DateTime.now();
        final replyToId = (item['reply_to_id'] ?? item['replyToId']) as String?;

        debugPrint('remote message id: $id');
        debugPrint('remote message sender id: $senderId');
        debugPrint('remote message content: $content');
        debugPrint('remote message created at: $createdAtStr');
        debugPrint('remote message timestamp: $timestamp');
        debugPrint('remote message reply to id: $replyToId');
        debugPrint('---------------------------------------------');

        return Message(
          id: id,
          conversationId: conversationId,
          role: senderId == currentUserId
              ? MessageRole.user
              : MessageRole.assistant,
          content: content,
          timestamp: timestamp,
          replyToId: replyToId,
        );
      }).toList();
    } catch (e) {
      throw Exception(e);
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
}
