import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/usecases/get_app_settings_use_case.dart';
import 'package:lotus_connect/features/settings/domain/usecases/update_app_setting_use_case.dart';

export 'package:lotus_connect/features/settings/application/settings_providers.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final AppSettings settings;
  final String? errorMessage;

  @override
  List<Object?> get props => [settings, isLoading, isSuccess, errorMessage];

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier({
    required GetAppSettingsUseCase getAppSettingsUseCase,
    required UpdateAppSettingUseCase updateAppSettingUseCase,
  })  : _getAppSettingsUseCase = getAppSettingsUseCase,
        _updateAppSettingUseCase = updateAppSettingUseCase,
        super(const SettingsState()) {
    loadSettings();
  }

  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final UpdateAppSettingUseCase _updateAppSettingUseCase;

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    final result = await _getAppSettingsUseCase(const NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (settings) {
        state = state.copyWith(
          settings: settings,
          isLoading: false,
        );
      },
    );
  }

  Future<bool> updateSettings(AppSettings settings) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
    );
    final result = await _updateAppSettingUseCase(
      UpdateAppSettingParam(settings: settings),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          settings: settings,
          isLoading: false,
          isSuccess: true,
        );
        debugPrint('update setting: ${state.settings.themeMode}');
        return true;
      },
    );
  }

  Future<bool> setThemeMode(AppThemeMode mode) async {
    return updateSettings(state.settings.copyWith(themeMode: mode));
  }

  Future<bool> setLanguage(String code) async {
    return updateSettings(state.settings.copyWith(languageCode: code));
  }

  Future<bool> setAiProvider(String providerId) async {
    return updateSettings(
      state.settings.copyWith(activeAiProvider: providerId),
    );
  }

  Future<bool> setAiModel(String modelName) async {
    return updateSettings(state.settings.copyWith(activeAiModel: modelName));
  }

  Future<bool> setGeminiApiKey(String apiKey) async {
    return updateSettings(
      state.settings.copyWith(
        geminiApiKey: apiKey.trim(),
        activeAiProvider: 'gemini',
      ),
    );
  }

  Future<bool> setLocalLlmBaseUrl(String url) async {
    return updateSettings(
      state.settings.copyWith(
        localLlmBaseUrl: url.trim(),
        activeAiProvider: 'local',
      ),
    );
  }

  Future<bool> setTokens(String accessToken, String refreshToken) async {
    return updateSettings(
      state.settings.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  Future<bool> setSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    required String email,
    required String fullName,
    required String avatarUrl,
  }) async {
    return updateSettings(
      state.settings.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        username: username,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
      ),
    );
  }

  Future<bool> setServerHost(String host) async {
    return updateSettings(state.settings.copyWith(serverHost: host.trim()));
  }

  Future<bool> clearTokens() async {
    return updateSettings(
      state.settings.copyWith(
        accessToken: '',
        refreshToken: '',
        userId: '',
        username: '',
        email: '',
        fullName: '',
        avatarUrl: '',
      ),
    );
  }
}
