import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/core/services/ai/ai_provider.dart';

/// Concrete Google Gemini AI Provider implementation using Google AI Studio REST API.
class GeminiAiProvider implements AiProvider {
  /// Constructor taking [DioClient] and optional API Key.
  GeminiAiProvider({
    required DioClient dioClient,
    String? apiKey,
  })  : _dioClient = dioClient,
        _apiKey = apiKey?.trim() ?? '';

  final DioClient _dioClient;
  final String _apiKey;
  CancelToken? _cancelToken;

  @override
  String get providerId => 'gemini';

  @override
  String get displayName => 'Google Gemini (AI Studio)';

  @override
  List<String> get availableModels => [
        'gemini-1.5-flash',
        'gemini-1.5-flash-8b',
        'gemini-1.5-pro',
        'gemini-2.0-flash',
        'gemini-2.0-flash-lite',
        'gemini-2.0-pro-exp-02-05',
        'gemini-2.0-flash-thinking-exp-01-21',
      ];

  @override
  Future<String> sendMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  }) async {
    if (_apiKey.isEmpty) {
      throw const AiProviderException(
        'Google AI Studio API Key is not set. Please enter your API Key in Settings.',
      );
    }
    _cancelToken = CancelToken();
    try {
      final modelName = model.startsWith('gemini') ? model : 'gemini-1.5-flash';
      final url =
          '${ApiConstants.geminiBaseUrl}/models/$modelName:generateContent?key=$_apiKey';

      final contents = <Map<String, dynamic>>[];
      if (history != null) {
        for (final msg in history) {
          final role = msg['role'] == 'user' ? 'user' : 'model';
          contents.add({
            'role': role,
            'parts': [
              {'text': msg['content']}
            ]
          });
        }
      }
      contents.add({
        'role': 'user',
        'parts': [
          {'text': prompt}
        ]
      });

      final body = <String, dynamic>{'contents': contents};
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        body['systemInstruction'] = {
          'parts': [
            {'text': systemPrompt}
          ]
        };
      }

      final response = await _dioClient.post<Map<String, dynamic>>(
        url,
        data: body,
        cancelToken: _cancelToken,
      );

      final candidates = response.data?['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String? ?? '';
        }
      }
      return '';
    } catch (e) {
      throw AiProviderException('Gemini API call failed: $e', e);
    }
  }

  @override
  Stream<String> streamMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  }) async* {
    if (_apiKey.isEmpty) {
      yield '⚠️ Google AI Studio API Key is missing.\n\nPlease open Settings -> AI Engine Settings and paste your Gemini API Key.';
      return;
    }

    _cancelToken = CancelToken();

    final modelName = model.startsWith('gemini') ? model : 'gemini-1.5-flash';
    final url =
        '${ApiConstants.geminiBaseUrl}/models/$modelName:streamGenerateContent?alt=sse&key=$_apiKey';

    final contents = <Map<String, dynamic>>[];
    if (history != null) {
      for (final msg in history) {
        final role = msg['role'] == 'user' ? 'user' : 'model';
        contents.add({
          'role': role,
          'parts': [
            {'text': msg['content']}
          ]
        });
      }
    }
    contents.add({
      'role': 'user',
      'parts': [
        {'text': prompt}
      ]
    });

    final body = <String, dynamic>{'contents': contents};
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemPrompt}
        ]
      };
    }

    try {
      final response = await _dioClient.dio.post<ResponseBody>(
        url,
        data: body,
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
        try {
          final errorJson = jsonDecode(rawError) as Map<String, dynamic>;
          final errObj = errorJson['error'];
          if (errObj is Map) {
            yield '⚠️ Gemini API Error (${response.statusCode}): ${errObj['message']}';
            return;
          }
        } catch (_) {}
        yield '⚠️ Gemini API Error (${response.statusCode}): $rawError';
        return;
      }

      var buffer = '';
      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (final line in lines.sublist(0, lines.length - 1)) {
          final trimmed = line.trim();
          if (trimmed.startsWith('data: ')) {
            final jsonStr = trimmed.substring(6).trim();
            if (jsonStr == '[DONE]') continue;
            try {
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              final candidates = data['candidates'] as List<dynamic>?;
              if (candidates != null && candidates.isNotEmpty) {
                final content =
                    candidates[0]['content'] as Map<String, dynamic>?;
                final parts = content?['parts'] as List<dynamic>?;
                if (parts != null && parts.isNotEmpty) {
                  final text = parts[0]['text'] as String?;
                  if (text != null && text.isNotEmpty) {
                    yield text;
                  }
                }
              }
            } catch (_) {
              // Partial chunk retry
            }
          }
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return;
      }
      var errorDetails = e.message ?? 'Network error';
      if (e.response?.data is ResponseBody) {
        try {
          final bodyStream = (e.response!.data as ResponseBody).stream;
          final rawJsonStr = await utf8.decodeStream(bodyStream);
          final errorJson = jsonDecode(rawJsonStr);
          if (errorJson is Map && errorJson['error'] != null) {
            final errObj = errorJson['error'];
            if (errObj is Map) {
              errorDetails = errObj['message'] as String? ?? rawJsonStr;
            } else {
              errorDetails = rawJsonStr;
            }
          } else {
            errorDetails = rawJsonStr;
          }
        } catch (_) {}
      }
      yield '⚠️ Gemini API Error ($errorDetails)';
    } catch (e) {
      yield 'Error connecting to Gemini API: $e';
    }
  }

  @override
  void cancel() {
    _cancelToken?.cancel('User cancelled request');
  }
}
