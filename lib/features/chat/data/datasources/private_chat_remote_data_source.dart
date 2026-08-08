import 'package:lotus_connect/core/services/api/chat_api_service.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class PrivateChatRemoteDataSource {
  Future<Map<String, dynamic>> createPrivateChat(String friendId);
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
  });
  Future<void> deleteMessage(String messageId);
  Future<void> updateMessage(String messageId, String content);
  Future<List<Message>> fetchRemoteMessages({
    required String conversationId,
    required String currentUserId,
  });
}

class PrivateChatRemoteDataSourceImpl implements PrivateChatRemoteDataSource {
  PrivateChatRemoteDataSourceImpl(this._apiService);

  final ChatApiService _apiService;

  @override
  Future<Map<String, dynamic>> createPrivateChat(String friendId) {
    return _apiService.createPrivateChat(friendId);
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final data = await _apiService.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      final messageId = data['id'] as String? ?? '';
      final createdAtStr = (data['created_at'] ?? data['createdAt']) as String?;
      final timestamp = createdAtStr != null
          ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
          : DateTime.now();

      return Message(
        id: messageId,
        conversationId: conversationId,
        role: MessageRole.user,
        content: content,
        timestamp: timestamp,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Message>> fetchRemoteMessages({
    required String conversationId,
    required String currentUserId,
  }) async {
    try {
      final list = await _apiService.getMessages(
        conversationId: conversationId,
        limit: 100,
      );
      return list.map((item) {
        final id = item['id'] as String? ?? '';
        final senderId =
            (item['sender_id'] ?? item['senderId']) as String? ?? '';
        final content = item['content'] as String? ?? '';
        final createdAtStr =
            (item['created_at'] ?? item['createdAt']) as String?;
        final timestamp = createdAtStr != null
            ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
            : DateTime.now();

        return Message(
          id: id,
          conversationId: conversationId,
          role: senderId == currentUserId
              ? MessageRole.user
              : MessageRole.assistant,
          content: content,
          timestamp: timestamp,
        );
      }).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiService.deleteMessage(messageId: messageId);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updateMessage(String messageId, String content) async {
    try {
      await _apiService.updateMessage(messageId: messageId, content: content);
    } catch (e) {
      throw Exception(e);
    }
  }
}
