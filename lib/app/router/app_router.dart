import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/chatbot_screen.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/conversation_list_view.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/main_shell_screen.dart';
import 'package:lotus_connect/features/settings/presentation/views/settings_screen.dart';

/// Central router configuration using GoRouter.
class AppRouter {
  const AppRouter._();

  static const String home = '/';
  static const String chat = '/chat';
  static const String conversations = '/conversations';
  static const String settings = '/settings';

  /// GoRouter instance configuration.
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (BuildContext context, GoRouterState state) =>
            const MainShellScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (BuildContext context, GoRouterState state) =>
            const ChatbotScreen(),
      ),
      GoRoute(
        path: conversations,
        builder: (BuildContext context, GoRouterState state) =>
            const ConversationListView(),
      ),
      GoRoute(
        path: settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
  );
}
