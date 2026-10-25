import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationRepository {
  FutureResult<ResponseEntityBase> registerDeviceToken({
    String? token,
    String? platform,
  });

  FutureResult<ResponseEntityBase> unregisterDeviceToken({String? token});

  FutureResult<List<AppNotification>> getNotifications(
    String? cursor,
    int limit,
  );

  FutureResult<ResponseEntityBase> markNotificationRead();

  FutureResult<ResponseEntityBase> readNotification(String notificationId);
}
