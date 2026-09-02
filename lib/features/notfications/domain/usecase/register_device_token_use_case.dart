import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notfications/domain/repositories/notification_repository.dart';

class RegisterDeviceTokenParam extends Equatable {
  const RegisterDeviceTokenParam({this.token, this.platform});

  final String? token;
  final String? platform;

  @override
  List<Object?> get props => [token, platform];
}

class RegisterDeviceTokenUseCase
    implements UseCase<ResponseEntityBase, RegisterDeviceTokenParam> {
  const RegisterDeviceTokenUseCase({required NotificationRepository repository})
      : _repository = repository;
  final NotificationRepository _repository;

  @override
  FutureResult<ResponseEntityBase> call(RegisterDeviceTokenParam params) async {
    return _repository.registerDeviceToken(
      token: params.token,
      platform: params.platform,
    );
  }
}
