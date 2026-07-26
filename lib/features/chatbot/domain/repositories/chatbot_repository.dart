import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/message.dart';

abstract class ChatbotRepository {
  /// Watches all conversations reactively.
  StreamResult<List<Conversation>> watchConversations();

  /// Gets all conversations once.
  FutureResult<List<Conversation>> getConversations();

  /// Watches messages for a specific conversation reactively.
  StreamResult<List<Message>> watchMessages(String conversationId);

  /// Creates a new conversation.
  FutureResult<Conversation> createConversation({
    required String title,
    String? modelName,
  });

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

  /// Streams AI response chunks token by token.
  StreamResult<String> streamAiResponse({
    required String conversationId,
    required String prompt,
    required String model,
    required List<Message> history,
  });

  /// Cancels in-flight AI response generation.
  FutureResult<void> cancelAiGeneration();

  /// Retrieves user application settings.
  FutureResult<AppSettings> getSettings();

  /// Updates user application settings.
  FutureResult<void> updateSettings(AppSettings settings);
}
