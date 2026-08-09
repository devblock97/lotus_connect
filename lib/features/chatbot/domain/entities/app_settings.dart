import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/app/config/app_config.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';

/// Pure Dart entity representing app-wide user preferences.
@immutable
class AppSettings extends Equatable {
  /// Creates an [AppSettings].
  const AppSettings({
    this.themeMode = AppThemeMode.dark,
    this.languageCode = 'en',
    this.activeAiProvider = 'mock',
    this.activeAiModel = 'gemini-1.5-flash',
    this.geminiApiKey = '',
    this.localLlmBaseUrl = 'http://localhost:11434',
    this.systemPrompt = 'You are a helpful, expert AI assistant.',
    this.accessToken = '',
    this.refreshToken = '',
    String serverHost = '',
    this.userId = '',
    this.username = '',
    this.email = '',
  }) : _serverHost = serverHost;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final themeName = json['themeMode'] as String? ?? 'dark';
    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => AppThemeMode.dark,
    );

    return AppSettings(
      themeMode: themeMode,
      languageCode: json['languageCode'] as String? ?? 'en',
      activeAiProvider: json['activeAiProvider'] as String? ?? 'mock',
      activeAiModel: json['activeAiModel'] as String? ?? 'gemini-1.5-flash',
      geminiApiKey: json['geminiApiKey'] as String? ?? '',
      localLlmBaseUrl:
          json['localLlmBaseUrl'] as String? ?? 'http://localhost:11434',
      systemPrompt: json['systemPrompt'] as String? ??
          'You are a helpful, expert AI assistant.',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      serverHost: json['serverHost'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  /// Selected theme mode.
  final AppThemeMode themeMode;

  /// Selected language code.
  final String languageCode;

  /// Active AI provider ID.
  final String activeAiProvider;

  /// Active AI model name.
  final String activeAiModel;

  /// Google AI Studio API Key.
  final String geminiApiKey;

  /// Local LLM Base URL (e.g. Ollama).
  final String localLlmBaseUrl;

  /// Default system prompt.
  final String systemPrompt;

  /// Access Token for backend calls.
  final String accessToken;

  /// Refresh Token for backend token updates.
  final String refreshToken;

  /// Raw Server host base URL.
  final String _serverHost;

  /// Server host base URL, falling back to AppConfig.defaultServerHost.
  String get serverHost {
    var host =
        _serverHost.isNotEmpty ? _serverHost : AppConfig.defaultServerHost;
    // Auto-migrate any legacy localhost, 10.0.2.2, or dynamic ngrok subdomains to the central active ngrok tunnel domain
    if (host == 'http://localhost:8080/api/v1' ||
        host == 'http://10.0.2.2:8080/api/v1' ||
        host.contains('localhost') ||
        host.contains('10.0.2.2') ||
        host.contains('ngrok-free.app')) {
      host = AppConfig.defaultServerHost;
    }
    return host;
  }

  /// Persisted User ID.
  final String userId;

  /// Persisted Username.
  final String username;

  /// Persisted Email.
  final String email;

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'languageCode': languageCode,
      'activeAiProvider': activeAiProvider,
      'activeAiModel': activeAiModel,
      'geminiApiKey': geminiApiKey,
      'localLlmBaseUrl': localLlmBaseUrl,
      'systemPrompt': systemPrompt,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'serverHost': serverHost,
      'userId': userId,
      'username': username,
      'email': email,
    };
  }

  /// Returns a copy of [AppSettings] with updated values.
  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    String? activeAiProvider,
    String? activeAiModel,
    String? geminiApiKey,
    String? localLlmBaseUrl,
    String? systemPrompt,
    String? accessToken,
    String? refreshToken,
    String? serverHost,
    String? userId,
    String? username,
    String? email,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      activeAiProvider: activeAiProvider ?? this.activeAiProvider,
      activeAiModel: activeAiModel ?? this.activeAiModel,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      localLlmBaseUrl: localLlmBaseUrl ?? this.localLlmBaseUrl,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      serverHost: serverHost ?? this.serverHost,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        languageCode,
        activeAiProvider,
        activeAiModel,
        geminiApiKey,
        localLlmBaseUrl,
        systemPrompt,
        accessToken,
        refreshToken,
        _serverHost,
        userId,
        username,
        email,
      ];
}
