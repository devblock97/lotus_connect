import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/application/private_active_conversation_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/person_message_bubble.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/presentation/widgets/chat_input_field.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Dedicated screen for private, person-to-person conversations.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  late final WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();
    _webSocketService = ref.read(webSocketServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref
            .read(privateConversationListProvider.notifier)
            .selectConversation(widget.conversationId);
        _webSocketService
            .send('chat:focus', {'conversationId': widget.conversationId});
      } catch (e) {
        AppLogger.error('Error in ChatScreen initState callback: $e');
      }
    });
  }

  @override
  void dispose() {
    try {
      _webSocketService.send('chat:focus', {'conversationId': null});
    } catch (e) {
      AppLogger.error('Error in ChatScreen dispose callback: $e');
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final conversations =
        ref.watch(privateConversationListProvider).conversations;
    Conversation? conversation;
    for (final item in conversations) {
      if (item.id == widget.conversationId) {
        conversation = item;
        break;
      }
    }
    final activeState = ref.watch(privateActiveConversationProvider);
    final activeNotifier = ref.read(privateActiveConversationProvider.notifier);
    final friends = ref.watch(contactsProvider).friends;

    ref.listen<PrivateActiveConversationState>(
        privateActiveConversationProvider, (_, next) {
      if (next.conversationId == widget.conversationId &&
          next.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    if (conversation == null || !conversation.isUserToUser) {
      return const Scaffold(
        body: Center(
          child: Text('This private conversation is no longer available.'),
        ),
      );
    }
    final privateConversation = conversation;
    User? friend;
    for (final f in friends) {
      if (f.id == privateConversation.peerId) {
        friend = f;
        break;
      }
    }
    final displayName = _displayName(privateConversation, friend);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(_initial(displayName)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Private conversation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
            tooltip: loc.voiceCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
            tooltip: loc.videoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: activeState.conversationId == widget.conversationId
                  ? activeState.messages.length
                  : 0,
              itemBuilder: (_, index) {
                final message = activeState.messages[index];
                final repliedTo = message.replyToId != null
                    ? activeState.messages
                        .firstWhereOrNull((m) => m.id == message.replyToId)
                    : null;
                return PersonMessageBubble(
                  message: message,
                  peerName: displayName,
                  repliedToMessage: repliedTo,
                );
              },
            ),
          ),
          if (activeState.replyingToMessage != null)
            _buildReplyPreview(
              context,
              activeState.replyingToMessage!,
              displayName,
              activeNotifier,
            ),
          ChatInputField(
            isGenerating: false,
            onSend: activeNotifier.sendMessage,
            onStop: () {},
            initialText: activeState.conversationId == widget.conversationId
                ? activeState.draftInput
                : '',
            onChanged: activeNotifier.updateDraft,
            hintText: 'Message $displayName',
            showAiDisclaimer: false,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(
    BuildContext context,
    Message replyingTo,
    String peerName,
    PrivateActiveConversationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isMine = replyingTo.role.isUser;
    final senderName = isMine ? 'You' : peerName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerLow ?? theme.cardColor,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to $senderName',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyingTo.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: notifier.cancelReply,
          ),
        ],
      ),
    );
  }

  String _displayName(Conversation conversation, User? friend) {
    final fullName = friend?.fullName;
    if (fullName != null && fullName.trim().isNotEmpty) return fullName;

    final username = friend?.username;
    if (username != null && username.trim().isNotEmpty) return username;

    return conversation.title;
  }

  String _initial(String name) {
    return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
  }
}
