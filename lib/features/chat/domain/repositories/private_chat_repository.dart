import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class PrivateChatRepository {
  /// Calls remote REST endpoint to create private chat conversation,
  /// and saves it locally inside Drift SQLite.
  FutureResult<Conversation> createPrivateChat({
    required String friendId,
    required String title,
  });

  FutureResult<Message> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) =>
      throw UnimplementedError('Stub');

  FutureResult<void> deleteMessage(String messageId);

  FutureResult<void> updateMessage({
    required String messageId,
    required String content,
  }) =>
      throw UnimplementedError('Stub');

  FutureResult<List<Message>> fetchRemoteMessages({
    required String conversationId,
    required String currentUserId,
  });

  FutureResult<List<Conversation>> getConversationList();
}
