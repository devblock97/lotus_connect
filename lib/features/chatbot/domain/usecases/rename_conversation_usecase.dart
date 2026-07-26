import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

class RenameConversationParams {
  const RenameConversationParams({
    required this.conversationId,
    required this.newTitle,
  });

  final String conversationId;
  final String newTitle;
}

class RenameConversationUseCase
    implements UseCase<void, RenameConversationParams> {
  /// Constructor taking [ChatbotRepository].
  const RenameConversationUseCase(this._repository);

  final ChatbotRepository _repository;

  @override
  FutureResult<void> call(RenameConversationParams params) {
    return _repository.renameConversation(
      params.conversationId,
      params.newTitle,
    );
  }
}
