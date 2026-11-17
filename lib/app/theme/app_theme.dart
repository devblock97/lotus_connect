import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/app/theme/app_theme_mode.dart';
import 'package:lotus_connect/app/theme/theme_extensions.dart';
export 'package:lotus_connect/app/theme/app_theme_mode.dart';

class AppTheme {
  const AppTheme._();

  /// Helper function to retrieve correct theme based on custom [AppThemeMode].
  static ThemeData getTheme(AppThemeMode mode) => _buildTheme(mode);

  /// Light Theme ColorScheme.
  static ColorScheme get lightColorScheme => colorSchemeFor(AppThemeMode.light);

  /// Dark Theme ColorScheme.
  static ColorScheme get darkColorScheme => colorSchemeFor(AppThemeMode.dark);

  /// Sepia Theme ColorScheme.
  static ColorScheme get sepiaColorScheme => colorSchemeFor(AppThemeMode.sepia);

  /// Builds a Material 3 [ColorScheme] for [mode] using [AppColor].
  static ColorScheme colorSchemeFor(AppThemeMode mode) => ColorScheme(
        brightness:
            mode == AppThemeMode.dark ? Brightness.dark : Brightness.light,
        primary: AppColor.primary.byMode(mode),
        onPrimary: AppColor.onPrimary.byMode(mode),
        primaryContainer: AppColor.primaryContainer.byMode(mode),
        onPrimaryContainer: AppColor.onPrimaryContainer.byMode(mode),
        secondary: AppColor.secondary.byMode(mode),
        onSecondary: AppColor.onSecondary.byMode(mode),
        secondaryContainer: AppColor.secondaryContainer.byMode(mode),
        onSecondaryContainer: AppColor.onSecondaryContainer.byMode(mode),
        tertiary: AppColor.tertiary.byMode(mode),
        onTertiary: AppColor.onTertiary.byMode(mode),
        tertiaryContainer: AppColor.tertiaryContainer.byMode(mode),
        onTertiaryContainer: AppColor.onTertiaryContainer.byMode(mode),
        error: AppColor.error.byMode(mode),
        onError: AppColor.onError.byMode(mode),
        surface: AppColor.surface.byMode(mode),
        onSurface: AppColor.onSurface.byMode(mode),
        surfaceContainerHighest: AppColor.surfaceContainerHighest.byMode(mode),
        onSurfaceVariant: AppColor.onSurfaceVariant.byMode(mode),
        outline: AppColor.outline.byMode(mode),
        outlineVariant: AppColor.outlineVariant.byMode(mode),
      );

  static TextTheme _buildTextTheme(TextTheme baseTextTheme, Color textColor) {
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  static ThemeData _buildTheme(AppThemeMode mode) {
    final scheme = colorSchemeFor(mode);
    final baseTextTheme = mode == AppThemeMode.sepia
        ? GoogleFonts.robotoTextTheme()
        : GoogleFonts.interTextTheme();
    final textColor = mode == AppThemeMode.dark
        ? AppColor.textPrimary.byMode(mode)
        : scheme.onSurface;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: AppSize.elevationNone,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: AppSize.elevationXs,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: AppSize.dividerThickness,
      ),
      textTheme: _buildTextTheme(baseTextTheme, textColor),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeModeExtension(mode: mode),
        AppChatTheme(
          userBubbleBg: AppColor.userBubbleBg.byMode(mode),
          userBubbleFg: AppColor.userBubbleFg.byMode(mode),
          aiBubbleBg: AppColor.aiBubbleBg.byMode(mode),
          aiBubbleFg: AppColor.aiBubbleFg.byMode(mode),
          codeBlockBg: AppColor.codeBlockBg.byMode(mode),
          codeBlockHeaderBg: AppColor.codeBlockHeaderBg.byMode(mode),
        ),
      ],
    );
  }

  /// Light Theme configuration.
  static ThemeData get lightTheme => _buildTheme(AppThemeMode.light);

  /// Dark Theme configuration.
  static ThemeData get darkTheme => _buildTheme(AppThemeMode.dark);

  /// Sepia Theme configuration for eye comfort.
  static ThemeData get sepiaTheme => _buildTheme(AppThemeMode.sepia);
}
