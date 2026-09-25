import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/repositories/settings_repository.dart';

class GetAppSettingsUseCase implements UseCase<AppSettings, NoParams> {
  GetAppSettingsUseCase({required SettingsRepository repository})
      : _repository = repository;

  final SettingsRepository _repository;

  @override
  FutureResult<AppSettings> call(NoParams params) async {
    return _repository.getAppSettings();
  }
}
