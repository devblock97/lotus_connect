import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Parameters for creating a new conversation.
class CreateConversationParams {
  const CreateConversationParams({required this.title, this.modelName});

  final String title;
  final String? modelName;
}

/// Use case to create a new chat conversation.
class CreateConversationUseCase
    implements UseCase<Conversation, CreateConversationParams> {
  /// Constructor taking [ChatbotRepository].
  const CreateConversationUseCase(this._repository);

  final ChatbotRepository _repository;

  @override
  FutureResult<Conversation> call(CreateConversationParams params) {
    return _repository.createConversation(
      title: params.title,
      modelName: params.modelName,
    );
  }
}
