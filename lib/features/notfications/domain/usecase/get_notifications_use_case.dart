import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notfications/application/notifications_notifier.dart';
import 'package:lotus_connect/features/notfications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase
    implements UseCase<List<AppNotification>, NoParams> {
  const GetNotificationsUseCase({required NotificationRepository repository})
      : _repository = repository;
  final NotificationRepository _repository;

  @override
  FutureResult<List<AppNotification>> call(NoParams params) async {
    return _repository.getNotifications();
  }
}
