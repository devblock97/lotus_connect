import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/router/app_router.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/services/callkit/callkit_service.dart';
import 'package:lotus_connect/core/services/notification/push_notification_service.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Bootstraps Lotus Connect application with
/// global error handling and ProviderScope.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  try {
    // Request full intent permission for Android 14+ incoming call UI
    await CallKitService.requestFullIntentPermission();

    // Initialize CallKit service and check for cold-start accepted calls
    final callKitService = container.read(callKitServiceProvider);

    // Initialize Push Notifications & FCM token registration
    final pushService = container.read(pushNotificationServiceProvider);
    await pushService.initialize(
      onCallAccepted: (extra) {
        debugPrint('Bootstrap: Call accepted by user -> $extra');
      },
      onNotificationTap: (data) {
        debugPrint('Bootstrap: Notification tapped -> $data');
        final type = data['type'] as String? ?? '';
        final router = container.read(routerProvider);

        if (type == 'chat_message' || type == 'chat') {
          final conversationId =
              (data['conversationId'] ?? data['conversation_id']) as String?;
          debugPrint('Routing to conversation list (convId: $conversationId)');
          router.go(AppRouter.conversations);
        } else if (type == 'friend_request' || type == 'friend_accept') {
          router.go(AppRouter.contacts);
        } else {
          router.go(AppRouter.home);
        }
      },
    );

    // Check if app was cold-started by accepting an incoming call
    final activeCall = await callKitService.getCurrentCall();
    if (activeCall != null) {
      debugPrint('Cold-start active call found: ${activeCall.id}');
    }
  } catch (e) {
    debugPrint('Bootstrap initialization note: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LotusConnectApp(),
    ),
  );
}

class LotusConnectApp extends ConsumerWidget {
  const LotusConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeData activeTheme;
    switch (settings.themeMode) {
      case AppThemeMode.light:
        activeTheme = AppTheme.lightTheme;
      case AppThemeMode.dark:
        activeTheme = AppTheme.darkTheme;
      case AppThemeMode.sepia:
        activeTheme = AppTheme.sepiaTheme;
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Lotus Connect',
      debugShowCheckedModeBanner: false,
      theme: activeTheme,
      routerConfig: router,
      locale: Locale(settings.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
