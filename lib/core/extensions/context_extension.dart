import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_theme_mode.dart';

/// Convenient BuildContext extensions for UI access.
extension ContextX on BuildContext {
  /// Quick access to ThemeData.
  ThemeData get theme => Theme.of(this);

  /// Quick access to ColorScheme.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Quick access to TextTheme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to MediaQuery size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Active theme mode (Light, Dark, or Sepia).
  AppThemeMode get themeMode => AppColor.modeOf(this);

  /// Checks if dark mode is active.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Checks if sepia mode is active.
  bool get isSepiaMode => themeMode == AppThemeMode.sepia;
}
