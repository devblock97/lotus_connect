import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/chat/application/presence_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_active_conversation_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/application/typing_status_provider.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/person_message_bubble.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/presentation/widgets/chat_input_field.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Dedicated screen for private, person-to-person conversations.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversation, super.key});

  final Conversation conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  late final WebSocketService _webSocketService;

  OverlayEntry? _newMessageOverlay;

  @override
  void initState() {
    super.initState();
    _webSocketService = ref.read(webSocketServiceProvider);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref
            .read(privateConversationListProvider.notifier)
            .selectConversation(widget.conversation.id);
        _webSocketService
            .send('chat:focus', {'conversationId': widget.conversation.id});
      } on Object catch (e) {
        AppLogger.error('Error in ChatScreen initState callback: $e');
      }
    });
  }

  @override
  void dispose() {
    try {
      _webSocketService.send('chat:focus', {'conversationId': null});
    } on Object catch (e) {
      AppLogger.error('Error in ChatScreen dispose callback: $e');
    }
    _scrollController.dispose();
    _hideNewMessageAlert();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final activeState = ref.watch(privateActiveConversationProvider);
    final activeNotifier = ref.read(privateActiveConversationProvider.notifier);
    final typingMap = ref.watch(typingStatusProvider);
    final isPeerTyping = typingMap[widget.conversation.id] ?? false;

    ref.listen<PrivateActiveConversationState>(
        privateActiveConversationProvider, (prev, next) {
      if (prev != null && next.messages.length > prev.messages.length) {
        final isNewMessageAppended = next.messages.isNotEmpty &&
            next.messages.last != prev.messages.lastOrNull;

        if (isNewMessageAppended) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients) return;
            if (_isBottom) {
              _scrollToBottom();
            } else {
              _showNewMessageAlert(context, 150, 120);
            }
          });
        }
      }

      final peerMessages = next.messages.where((m) => m.role.isAssistant);

      if (peerMessages.isNotEmpty) {
        final latestPeerMessage = peerMessages.last;
        // Send the read receipt only if the latest peer message is not already
        // marked as read
        if (latestPeerMessage.status != MessageStatus.read) {
          _webSocketService.sendReadReceipt(latestPeerMessage.id);
        }
      }
    });

    final displayName = widget.conversation.title;
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[widget.conversation.peerId];
    final isOnline = peerPresence?.isOnline ?? false;
    final lastSeen = peerPresence?.lastSeen ?? widget.conversation.updatedAt;

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
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatLastSeen(isOnline, lastSeen),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
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
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: activeState.messages.length +
                  (activeState.hasLoadMore ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == activeState.messages.length) {
                  if (activeState.hasLoadMore) {
                    return const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final msgIndex = activeState.messages.length - 1 - index;

                final message = activeState.messages[msgIndex];
                final repliedTo = message.replyToId != null
                    ? activeState.messages
                        .firstWhereOrNull((m) => m.id == message.replyToId)
                    : null;
                return PersonMessageBubble(
                  message: message,
                  peerName: displayName,
                  repliedToMessage: repliedTo,
                  onSelectReaction: (msg, emoji) {
                    ref
                        .read(privateActiveConversationProvider.notifier)
                        .reactMessage(msg.id, emoji);
                  },
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
          if (isPeerTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text(
                    '$displayName is typing...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ChatInputField(
            isGenerating: false,
            onSend: (message, medias) {
              debugPrint('check media message input: ${medias.length}');
              activeNotifier.sendMessage(message, medias);
              _scrollToBottom();
            },
            onStop: () {},
            initialText: activeState.conversationId == widget.conversation.id
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

  void _showNewMessageAlert(
    BuildContext context,
    double bottom,
    double left,
  ) {
    if (_newMessageOverlay != null || _isBottom) return;

    final overlay = Overlay.of(context);

    _newMessageOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottom,
        left: left,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _hideNewMessageAlert,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'New message',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_newMessageOverlay!);
  }

  void _hideNewMessageAlert([double offset = 0]) {
    if (_newMessageOverlay == null) return;
    _newMessageOverlay?.remove();
    _newMessageOverlay = null;
    _scrollToBottom(offset);
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
      color: theme.colorScheme.surfaceContainerLow,
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

  void _scrollToBottom([double offset = 0]) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return true;
    return _scrollController.position.pixels <= 60;
  }

  bool get _isTop {
    if (!_scrollController.hasClients) return false;
    final maxPixel = _scrollController.position.maxScrollExtent;
    return _scrollController.position.pixels >= maxPixel - 200;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_isTop) {
      ref
          .read(privateActiveConversationProvider.notifier)
          .loadMoreMessage(widget.conversation.id);
    }
  }

  String _initial(String name) {
    return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
  }
}
