import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_dispatcher.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/features/chat/application/chat_application.dart';

final webSocketSyncCoordinatorProvider = Provider<void>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  final dispatcher = ref.watch(webSocketEventDispatcherProvider);

  final subscription = wsService.eventStream.listen(dispatcher.dispatch);

  final connectionSubscription =
      wsService.connectionStateStream.listen((isConnected) async {
    if (isConnected) {
      await ref
          .read(privateConversationListProvider.notifier)
          .loadRemoteConversations();

      final activeChatNotifier =
          ref.read(privateActiveConversationProvider.notifier);
      await activeChatNotifier.flushPendingMessages();

      await activeChatNotifier.syncCurrentConversation();
    }
  });

  ref.onDispose(() {
    subscription.cancel();
    connectionSubscription.cancel();
  });
});
