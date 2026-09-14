import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class ToggleFavouriteConversationParam extends Equatable {
  const ToggleFavouriteConversationParam({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class ToggleFavouriteConversationUseCase
    implements UseCase<void, ToggleFavouriteConversationParam> {
  const ToggleFavouriteConversationUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(ToggleFavouriteConversationParam params) {
    return _repository.toggleFavouriteConversation(params.id);
  }
}
