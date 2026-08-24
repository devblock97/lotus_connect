import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class ChatCoreRepository {
  /// Watches all conversations reactively.
  StreamResult<List<Conversation>> watchConversations();

  /// Gets all conversations once.
  FutureResult<List<Conversation>> getConversations();

  /// Watches messages for a specific conversation reactively.
  StreamResult<List<Message>> watchMessages(String conversationId);

  /// Renames an existing conversation.
  FutureResult<void> renameConversation(
    String conversationId,
    String newTitle,
  );

  /// Deletes a conversation and associated messages.
  FutureResult<void> deleteConversation(String conversationId);

  /// Toggles pinned state for a conversation.
  FutureResult<void> togglePinConversation(String conversationId);

  /// Toggles favourite state for a conversation.
  FutureResult<void> toggleFavouriteConversation(String conversationId);

  /// Saves unsent draft message for a conversation.
  FutureResult<void> saveDraftMessage(String conversationId, String draft);

  /// Saves a message entity to local store.
  FutureResult<void> saveMessage(Message message);

  /// Creates a local conversation row inside SQLite database.
  FutureResult<Conversation> createLocalConversation({
    required String title,
    String? modelName,
    bool isUserToUser = false,
    String peerId = '',
    String? id,
  });

  FutureResult<void> deleteMessage(String id);

  FutureResult<List<Message>> getLocalMessages(String conversationId);

  FutureResult<Message?> getMessage(String messageId);
}
