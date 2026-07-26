import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Use case to toggle pinned status of a conversation.
class TogglePinConversationUseCase implements UseCase<void, String> {
  /// Constructor taking [ChatbotRepository].
  const TogglePinConversationUseCase(this._repository);

  final ChatbotRepository _repository;

  @override
  FutureResult<void> call(String conversationId) {
    return _repository.togglePinConversation(conversationId);
  }
}
