import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/core/services/ai/ai_provider.dart';

/// Concrete local AI provider connecting to local LLM engines (Ollama, LM Studio).
class LocalAiProvider implements AiProvider {
  /// Constructor taking [DioClient] and optional base URL.
  LocalAiProvider({
    required DioClient dioClient,
    String? baseUrl,
  })  : _dioClient = dioClient,
        _baseUrl = baseUrl?.isNotEmpty == true ? baseUrl! : 'http://localhost:11434';

  final DioClient _dioClient;
  final String _baseUrl;
  CancelToken? _cancelToken;

  @override
  String get providerId => 'local';

  @override
  String get displayName => 'Local LLM (Ollama)';

  @override
  List<String> get availableModels => [
        'llama3',
        'mistral',
        'phi3',
        'gemma2',
        'qwen2',
      ];

  @override
  Future<String> sendMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  }) async {
    _cancelToken = CancelToken();
    try {
      final url = '$_baseUrl/api/chat';
      final messages = <Map<String, String>>[];

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add({'role': 'system', 'content': systemPrompt});
      }
      if (history != null) {
        messages.addAll(history);
      }
      messages.add({'role': 'user', 'content': prompt});

      final response = await _dioClient.post<Map<String, dynamic>>(
        url,
        data: {
          'model': model,
          'messages': messages,
          'stream': false,
        },
        cancelToken: _cancelToken,
      );

      final messageMap = response.data?['message'] as Map<String, dynamic>?;
      return messageMap?['content'] as String? ?? '';
    } catch (e) {
      return 'Failed to call local LLM. Make sure Ollama/LM Studio is running at $_baseUrl. Error: $e';
    }
  }

  @override
  Stream<String> streamMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  }) async* {
    _cancelToken = CancelToken();
    final url = '$_baseUrl/api/chat';
    final messages = <Map<String, String>>[];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    if (history != null) {
      messages.addAll(history);
    }
    messages.add({'role': 'user', 'content': prompt});

    try {
      final response = await _dioClient.dio.post<ResponseBody>(
        url,
        data: {
          'model': model,
          'messages': messages,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
        cancelToken: _cancelToken,
      );

      final stream = response.data?.stream;
      if (stream == null) return;

      if (response.statusCode != 200) {
        final rawError = await utf8.decodeStream(stream);
        yield '⚠️ Local LLM Error (${response.statusCode}): $rawError\n\nPlease ensure Ollama or LM Studio is running locally at $_baseUrl';
        return;
      }

      var buffer = '';
      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (final line in lines.sublist(0, lines.length - 1)) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          try {
            final data = jsonDecode(trimmed) as Map<String, dynamic>;
            final messageMap = data['message'] as Map<String, dynamic>?;
            if (messageMap != null) {
              final content = messageMap['content'] as String?;
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            }
          } catch (_) {
            // Partial JSON buffer retry
          }
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      yield '⚠️ Local LLM connection failed at $_baseUrl.\n\nPlease start Ollama (`ollama run llama3`) or check your connection. Error: ${e.message}';
    } catch (e) {
      yield 'Error connecting to local LLM: $e';
    }
  }

  @override
  void cancel() {
    _cancelToken?.cancel('User cancelled request');
  }
}
