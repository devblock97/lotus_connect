import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypingStatusNotifier extends StateNotifier<Map<String, bool>> {
  TypingStatusNotifier() : super({});

  void setTyping(
    String conversationId,
    bool isTyping,
  ) {
    state = {...state, conversationId: isTyping};
  }
}

final typingStatusProvider =
    StateNotifierProvider<TypingStatusNotifier, Map<String, bool>>((ref) {
  return TypingStatusNotifier();
});
