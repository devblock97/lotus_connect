import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';

class ChatEditHandler implements WebSocketEventHandler {
  ChatEditHandler(this._localDataSource);
  final ChatCoreLocalDataSource _localDataSource;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    final messageId = payload['messageId'] as String? ?? '';
    final content = payload['content'] as String? ?? '';
    final message = await _localDataSource.getMessage(messageId);
    if (message != null) {
      await _localDataSource.saveMessage(
        message.copyWith(
          content: content,
        ),
      );
    }
  }

  @override
  List<String> get supportedEvents => ['chat:edit'];
}

final chatEditHandler = Provider<ChatEditHandler>((ref) {
  return ChatEditHandler(ref.watch(chatCoreLocalDataSourceProvider));
});
