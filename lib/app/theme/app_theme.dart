import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotus_connect/app/theme/app_colors.dart';
import 'package:lotus_connect/app/theme/theme_extensions.dart';

/// Usage Example:
///
/// ```dart
/// // Since Sepia is not a native Flutter ThemeMode, you can apply the theme dynamically
/// // using Riverpod, Provider, or value notifier to watch `AppThemeMode`:
///
/// class AppRoot extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final themeMode = ref.watch(themeModeProvider); // AppThemeMode enum
///
///     return MaterialApp(
///       title: 'Lotus Connect',
///       theme: AppTheme.getTheme(themeMode),
///       home: HomeScreen(),
///     );
///   }
/// }
/// ```

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

  /// Helper function to retrieve correct theme based on custom AppThemeMode.
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.sepia:
        return sepiaTheme;
    }
  }

  /// Light Theme ColorScheme.
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6F5B40),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFBDEB9),
    onPrimaryContainer: Color(0xFF271905),
    secondary: Color(0xFF6D5D4E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF7DFC7),
    onSecondaryContainer: Color(0xFF251A0D),
    tertiary: Color(0xFF51643F),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD3EABB),
    onTertiaryContainer: Color(0xFF101F03),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFF8F3),
    onSurface: Color(0xFF1F1B16),
    surfaceContainerHighest: Color(0xFFF0E0CF),
    onSurfaceVariant: Color(0xFF4F4539),
    outline: Color(0xFF817567),
    outlineVariant: Color(0xFFD3C4B4),
  );

  /// Dark Theme ColorScheme.
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFDEC08F),
    onPrimary: Color(0xFF3D2E15),
    primaryContainer: Color(0xFF57432A),
    onPrimaryContainer: Color(0xFFFBDEB9),
    secondary: Color(0xFFDAC3AC),
    onSecondary: Color(0xFF3B2E20),
    secondaryContainer: Color(0xFF534435),
    onSecondaryContainer: Color(0xFFF7DFC7),
    tertiary: Color(0xFFB7CEA0),
    onTertiary: Color(0xFF243516),
    tertiaryContainer: Color(0xFF3A4C2B),
    onTertiaryContainer: Color(0xFFD3EABB),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF17130E),
    onSurface: Color(0xFFEAE1D9),
    surfaceContainerHighest: Color(0xFF4F4539),
    onSurfaceVariant: Color(0xFFD3C4B4),
    outline: Color(0xFF9C8F80),
    outlineVariant: Color(0xFF4F4539),
  );

  /// Sepia Theme ColorScheme.
  static const ColorScheme sepiaColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF8A5A2B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF0D3A6),
    onPrimaryContainer: Color(0xFF2E1B03),
    secondary: Color(0xFF7A6A50),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE9D9BE),
    onSecondaryContainer: Color(0xFF2A2010),
    tertiary: Color(0xFF6B7A4F),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFDCE7C4),
    onTertiaryContainer: Color(0xFF1D2809),
    error: Color(0xFF9A3412),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF4ECD8),
    onSurface: Color(0xFF3B2F1E),
    surfaceContainerHighest: Color(0xFFE6D8BC),
    onSurfaceVariant: Color(0xFF5C4E39),
    outline: Color(0xFF8A7A5F),
    outlineVariant: Color(0xFFD8C7A5),
  );

  /// Light Theme configuration.
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightColorScheme.surface,
        elevation: 1,
      ),
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outlineVariant,
        space: 1,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: lightColorScheme.onSurface,
        displayColor: lightColorScheme.onSurface,
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
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkColorScheme.surface,
        elevation: 1,
      ),
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outlineVariant,
        space: 1,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
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
      colorScheme: sepiaColorScheme,
      scaffoldBackgroundColor: sepiaColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: sepiaColorScheme.surface,
        foregroundColor: sepiaColorScheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: sepiaColorScheme.onSurface,
        ),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: sepiaColorScheme.surface,
        elevation: 1,
      ),
      dividerTheme: DividerThemeData(
        color: sepiaColorScheme.outlineVariant,
        space: 1,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: sepiaColorScheme.onSurface,
        displayColor: sepiaColorScheme.onSurface,
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
