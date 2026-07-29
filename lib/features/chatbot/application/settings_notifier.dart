import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/app_settings.dart';

/// Notifier for application settings state management.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._ref) : super(const AppSettings()) {
    _loadSettings();
  }

  final Ref _ref;

  Future<void> _loadSettings() async {
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    try {
      final settings = await localDataSource.getSettings();
      state = settings;
    } catch (_) {
      // Retain default AppSettings
    }
  }

  /// Sets active ThemeMode (Light, Dark, Sepia).
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets active Language code ('en', 'vi').
  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets active AI Provider ('mock', 'gemini', 'local').
  Future<void> setAiProvider(String providerId) async {
    state = state.copyWith(activeAiProvider: providerId);
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets active AI Model name.
  Future<void> setAiModel(String modelName) async {
    state = state.copyWith(activeAiModel: modelName);
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets Google AI Studio API key.
  Future<void> setGeminiApiKey(String apiKey) async {
    state = state.copyWith(
      geminiApiKey: apiKey.trim(),
      activeAiProvider: 'gemini',
    );
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets Local LLM host URL (Ollama, LM Studio).
  Future<void> setLocalLlmBaseUrl(String url) async {
    state = state.copyWith(
      localLlmBaseUrl: url.trim(),
      activeAiProvider: 'local',
    );
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets auth tokens.
  Future<void> setTokens(String accessToken, String refreshToken) async {
    state = state.copyWith(accessToken: accessToken, refreshToken: refreshToken);
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets auth session including user info.
  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    required String email,
  }) async {
    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      username: username,
      email: email,
    );
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Sets server host.
  Future<void> setServerHost(String host) async {
    state = state.copyWith(serverHost: host.trim());
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }

  /// Clears auth tokens (on logout).
  Future<void> clearTokens() async {
    state = state.copyWith(
      accessToken: '',
      refreshToken: '',
      userId: '',
      username: '',
      email: '',
    );
    final localDataSource = _ref.read(chatbotLocalDataSourceProvider);
    await localDataSource.updateSettings(state);
  }
}

/// Settings notifier provider.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref);
});
