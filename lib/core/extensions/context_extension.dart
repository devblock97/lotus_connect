import 'package:flutter/material.dart';

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

  /// Checks if dark mode is active.
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
