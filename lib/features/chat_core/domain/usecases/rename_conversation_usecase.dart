import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

/// Params for rename conversation use case.
class RenameConversationParams {
  const RenameConversationParams({
    required this.conversationId,
    required this.newTitle,
  });

  final String conversationId;
  final String newTitle;
}

/// Use case to rename an existing conversation.
class RenameConversationUseCase
    implements UseCase<void, RenameConversationParams> {
  /// Constructor taking [ChatCoreRepository].
  const RenameConversationUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(RenameConversationParams params) {
    return _repository.renameConversation(
      params.conversationId,
      params.newTitle,
    );
  }
}
