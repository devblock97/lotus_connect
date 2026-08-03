import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';

class CreatePrivateChatParams {
  const CreatePrivateChatParams({
    required this.friendId,
    required this.title,
  });

  final String friendId;
  final String title;
}

class CreatePrivateChatUseCase
    implements UseCase<Conversation, CreatePrivateChatParams> {
  const CreatePrivateChatUseCase(this._repository);

  final PrivateChatRepository _repository;

  @override
  FutureResult<Conversation> call(CreatePrivateChatParams params) {
    return _repository.createPrivateChat(
      friendId: params.friendId,
      title: params.title,
    );
  }
}
