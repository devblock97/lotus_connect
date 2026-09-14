import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';

class CreateConversationParams {
  const CreateConversationParams({
    required this.friendId,
    required this.title,
  });

  final String friendId;
  final String title;
}

class CreateConversationUseCase
    implements UseCase<Conversation, CreateConversationParams> {
  const CreateConversationUseCase(this._repository);

  final ChatRepository _repository;

  @override
  FutureResult<Conversation> call(CreateConversationParams params) {
    return _repository.createConversation(
      friendId: params.friendId,
      title: params.title,
    );
  }
}
