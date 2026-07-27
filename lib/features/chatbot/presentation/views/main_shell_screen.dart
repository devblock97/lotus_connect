import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/features/calls/presentation/views/calls_screen.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/chatbot_screen.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/conversation_list_view.dart';
import 'package:lotus_connect/features/settings/presentation/views/settings_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Navigation shell wrapping main application tabs matching provided image mocks.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    // Listen to token changes to dynamically connect or disconnect WS
    ref.listen<String>(
      settingsProvider.select((s) => s.accessToken),
      (prev, next) {
        if (next.isNotEmpty) {
          ref.read(webSocketServiceProvider).connect();
        } else {
          ref.read(webSocketServiceProvider).disconnect();
        }
      },
    );

    final pages = [
      const ChatbotScreen(),
      ConversationListView(
        onSelectConversation: () {
          setState(() {
            _currentIndex = 0; // Switch back to AI Chat when conversation is selected
          });
        },
      ),
      const CallsScreen(),
      PlaceholderTab(
        title: loc.tabAlerts,
        icon: Icons.notifications_none_rounded,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
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
              'Scheduled for Phase 2 / Phase 3 roadmap execution.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
