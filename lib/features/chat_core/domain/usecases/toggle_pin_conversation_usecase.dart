import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

/// Use case to toggle pinned state for a conversation.
class TogglePinConversationUseCase implements UseCase<void, String> {
  /// Constructor taking [ChatCoreRepository].
  const TogglePinConversationUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(String params) {
    return _repository.togglePinConversation(params);
  }
}
