import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/core/services/websocket/websocket_sync_coordinator.dart';
import 'package:lotus_connect/features/chat/presentation/views/conversation_list_view.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/chatbot_conversation_list_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/views/contacts_screen.dart';
import 'package:lotus_connect/features/notfications/presentation/view/alerts_screen.dart';
import 'package:lotus_connect/features/settings/presentation/views/settings_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = ref.read(settingsProvider).accessToken;
      if (token.isNotEmpty) {
        ref.read(webSocketServiceProvider).connect();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(webSocketSyncCoordinatorProvider);

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
          ref.read(shellIndexProvider.notifier).state = 0;
        },
      ),
      const ContactsScreen(),
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
            icon: const Icon(Icons.perm_contact_cal_outlined),
            selectedIcon: const Icon(Icons.perm_contact_cal_sharp),
            label: loc.contacts,
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
