import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class ChatbotRepository {
  /// Creates a new conversation.
  FutureResult<Conversation> createConversation({
    required String title,
    String? modelName,
  });

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
