/// Supported theme modes in Lotus Connect.
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
