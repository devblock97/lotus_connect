import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/application/presence_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_active_conversation_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/application/typing_status_provider.dart';
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

  double _previousMaxScroll = 0;
  double _previousPixels = 0;

  OverlayEntry? _newMessageOverlay;

  @override
  void initState() {
    super.initState();
    _webSocketService = ref.read(webSocketServiceProvider);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      try {
        ref
            .read(privateConversationListProvider.notifier)
            .selectConversation(widget.conversationId);
        _webSocketService
            .send('chat:focus', {'conversationId': widget.conversationId});
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
    final typingMap = ref.watch(typingStatusProvider);
    final isPeerTyping = typingMap[widget.conversationId] ?? false;

    ref.listen<PrivateActiveConversationState>(
        privateActiveConversationProvider, (prev, next) {
      if (prev != null &&
          next.messages.length > prev.messages.length &&
          _previousMaxScroll > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          final newMaxScroll = _scrollController.position.maxScrollExtent;
          final delta = newMaxScroll - _previousMaxScroll;
          debugPrint('delta: $delta');
          if (delta > 50) {
            _showNewMessageAlert(context, 150, 120, delta + 20);
          }
          _previousPixels = 0.0;
        });
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
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[privateConversation.peerId];
    final isOnline = peerPresence?.isOnline ?? false;
    final lastSeen = peerPresence?.lastSeen ?? privateConversation.updatedAt;

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
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: activeState.messages.length +
                  (activeState.hasLoadMore || activeState.hasReachedMax
                      ? 1
                      : 0),
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

                  if (activeState.hasReachedMax &&
                      activeState.messages.length >= 25) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Beginning of conversation',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500,),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }

                final message = activeState.messages[index];
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
            onSend: (message, file) {
              _scrollToBottom();
              activeNotifier.sendMessage(message, file?.path);
            },
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

  void _showNewMessageAlert(BuildContext context, double bottom, double left,
      [double offset = 0,]) {
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
    debugPrint('hide nef :)');
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

  void _scrollToBottom([double offset = 0]) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  bool get _isBottom {
    final currPixel = _scrollController.position.pixels;
    final maxPixel = _scrollController.position.maxScrollExtent;

    return currPixel >= (maxPixel * 0.9);
  }

  bool get _isTop {
    final currPixel = _scrollController.position.pixels;
    final maxPixel = _scrollController.position.maxScrollExtent;

    return currPixel <= maxPixel * 0.2;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_isTop) {
      debugPrint("hello, it's me");
      final state = ref.read(privateActiveConversationProvider);
      if (!state.hasLoadMore && !state.hasReachedMax) {
        _previousPixels = _scrollController.position.pixels;
        _previousMaxScroll = _scrollController.position.maxScrollExtent;

        ref
            .read(privateActiveConversationProvider.notifier)
            .loadMoreMessage(widget.conversationId);
      }
    }
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
