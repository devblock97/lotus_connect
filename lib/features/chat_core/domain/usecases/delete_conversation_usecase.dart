import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

/// Use case to delete an existing conversation.
class DeleteConversationUseCase implements UseCase<void, String> {
  /// Constructor taking [ChatCoreRepository].
  const DeleteConversationUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(String params) {
    return _repository.deleteConversation(params);
  }
}
