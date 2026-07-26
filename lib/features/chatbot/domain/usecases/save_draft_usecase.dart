import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Parameters for saving draft messages.
class SaveDraftParams {
  const SaveDraftParams({
    required this.conversationId,
    required this.draft,
  });

  final String conversationId;
  final String draft;
}

/// Use case to save unsent message drafts.
class SaveDraftUseCase implements UseCase<void, SaveDraftParams> {
  /// Constructor taking [ChatbotRepository].
  const SaveDraftUseCase(this._repository);

  final ChatbotRepository _repository;

  @override
  FutureResult<void> call(SaveDraftParams params) {
    return _repository.saveDraftMessage(params.conversationId, params.draft);
  }
}
