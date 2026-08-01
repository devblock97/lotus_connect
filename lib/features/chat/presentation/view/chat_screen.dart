import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/person_message_bubble.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/active_conversation_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/presentation/widgets/chat_input_field.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';

/// Dedicated screen for private, person-to-person conversations.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref
            .read(conversationListProvider.notifier)
            .selectConversation(widget.conversationId);
        ref
            .read(webSocketServiceProvider)
            .send('chat:focus', {'conversationId': widget.conversationId});
      } catch (e) {
        AppLogger.error('Error in ChatScreen initState callback: $e');
      }
    });
  }

  @override
  void dispose() {
    try {
      ref
          .read(webSocketServiceProvider)
          .send('chat:focus', {'conversationId': null});
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
    final conversations = ref.watch(conversationListProvider).conversations;
    Conversation? conversation;
    for (final item in conversations) {
      if (item.id == widget.conversationId) {
        conversation = item;
        break;
      }
    }
    final activeState = ref.watch(activeConversationProvider);
    final activeNotifier = ref.read(activeConversationProvider.notifier);
    final friends = ref.watch(contactsProvider).friends;

    ref.listen<ActiveConversationState>(activeConversationProvider, (_, next) {
      if (next.conversationId == widget.conversationId &&
          next.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    if (conversation == null || !conversation.isUserToUser) {
      return const Scaffold(
        body: Center(
            child: Text('This private conversation is no longer available.')),
      );
    }
    final privateConversation = conversation;
    User? friend;
    for (final item in friends) {
      if (item.id == privateConversation.peerId) {
        friend = item;
        break;
      }
    }
    final displayName = _displayName(privateConversation, friend);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
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
                    loc.privateConversation,
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
              tooltip: loc.voiceCall),
          IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () {},
              tooltip: loc.videoCall),
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
              itemBuilder: (_, index) => PersonMessageBubble(
                message: activeState.messages[index],
                peerName: displayName,
              ),
            ),
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
