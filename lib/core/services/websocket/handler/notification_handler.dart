import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/notfications/application/notifications_notifier.dart';

class NotificationHandler implements WebSocketEventHandler {
  NotificationHandler(this._notificationsNotifier);

  final NotificationsNotifier _notificationsNotifier;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    await _notificationsNotifier.loadNotifications();
  }

  @override
  List<String> get supportedEvents => ['notification:new'];
}

final notificationWebSocketHandler = Provider<NotificationHandler>((ref) {
  return NotificationHandler(ref.watch(notificationsProvider.notifier));
});
