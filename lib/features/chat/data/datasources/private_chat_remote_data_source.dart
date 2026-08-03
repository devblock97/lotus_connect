import 'package:lotus_connect/core/services/api/chat_api_service.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class PrivateChatRemoteDataSource {
  Future<Map<String, dynamic>> createPrivateChat(String friendId);
  Future<Message> sendMessage({
    required String conversationId,
    required String content, });
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
      final createdAtStr = (data['createdAt'] ?? data['createdAt']) as String?;
      final timestamp = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

      return Message(
        id: messageId,
        conversationId: conversationId,
        role: MessageRole.user,
        content: content,
        timestamp: timestamp,
        status: MessageStatus.sent,
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}
