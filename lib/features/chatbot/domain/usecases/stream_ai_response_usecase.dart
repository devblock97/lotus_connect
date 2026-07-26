import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Parameters for streaming AI responses.
class StreamAiParams {
  const StreamAiParams({
    required this.conversationId,
    required this.prompt,
    required this.model,
    required this.history,
  });

  final String conversationId;
  final String prompt;
  final String model;
  final List<Message> history;
}

/// Use case to stream incremental AI response tokens.
class StreamAiResponseUseCase implements StreamUseCase<String, StreamAiParams> {
  /// Constructor taking [ChatbotRepository].
  const StreamAiResponseUseCase(this._repository);

  final ChatbotRepository _repository;

  @override
  StreamResult<String> call(StreamAiParams params) {
    return _repository.streamAiResponse(
      conversationId: params.conversationId,
      prompt: params.prompt,
      model: params.model,
      history: params.history,
    );
  }
}
