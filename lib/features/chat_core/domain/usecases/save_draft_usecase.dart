import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

/// Params for saving conversation draft input text.
class SaveDraftMessageParams {
  const SaveDraftMessageParams({
    required this.conversationId,
    required this.draft,
  });

  final String conversationId;
  final String draft;
}

/// Use case to save unsubmitted draft text inputs.
class SaveDraftMessageUseCase implements UseCase<void, SaveDraftMessageParams> {
  /// Constructor taking [ChatCoreRepository].
  const SaveDraftMessageUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(SaveDraftMessageParams params) {
    return _repository.saveDraftMessage(
      params.conversationId,
      params.draft,
    );
  }
}
