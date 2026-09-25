import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_delete_handler.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_edit_handler.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_message_handler.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_reaction_add_handler.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_reaction_remove_handler.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_read_handler.dart';
import 'package:lotus_connect/core/services/websocket/handler/presence_handler.dart';
import 'package:lotus_connect/core/services/websocket/handler/typing_handler.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';

class WebSocketEventDispatcher {
  WebSocketEventDispatcher(List<WebSocketEventHandler> handlers) {
    for (final handler in handlers) {
      for (final event in handler.supportedEvents) {
        _handleMap[event] = handler;
      }
    }
  }

  final Map<String, WebSocketEventHandler> _handleMap = {};

  Future<void> dispatch(Map<String, dynamic> eventFrame) async {
    final event = eventFrame['event'] as String?;
    final payload = eventFrame['payload'] as Map<String, dynamic>? ?? {};

    if (event == null) return;

    final handler = _handleMap[event];
    if (handler != null) {
      try {
        await handler.handle(event, payload);
      } on Object catch (e, stack) {
        AppLogger.error('Error handling ws event "$event"', e, stack);
      }
    } else {
      AppLogger.debug('No handler registered for WS event: $event');
    }
  }
}

final webSocketEventDispatcherProvider =
    Provider<WebSocketEventDispatcher>((ref) {
  final handlers = [
    ref.watch(chatMessageHandler),
    ref.watch(typingStatusHandler),
    ref.watch(presenceHandler),
    ref.watch(chatReactionAddHandler),
    ref.watch(chatReactionRemoveHandler),
    ref.watch(chatDeleteHandler),
    ref.watch(chatReadHandler),
    ref.watch(chatEditHandler),
  ];
  return WebSocketEventDispatcher(handlers);
});
