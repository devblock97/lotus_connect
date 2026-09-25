import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required this.localDataSource});

  final SettingLocalDataSource localDataSource;

  @override
  FutureResult<AppSettings> getAppSettings() async {
    try {
      final response = await localDataSource.getAppSettings();
      return Right(response);
    } on Object catch (_) {
      return const Left(
        DatabaseFailure('Failed to get app settings. Please try again'),
      );
    }
  }

  @override
  FutureResult<void> updateAppSettings(AppSettings settings) async {
    try {
      await localDataSource.updateAppSettings(settings);
      return const Right(null);
    } on Object catch (_) {
      return const Left(
        DatabaseFailure('Failed to update app setting. Please try again'),
      );
    }
  }
}
