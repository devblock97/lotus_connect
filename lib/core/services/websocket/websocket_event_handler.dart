abstract class WebSocketEventHandler {
  /// List of event names this handler responds
  /// (e.g ['chat:message', 'chat:delete'])
  List<String> get supportedEvents;

  /// Processes the event frame payload and executes appropriate business/data actions
  Future<void> handle(String event, Map<String, dynamic> payload);
}
