import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';

class ChatDeleteHandler implements WebSocketEventHandler {
  ChatDeleteHandler(this._localDataSource);
  final ChatCoreLocalDataSource _localDataSource;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    final messageId = payload['messageId'] as String? ?? '';
    if (messageId.isNotEmpty) {
      await _localDataSource.deleteMessage(messageId);
    }
  }

  @override
  List<String> get supportedEvents => ['chat:delete'];
}

final chatDeleteHandler = Provider<ChatDeleteHandler>((ref) {
  return ChatDeleteHandler(ref.watch(chatCoreLocalDataSourceProvider));
});
