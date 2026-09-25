import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:lotus_connect/features/settings/data/repositories/settings_repository.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/repositories/settings_repository.dart';
import 'package:lotus_connect/features/settings/domain/usecases/get_app_settings_use_case.dart';
import 'package:lotus_connect/features/settings/domain/usecases/update_app_setting_use_case.dart';

final settingsLocalDataSourceProvider = Provider<SettingLocalDataSource>((ref) {
  return SettingsLocalDataSourceImpl(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    localDataSource: ref.watch(settingsLocalDataSourceProvider),
  );
});

final getAppSettingsUseCaseProvider = Provider<GetAppSettingsUseCase>((ref) {
  return GetAppSettingsUseCase(
    repository: ref.watch(settingsRepositoryProvider),
  );
});

final updateAppSettingUseCaseProvider =
    Provider<UpdateAppSettingUseCase>((ref) {
  return UpdateAppSettingUseCase(
    repository: ref.watch(settingsRepositoryProvider),
  );
});

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    getAppSettingsUseCase: ref.watch(getAppSettingsUseCaseProvider),
    updateAppSettingUseCase: ref.watch(updateAppSettingUseCaseProvider),
  );
});

final currentAppSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsNotifierProvider).settings;
});
