import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class TogglePinConversationParam extends Equatable {
  const TogglePinConversationParam({required this.id});
  final String id;
  @override
  List<Object?> get props => [id];
}

class TogglePinConversationUseCase
    implements UseCase<void, TogglePinConversationParam> {
  /// Constructor taking [ChatCoreRepository].
  const TogglePinConversationUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(TogglePinConversationParam params) {
    return _repository.togglePinConversation(params.id);
  }
}
