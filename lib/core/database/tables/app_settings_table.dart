import 'package:drift/drift.dart';

/// Drift table schema for app preferences and user settings.
class AppSettingsTable extends Table {
  /// Key for setting entry (e.g., 'singleton').
  TextColumn get id => text()();

  /// Theme mode string ('light', 'dark', 'sepia').
  TextColumn get themeMode => text().withDefault(const Constant('dark'))();

  /// Locale language code ('en', 'vi').
  TextColumn get languageCode => text().withDefault(const Constant('en'))();

  /// Currently active AI Provider ('mock', 'gemini', 'local').
  TextColumn get activeAiProvider =>
      text().withDefault(const Constant('mock'))();

  /// Currently active AI Model name.
  TextColumn get activeAiModel =>
      text().withDefault(const Constant('gemini-1.5-flash'))();

  /// Google AI Studio API Key.
  TextColumn get geminiApiKey => text().withDefault(const Constant(''))();

  /// Local LLM Base URL (e.g. Ollama http://localhost:11434).
  TextColumn get localLlmBaseUrl =>
      text().withDefault(const Constant('http://localhost:11434'))();

  /// Default system prompt.
  TextColumn get systemPrompt => text().withDefault(
        const Constant('You are a helpful, expert AI assistant.'),
      )();

  /// Access Token for REST & WebSockets auth.
  TextColumn get accessToken => text().withDefault(const Constant(''))();

  /// Refresh Token for RTR auth flow.
  TextColumn get refreshToken => text().withDefault(const Constant(''))();

  /// Rust backend server host base URL.
  TextColumn get serverHost =>
      text().withDefault(const Constant('http://localhost:8080/api/v1'))();

  @override
  Set<Column> get primaryKey => {id};
}
