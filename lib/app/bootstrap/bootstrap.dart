import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/router/app_router.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Bootstraps Lotus Connect application with global error handling and ProviderScope.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: LotusConnectApp(),
    ),
  );
}

/// Root widget for Lotus Connect application.
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
