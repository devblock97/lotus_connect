import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';

class GetRemoteConversationUseCase
    implements UseCase<List<Conversation>, NoParams> {
  const GetRemoteConversationUseCase({
    required PrivateChatRepository privateChatRepository,
  }) : _repository = privateChatRepository;

  final PrivateChatRepository _repository;

  @override
  FutureResult<List<Conversation>> call(NoParams params) async {
    return _repository.getConversationList();
  }
}
