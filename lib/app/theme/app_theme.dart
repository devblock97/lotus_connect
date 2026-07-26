import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotus_connect/app/theme/app_colors.dart';
import 'package:lotus_connect/app/theme/theme_extensions.dart';

/// Enum representing supported themes in Lotus Connect.
enum AppThemeMode {
  light,
  dark,
  sepia;

  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.sepia:
        return 'Sepia';
    }
  }
}

/// Provides Light, Dark, and Sepia ThemeData configurations with Material 3.
class AppTheme {
  const AppTheme._();

  /// Light Theme configuration.
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textLight,
        secondary: Color(0xFF0066FF),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppChatTheme(
          userBubbleBg: AppColors.userBubbleLight,
          userBubbleFg: Colors.white,
          aiBubbleBg: AppColors.aiBubbleLight,
          aiBubbleFg: AppColors.textLight,
          codeBlockBg: Color(0xFF1E1E2E),
          codeBlockHeaderBg: Color(0xFF181825),
        ),
      ],
    );
  }

  /// Dark Theme configuration.
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textDark,
        secondary: Color(0xFF64B5F6),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppChatTheme(
          userBubbleBg: AppColors.userBubbleDark,
          userBubbleFg: AppColors.textDark,
          aiBubbleBg: AppColors.aiBubbleDark,
          aiBubbleFg: AppColors.textDark,
          codeBlockBg: Color(0xFF18181E),
          codeBlockHeaderBg: Color(0xFF121216),
        ),
      ],
    );
  }

  /// Sepia Theme configuration for eye comfort.
  static ThemeData get sepiaTheme {
    final baseTextTheme = GoogleFonts.merriweatherTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgSepia,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primarySepia,
        surface: AppColors.surfaceSepia,
        onSurface: AppColors.textSepia,
        secondary: Color(0xFFA1887F),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textSepia,
        displayColor: AppColors.textSepia,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppChatTheme(
          userBubbleBg: AppColors.userBubbleSepia,
          userBubbleFg: Colors.white,
          aiBubbleBg: AppColors.aiBubbleSepia,
          aiBubbleFg: AppColors.textSepia,
          codeBlockBg: Color(0xFF3E2723),
          codeBlockHeaderBg: Color(0xFF2C1D18),
        ),
      ],
    );
  }
}
