import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

/// Use case to toggle favourite state for a conversation.
class ToggleFavouriteConversationUseCase implements UseCase<void, String> {
  /// Constructor taking [ChatCoreRepository].
  const ToggleFavouriteConversationUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(String params) {
    return _repository.toggleFavouriteConversation(params);
  }
}
