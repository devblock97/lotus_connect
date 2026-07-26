import 'package:lotus_connect/core/services/ai/ai_provider.dart';

/// Remote data source interface wrapping AI provider streaming & execution.
abstract class ChatbotRemoteDataSource {
  Stream<String> streamMessage({
    required String prompt,
    required String model,
    required List<Map<String, String>> history,
  });

  void cancelGeneration();

  void setAiProvider(AiProvider provider);
}

/// Concrete implementation of [ChatbotRemoteDataSource].
class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  ChatbotRemoteDataSourceImpl(this._aiProvider);

  AiProvider _aiProvider;

  @override
  void setAiProvider(AiProvider provider) {
    _aiProvider = provider;
  }

  @override
  Stream<String> streamMessage({
    required String prompt,
    required String model,
    required List<Map<String, String>> history,
  }) {
    return _aiProvider.streamMessage(
      prompt: prompt,
      model: model,
      history: history,
    );
  }

  @override
  void cancelGeneration() {
    _aiProvider.cancel();
  }
}
