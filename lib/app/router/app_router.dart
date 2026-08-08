import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotus_connect/features/auth/presentation/views/login_screen.dart';
import 'package:lotus_connect/features/chat/presentation/views/conversation_list_view.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/chatbot_screen.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/main_shell_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/views/contacts_screen.dart';
import 'package:lotus_connect/features/settings/presentation/views/settings_screen.dart';

/// Central router configuration using GoRouter.
class AppRouter {
  const AppRouter._();

  static const String home = '/';
  static const String login = '/login';
  static const String chat = '/chat';
  static const String conversations = '/conversations';
  static const String settings = '/settings';
  static const String contacts = '/contacts';
}

/// Global provider exposing the reactive GoRouter configuration.
final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);

  return GoRouter(
    initialLocation: AppRouter.home,
    redirect: (context, state) {
      final isAuth = settings.accessToken.isNotEmpty;
      final goingToAuth = state.matchedLocation == AppRouter.login;

      // Force redirection to Login if no access token exists in local SQLite
      if (!isAuth && !goingToAuth) {
        return AppRouter.login;
      }
      // Redirect authenticated users away from Login screen
      if (isAuth && goingToAuth) {
        return AppRouter.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRouter.home,
        builder: (BuildContext context, GoRouterState state) =>
            const MainShellScreen(),
      ),
      GoRoute(
        path: AppRouter.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.chat,
        builder: (BuildContext context, GoRouterState state) =>
            const ChatbotScreen(),
      ),
      GoRoute(
        path: AppRouter.conversations,
        builder: (BuildContext context, GoRouterState state) =>
            const ConversationListView(),
      ),
      GoRoute(
        path: AppRouter.settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      GoRoute(
        path: AppRouter.contacts,
        builder: (BuildContext context, GoRouterState state) =>
            const ContactsScreen(),
      ),
    ],
  );
});
