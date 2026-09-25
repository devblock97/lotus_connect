import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/settings/domain/repositories/settings_repository.dart';

class UpdateAppSettingParam extends Equatable {
  const UpdateAppSettingParam({required this.settings});

  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}

class UpdateAppSettingUseCase implements UseCase<void, UpdateAppSettingParam> {
  UpdateAppSettingUseCase({required SettingsRepository repository})
      : _repository = repository;

  final SettingsRepository _repository;

  @override
  FutureResult<void> call(UpdateAppSettingParam params) async {
    return _repository.updateAppSettings(params.settings);
  }
}
