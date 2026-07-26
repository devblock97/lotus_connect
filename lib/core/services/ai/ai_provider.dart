import 'dart:async';

/// Abstract interface for AI providers.
/// Enables swapping AI backends (Mock, Gemini, OpenRouter, OpenAI, Groq, etc.)
/// without mutating domain or presentation layers.
abstract class AiProvider {
  /// Unique provider identifier (e.g. 'gemini', 'openrouter', 'mock').
  String get providerId;

  /// Human readable display name.
  String get displayName;

  /// List of supported models for this provider.
  List<String> get availableModels;

  /// Sends a message non-streamed and returns complete response.
  Future<String> sendMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  });

  /// Streams AI response chunks incrementally.
  Stream<String> streamMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  });

  /// Cancels an in-flight generation task if supported.
  void cancel();
}
