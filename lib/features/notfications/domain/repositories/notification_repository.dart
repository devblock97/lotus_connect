import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notfications/application/notifications_notifier.dart';

abstract class NotificationRepository {
  FutureResult<ResponseEntityBase> registerDeviceToken({
    String? token,
    String? platform,
  });

  FutureResult<ResponseEntityBase> unregisterDeviceToken({String? token});

  FutureResult<List<AppNotification>> getNotifications();

  FutureResult<ResponseEntityBase> markNotificationRead();

  FutureResult<ResponseEntityBase> readNotification(String notificationId);
}
