import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Use case to delete a conversation.
class DeleteConversationUseCase implements UseCase<void, String> {
  /// Constructor taking [ChatbotRepository].
  const DeleteConversationUseCase(this._repository);

  final ChatbotRepository _repository;

  @override
  FutureResult<void> call(String conversationId) {
    return _repository.deleteConversation(conversationId);
  }
}
