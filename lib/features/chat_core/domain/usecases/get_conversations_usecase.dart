import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

/// Use case to fetch or stream conversation history list.
class GetConversationsUseCase
    implements StreamUseCase<List<Conversation>, NoParams> {
  /// Constructor taking [ChatCoreRepository].
  const GetConversationsUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  StreamResult<List<Conversation>> call(NoParams params) {
    return _repository.watchConversations();
  }
}
