import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Use case to fetch or stream conversation history list.
class GetConversationsUseCase
    implements StreamUseCase<List<Conversation>, NoParams> {
  /// Constructor taking [ChatbotRepository].
  const GetConversationsUseCase(this._repository);

  final ChatbotRepository _repository;

  @override
  StreamResult<List<Conversation>> call(NoParams params) {
    return _repository.watchConversations();
  }
}
