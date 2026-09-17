import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class ChatReactionRemoveHandler implements WebSocketEventHandler {
  ChatReactionRemoveHandler(this._localDataSource);

  final ChatCoreLocalDataSource _localDataSource;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    final messageId = payload['messageId'] as String? ?? '';
    final reaction = payload['reaction'] as String? ?? '';
    final userId = payload['userId'] as String? ?? '';

    final existing = await _localDataSource.getMessage(messageId);

    if (existing != null) {
      final newReactions = List<Reaction>.from(existing.reactions);
      final index = newReactions.indexWhere((r) => r.reaction == reaction);

      if (index != -1) {
        final r = newReactions[index];
        if (r.users.contains(userId)) {
          final updatedUsers = List<String>.from(r.users)..remove(userId);
          if (updatedUsers.isEmpty) {
            newReactions.removeAt(index);
          } else {
            newReactions[index] = Reaction(
              reaction: reaction,
              count: r.count - 1,
              users: updatedUsers,
            );
          }
        }
      }

      await _localDataSource.saveMessage(
        existing.copyWith(
          reactions: newReactions,
        ),
      );
    }
  }

  @override
  List<String> get supportedEvents => ['chat:reaction_remove'];
}

final chatReactionRemoveHandler = Provider<ChatReactionRemoveHandler>((ref) {
  return ChatReactionRemoveHandler(ref.watch(chatCoreLocalDataSourceProvider));
});
