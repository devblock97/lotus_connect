import 'dart:async';
import 'package:lotus_connect/core/services/ai/ai_provider.dart';

/// Concrete Mock AI Provider that simulates incremental token streaming using Dart async*.
class MockAiProvider implements AiProvider {
  bool _cancelled = false;

  @override
  String get providerId => 'mock';

  @override
  String get displayName => 'Neural AI (Mock)';

  @override
  List<String> get availableModels => [
        'gpt-4o',
        'gemini-1.5-pro',
        'claude-3-5-sonnet',
        'deepseek-r1',
      ];

  @override
  Future<String> sendMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _generateResponseForPrompt(prompt);
  }

  @override
  Stream<String> streamMessage({
    required String prompt,
    required String model,
    List<Map<String, String>>? history,
    String? systemPrompt,
  }) async* {
    _cancelled = false;
    final fullResponse = _generateResponseForPrompt(prompt);
    final words = fullResponse.split(' ');

    for (var i = 0; i < words.length; i++) {
      if (_cancelled) break;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      yield (i == 0) ? words[i] : ' ${words[i]}';
    }
  }

  @override
  void cancel() {
    _cancelled = true;
  }

  String _generateResponseForPrompt(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('code') ||
        lower.contains('python') ||
        lower.contains('stock') ||
        lower.contains('nvidia')) {
      return '''
Based on market data from Q3 2024, NVIDIA has shown significant outperformance. Here is the comparative analysis:

```python
def calculate_alpha(stock_returns, market_returns):
    # Sector baseline: 4.2%
    # NVIDIA baseline: 12.8%
    return stock_returns - market_returns
```

- **NVIDIA (NVDA)**: +12.8%
- **Nasdaq-100 (NDX)**: +4.2%

Let me know if you would like me to plot additional metrics!''';
    } else if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hello! How can I assist you today on Lotus Connect?';
    }

    return 'That is a great query! Here is a structured response to help you:\n\n'
        '1. **Scalability**: Clean Architecture ensures feature independence.\n'
        '2. **Persistence**: Drift local DB guarantees offline performance.\n'
        '3. **Reactive UI**: Riverpod 3.x keeps state predictable.\n\n'
        'Feel free to ask follow-up questions!';
  }
}
