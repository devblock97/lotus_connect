import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:lotus_connect/features/chat/application/presence_notifier.dart';

class PresenceHandler implements WebSocketEventHandler {
  PresenceHandler(this._presenceNotifier);
  final PresenceNotifier _presenceNotifier;

  @override
  Future<void> handle(String event, Map<String, dynamic> payload) async {
    final userId = payload['userId'] as String? ?? '';
    final isOnline = payload['isOnline'] as bool? ?? false;
    final lastSeenStr = payload['lastSeen'] as String?;
    final lastSeen = lastSeenStr != null
        ? DateTime.tryParse(lastSeenStr) ?? DateTime.now()
        : DateTime.now();
    _presenceNotifier.updatePresence(userId, isOnline, lastSeen);
  }

  @override
  List<String> get supportedEvents => ['presence:status'];
}

final presenceHandler = Provider<PresenceHandler>((ref) {
  return PresenceHandler(ref.watch(presenceProvider.notifier));
});
