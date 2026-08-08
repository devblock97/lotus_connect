import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/features/calls/presentation/views/calls_screen.dart';
import 'package:lotus_connect/features/chat/presentation/views/conversation_list_view.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/notifications_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/alerts_screen.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/chatbot_conversation_list_screen.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/settings/presentation/views/settings_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = ref.read(settingsProvider).accessToken;
      if (token.isNotEmpty) {
        ref.read(webSocketServiceProvider).connect();
      }
      _subscribeToWebSocket();
    });
  }

  void _subscribeToWebSocket() {
    _wsSubscription?.cancel();
    _wsSubscription = ref
        .read(webSocketServiceProvider)
        .eventStream
        .listen((eventFrame) async {
      AppLogger.debug('WS Event received: $eventFrame');
      final event = eventFrame['event'] as String?;
      final payload = eventFrame['payload'] as Map<String, dynamic>? ?? {};

      if (event == 'chat:message') {
        final messageId = payload['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString();
        final conversationId = (payload['conversationId'] ??
                payload['conversation_id']) as String? ??
            '';
        final senderId =
            (payload['senderId'] ?? payload['sender_id']) as String? ?? '';
        final content = payload['content'] as String? ?? '';
        final createdAtStr =
            (payload['createdAt'] ?? payload['created_at']) as String?;
        final timestamp = createdAtStr != null
            ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
            : DateTime.now();

        AppLogger.debug(
          'WS message parsed - id: $messageId, conv: $conversationId, sender: $senderId, content: $content',
        );

        if (conversationId.isEmpty) {
          AppLogger.warning('WS message ignored: empty conversationId');
          return;
        }

        final currentUserId = ref.read(settingsProvider).userId;
        final isFromSelf = senderId.isNotEmpty && senderId == currentUserId;

        AppLogger.debug(
          'WS check self - currentUserId: $currentUserId, isFromSelf: $isFromSelf',
        );

        // Sender already saved their message locally upon tapping send.
        // Ignore self echo frames.
        if (isFromSelf) {
          AppLogger.debug('WS Ignoring self echo frame');
          return;
        }

        final localDataSource = ref.read(chatCoreLocalDataSourceProvider);

        var peerDisplayName = _nameFromMessagePayload(payload);
        if (peerDisplayName == null && senderId.isNotEmpty) {
          final contactsNotifier = ref.read(contactsProvider.notifier);
          if (ref.read(contactsProvider).friends.isEmpty) {
            await contactsNotifier.loadFriends();
          }
          for (final friend in ref.read(contactsProvider).friends) {
            if (friend.id == senderId) {
              peerDisplayName = friend.fullName?.trim().isNotEmpty ?? false
                  ? friend.fullName!.trim()
                  : friend.username;
              break;
            }
          }
        }
        peerDisplayName ??= _fallbackPeerName(senderId);

        // Auto-create a local conversation if it doesn't exist on
        // the recipient's device yet.
        final conversations = await localDataSource.getConversations();
        final existingConversations =
            conversations.where((c) => c.id == conversationId);
        final existingConversation =
            existingConversations.isEmpty ? null : existingConversations.first;
        if (existingConversation == null) {
          await localDataSource.createConversation(
            id: conversationId,
            title: peerDisplayName,
            isUserToUser: true,
            peerId: senderId,
          );
          AppLogger.info(
            'WS Auto-created conversation $conversationId for peer $senderId',
          );
        } else if (existingConversation.title == _fallbackPeerName(senderId)) {
          await localDataSource.renameConversation(
            conversationId,
            peerDisplayName,
          );
        }

        final replyToId =
            (payload['reply_to_id'] ?? payload['replyToId']) as String?;
        final message = Message(
          id: messageId,
          conversationId: conversationId,
          role: MessageRole.assistant,
          content: content,
          timestamp: timestamp,
          replyToId: replyToId,
        );

        await localDataSource.saveMessage(message);
        AppLogger.info('WS Saved incoming message to SQLite');
      } else if (event == 'chat:delete') {
        final messageId = payload['messageId'] as String? ?? '';
        if (messageId.isNotEmpty) {
          final localDataSource = ref.read(chatCoreLocalDataSourceProvider);
          await localDataSource.deleteMessage(messageId);
          AppLogger.info('WS Deleted message $messageId from SQLite');
        }
      } else if (event == 'chat:edit') {
        final messageId = payload['messageId'] as String? ?? '';
        final content = payload['content'] as String? ?? '';
        if (messageId.isNotEmpty) {
          final localDataSource = ref.read(chatCoreLocalDataSourceProvider);
          final existing = await localDataSource.getMessage(messageId);
          if (existing != null) {
            final updated = existing.copyWith(content: content);
            await localDataSource.saveMessage(updated);
            AppLogger.info('WS Edited message $messageId in SQLite');
          }
        }
      } else if (event == 'notification:new') {
        await ref.read(notificationsProvider.notifier).loadNotifications();
      }
    });
  }

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

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    ref
      ..listen<String>(
        settingsProvider.select((s) => s.accessToken),
        (prev, next) {
          if (next.isNotEmpty) {
            ref.read(webSocketServiceProvider).connect();
          } else {
            ref.read(webSocketServiceProvider).disconnect();
          }
        },
      )
      // Automatically switch to Calls tab (index 2) on incoming call
      ..listen<AsyncValue<WebRTCCallInvitation>>(
        incomingCallProvider,
        (prev, next) {
          if (next.hasValue) {
            ref.read(shellIndexProvider.notifier).state = 2;
          }
        },
      );

    final shellIndex = ref.watch(shellIndexProvider);

    final pages = [
      const ChatbotConversationListScreen(),
      ConversationListView(
        onSelectConversation: () {
          ref.read(shellIndexProvider.notifier).state =
              0; // Switch back to AI Chat when conversation is selected
        },
      ),
      const CallsScreen(),
      const AlertsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: shellIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shellIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            final conversations =
                ref.read(conversationListProvider).conversations;
            final aiConversations = conversations.where((c) => !c.isUserToUser);
            final aiConversation =
                aiConversations.isEmpty ? null : aiConversations.first;
            if (aiConversation != null) {
              ref
                  .read(conversationListProvider.notifier)
                  .selectConversation(aiConversation.id);
            }
          }
          ref.read(shellIndexProvider.notifier).state = index;
        },
        indicatorColor: theme.colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.psychology_outlined),
            selectedIcon: const Icon(Icons.psychology),
            label: loc.tabAi,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: loc.tabChats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.call_outlined),
            selectedIcon: const Icon(Icons.call),
            label: loc.tabCalls,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none_rounded),
            selectedIcon: const Icon(Icons.notifications),
            label: loc.tabAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: loc.tabProfile,
          ),
        ],
      ),
    );
  }
}

/// Placeholder screen for roadmap features (Phase 2 & Phase 3).
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title Feature',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature will be implemented in future',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
