import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class DeleteConversationParam extends Equatable {
  const DeleteConversationParam({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Use case to delete an existing conversation.
class DeleteConversationUseCase
    implements UseCase<void, DeleteConversationParam> {
  /// Constructor taking [ChatCoreRepository].
  const DeleteConversationUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(DeleteConversationParam params) {
    return _repository.deleteConversation(params.id);
  }
}
