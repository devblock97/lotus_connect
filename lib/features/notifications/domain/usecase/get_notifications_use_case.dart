import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';
import 'package:lotus_connect/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationParam extends Equatable {
  const GetNotificationParam({this.cursor, this.limit = 10});

  final String? cursor;
  final int limit;

  @override
  List<Object?> get props => [cursor, limit];
}

class GetNotificationsUseCase
    implements UseCase<List<AppNotification>, GetNotificationParam> {
  const GetNotificationsUseCase({required NotificationRepository repository})
      : _repository = repository;
  final NotificationRepository _repository;

  @override
  FutureResult<List<AppNotification>> call(GetNotificationParam params) async {
    return _repository.getNotifications(
      params.cursor,
      params.limit,
    );
  }
}
