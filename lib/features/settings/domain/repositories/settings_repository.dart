import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  FutureResult<AppSettings> getAppSettings();

  FutureResult<void> updateAppSettings(AppSettings settings);
}
