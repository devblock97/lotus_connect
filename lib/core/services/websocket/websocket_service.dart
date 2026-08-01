import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';

/// Service managing dynamic, resilient WebSocket connections to the Rust gateway.
class WebSocketService {
  WebSocketService(this._ref);

  final Ref _ref;
  WebSocket? _socket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  int _reconnectDelaySeconds = 2;

  // Stream controller to broadcast all parsed WebSocket frames
  final _eventStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Exposes incoming events stream from the server.
  Stream<Map<String, dynamic>> get eventStream => _eventStreamController.stream;

  /// Connection state helper.
  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  /// Initiates connection using credentials from settings.
  Future<void> connect() async {
    if (isConnected) return;
    _cancelReconnect();

    final settings = _ref.read(settingsProvider);
    final token = settings.accessToken;
    final serverHost = settings.serverHost;

    if (token.isEmpty) {
      AppLogger.warning('WS Connection aborted: Access Token is empty');
      return;
    }

    final wsUrl = _buildWsUrl(serverHost, token);
    AppLogger.info('WS Connecting to: $wsUrl');

    try {
      _socket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 10));
      _reconnectDelaySeconds = 2;
      AppLogger.info('WS Connected successfully');

      // Start listening and heartbeat loop
      _socket!.listen(
        _onMessageReceived,
        onError: _onConnectionError,
        onDone: _onConnectionClosed,
        cancelOnError: true,
      );

      _startHeartbeat();
    } catch (e) {
      AppLogger.error('WS Connection failed: $e');
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
    _stopHeartbeat();
    _cancelReconnect();
    AppLogger.info('WS Disconnected');
  }

  void send(String event, Map<String, dynamic> payload) {
    if (!isConnected) {
      AppLogger.warning('WS Send aborted: Socket is not open');
      return;
    }

    final envelope = {
      'event': event,
      'payload': payload,
    };
    final jsonStr = json.encode(envelope);
    _socket!.add(jsonStr);
  }

  void sendTyping({
    required String recipientId,
    required String conversationId,
    required bool isTyping,
  }) {
    send('typing', {
      'recipientId': recipientId,
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void sendChatMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) {
    send('chat:message', {
      'conversationId': conversationId,
      'content': content,
      if (replyToId != null) 'replyToId': replyToId,
    });
  }

  void sendReadReceipt(String messageId) {
    send('chat:read', {
      'messageId': messageId,
    });
  }

  void _onMessageReceived(dynamic message) {
    try {
      final decoded = json.decode(message.toString()) as Map<String, dynamic>;
      _eventStreamController.add(decoded);
    } catch (e) {
      AppLogger.error('WS Parsing error on frame: $message, error: $e');
    }
  }

  void _onConnectionError(dynamic error) {
    AppLogger.error('WS Socket error encountered: $error');
    _scheduleReconnect();
  }

  void _onConnectionClosed() {
    AppLogger.warning('WS Connection closed by host');
    _socket = null;
    _stopHeartbeat();
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    // Heartbeat Interval: 30 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isConnected) {
        send('heartbeat', {});
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    _socket = null;
    _stopHeartbeat();
    _reconnectTimer?.cancel();

    AppLogger.info('WS Reconnecting in $_reconnectDelaySeconds seconds...');
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelaySeconds), () {
      _reconnectDelaySeconds = (_reconnectDelaySeconds * 2).clamp(2, 60);
      connect();
    });
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  String _buildWsUrl(String restUrl, String token) {
    var wsBase = restUrl
        .replaceAll('https://', 'wss://')
        .replaceAll('http://', 'ws://');
    if (!wsBase.endsWith('/')) {
      wsBase = '$wsBase/';
    }
    return '${wsBase}ws?token=$token';
  }

  /// Disposes of active resources.
  void dispose() {
    _isDisposed = true;
    disconnect();
    _eventStreamController.close();
  }
}

/// Global provider for WebSocket client service.
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService(ref);
  ref.onDispose(service.dispose);
  return service;
});
