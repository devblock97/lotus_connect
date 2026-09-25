import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';

class ChatMessageWebSocketHandler implements WebSocketEventHandler {
  ChatMessageWebSocketHandler({
    required ChatCoreLocalDataSource localDataSource,
    required String Function() currentUserIdGetter,
  })  : _localDataSource = localDataSource,
        _currentUserIdGetter = currentUserIdGetter;

  final ChatCoreLocalDataSource _localDataSource;
  final String Function() _currentUserIdGetter;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    final senderId =
        (payload['senderId'] ?? payload['sender_id']) as String ?? '';
    final currentUserId = _currentUserIdGetter();
    if (senderId == currentUserId && senderId.isNotEmpty) return;

    final messageId = payload['id'] as String? ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final conversationId =
        (payload['conversationId'] ?? payload['conversation_id']) as String? ??
            '';

    if (conversationId.isEmpty) return;

    final content = payload['content'] as String? ?? '';
    final createdAtStr =
        (payload['createdAt'] ?? payload['created_at']) as String?;
    final timestamp = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    // Auto-create or update conversation
    final conversations = await _localDataSource.getConversations();
    final existingConversation = conversations.cast<Conversation?>().firstWhere(
          (c) => c?.id == conversationId,
          orElse: () => null,
        );

    if (existingConversation == null) {
      final peerDisplayName =
          _nameFromMessagePayload(payload) ?? _fallbackPeerName(senderId);
      await _localDataSource.createConversation(
        id: conversationId,
        title: peerDisplayName,
        isUserToUser: true,
        peerId: senderId,
      );
    } else {
      final peerDisplayName = _nameFromMessagePayload(payload);
      if (peerDisplayName != null &&
          existingConversation.title == _fallbackPeerName(senderId)) {
        await _localDataSource.renameConversation(
          conversationId,
          peerDisplayName,
        );
      }
    }

    final message = Message(
      id: messageId,
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: content,
      timestamp: timestamp,
      replyToId: (payload['reply_to_id'] ?? payload['replyToId']) as String?,
      mediaUrl: payload['media_url'] as String?,
      thumbnailUrl: payload['thumbnail_url'] as String?,
      mimeType: payload['mime_type'] as String?,
    );

    await _localDataSource.saveMessage(message);
  }

  @override
  List<String> get supportedEvents => ['chat:message'];

  String _fallbackPeerName(String senderId) {
    return senderId.length > 8
        ? 'User ${senderId.substring(0, 8)}'
        : 'User $senderId';
  }

  String? _nameFromMessagePayload(Map<String, dynamic> payload) {
    final sender = payload['sender'];
    final profile = sender is Map ? Map<String, dynamic>.from(sender) : payload;
    final fullName = profile['fullName'] ?? profile['full_name'];
    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }

    final username = profile['username'] ??
        profile['senderUsername'] ??
        profile['sender_username'];
    if (username is String && username.trim().isNotEmpty) {
      return username.trim();
    }

    final displayName = profile['displayName'] ??
        profile['display_name'] ??
        profile['senderName'] ??
        profile['sender_name'];
    return displayName is String && displayName.trim().isNotEmpty
        ? displayName.trim()
        : null;
  }
}

final chatMessageHandler = Provider<ChatMessageWebSocketHandler>((ref) {
  return ChatMessageWebSocketHandler(
    localDataSource: ref.watch(chatCoreLocalDataSourceProvider),
    currentUserIdGetter: () =>
        ref.watch(settingsNotifierProvider).settings.userId,
  );
});
