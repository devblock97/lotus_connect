import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notfications/domain/repositories/notification_repository.dart';

class UnregisterDeviceTokenParam extends Equatable {
  const UnregisterDeviceTokenParam({this.token});
  final String? token;

  @override
  List<Object?> get props => [token];
}

class UnregisterDeviceTokenUseCase
    implements UseCase<ResponseEntityBase, UnregisterDeviceTokenParam> {
  const UnregisterDeviceTokenUseCase({
    required NotificationRepository repository,
  }) : _repository = repository;

  final NotificationRepository _repository;

  @override
  FutureResult<ResponseEntityBase> call(UnregisterDeviceTokenParam params) {
    return _repository.unregisterDeviceToken(token: params.token);
  }
}
