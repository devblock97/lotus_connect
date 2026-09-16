import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_dispatcher.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';

final webSocketSyncCoordinatorProvider = Provider<void>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  final dispatcher = ref.watch(webSocketEventDispatcherProvider);

  final subscription = wsService.eventStream.listen(dispatcher.dispatch);

  ref.onDispose(subscription.cancel);
});
