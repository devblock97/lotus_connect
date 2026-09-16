import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/chat/application/typing_status_provider.dart';

class TypingWebsocketHandler implements WebSocketEventHandler {
  TypingWebsocketHandler(this._typingStatusNotifier);

  final TypingStatusNotifier _typingStatusNotifier;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    final conversationId =
        (payload['conversationId'] ?? payload['conversation_id']) as String? ??
            '';

    if (conversationId.isEmpty) return;

    final isTyping = payload['isTyping'] as bool? ?? false;

    _typingStatusNotifier.setTyping(conversationId, isTyping);
  }

  @override
  List<String> get supportedEvents => ['typing'];
}

final typingStatusHandler = Provider<TypingWebsocketHandler>((ref) {
  return TypingWebsocketHandler(ref.watch(typingStatusProvider.notifier));
});
