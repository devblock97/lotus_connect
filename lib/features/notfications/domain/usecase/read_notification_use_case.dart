import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notfications/domain/repositories/notification_repository.dart';

class ReadNotificationParam extends Equatable {
  const ReadNotificationParam({required this.notificationId});
  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class ReadNotificationUseCase
    implements UseCase<ResponseEntityBase, ReadNotificationParam> {
  const ReadNotificationUseCase({required NotificationRepository repository})
      : _repository = repository;
  final NotificationRepository _repository;

  @override
  FutureResult<ResponseEntityBase> call(ReadNotificationParam params) async {
    return _repository.readNotification(params.notificationId);
  }
}
