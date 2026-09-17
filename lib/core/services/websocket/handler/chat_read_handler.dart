import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';

class ChatReadHandler implements WebSocketEventHandler {
  ChatReadHandler(this._localDataSource);
  final ChatCoreLocalDataSource _localDataSource;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    final messageId = payload['messageId'] as String? ?? '';
    final readMessage = await _localDataSource.getMessage(messageId);
    if (readMessage != null) {
      await _localDataSource.markOutgoingMessagesAsRead(
        readMessage.conversationId,
        readMessage.timestamp,
      );
    }
  }

  @override
  List<String> get supportedEvents => ['chat:read'];
}

final chatReadHandler = Provider<ChatReadHandler>((ref) {
  return ChatReadHandler(ref.watch(chatCoreLocalDataSourceProvider));
});
