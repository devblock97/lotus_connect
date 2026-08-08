import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';

/// Structured incoming invitation models for WebRTC calling.
class WebRTCCallInvitation {
  WebRTCCallInvitation({
    required this.callId,
    required this.senderId,
    required this.conversationId,
    required this.channelId,
    required this.isVideo,
  });

  final String callId;
  final String senderId;
  final String? conversationId;
  final String channelId;
  final bool isVideo;
}

/// Service to handle WebRTC signaling exchange (SDP offers/answers & ICE candidates) over WebSockets.
class WebRTCSignalingService {
  WebRTCSignalingService({required this.webSocketService}) {
    _subscribeToWebSocket();
  }

  final WebSocketService webSocketService;
  StreamSubscription? _subscription;

  // Streams for calls UI to listen to call invitation/lifecycle changes
  final _invitationController =
      StreamController<WebRTCCallInvitation>.broadcast();
  final _acceptController = StreamController<Map<String, dynamic>>.broadcast();
  final _endController = StreamController<Map<String, dynamic>>.broadcast();
  final _sdpController = StreamController<Map<String, dynamic>>.broadcast();
  final _iceController = StreamController<Map<String, dynamic>>.broadcast();
  final _inviteAckController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<WebRTCCallInvitation> get invitationStream =>
      _invitationController.stream;
  Stream<Map<String, dynamic>> get acceptStream => _acceptController.stream;
  Stream<Map<String, dynamic>> get endStream => _endController.stream;
  Stream<Map<String, dynamic>> get sdpStream => _sdpController.stream;
  Stream<Map<String, dynamic>> get iceStream => _iceController.stream;
  Stream<Map<String, dynamic>> get inviteAckStream =>
      _inviteAckController.stream;

  void _subscribeToWebSocket() {
    _subscription = webSocketService.eventStream.listen((eventFrame) {
      final event = eventFrame['event'] as String?;
      final payload = eventFrame['payload'] as Map<String, dynamic>? ?? {};

      if (event == null) return;

      switch (event) {
        case 'call:invite':
          _invitationController.add(
            WebRTCCallInvitation(
              callId: payload['callId'] as String? ?? '',
              senderId: payload['senderId'] as String? ?? '',
              conversationId: payload['conversationId'] as String?,
              channelId: payload['channelId'] as String? ?? '',
              isVideo: payload['isVideo'] as bool? ?? false,
            ),
          );
        case 'call:accept':
          _acceptController.add(payload);
        case 'call:invite_ack':
          _inviteAckController.add(payload);
        case 'call:ended':
          _endController.add(payload);
        case 'signaling:offer':
        case 'signaling:answer':
          _sdpController.add({
            'type': event.split(':').last,
            'senderId': payload['senderId'],
            'sdp': payload['sdp'],
          });
        case 'signaling:ice-candidate':
          _iceController.add(payload);
      }
    });
  }

  /// Initiates / Invites a recipient user to join a WebRTC channel room call.
  void sendInvite({
    required String recipientId,
    required String channelId,
    required bool isVideo,
    String? conversationId,
  }) {
    webSocketService.send('call:invite', {
      'recipientId': recipientId,
      'channelId': channelId,
      'isVideo': isVideo,
      if (conversationId != null) 'conversationId': conversationId,
    });
  }

  /// Accepts a incoming call invitation.
  void acceptCall({
    required String callId,
    required String recipientId,
  }) {
    webSocketService.send('call:accept', {
      'callId': callId,
      'recipientId': recipientId,
    });
  }

  /// Terminates or declines a call.
  void endCall({
    required String callId,
    required String recipientId,
  }) {
    webSocketService.send('call:ended', {
      'callId': callId,
      'recipientId': recipientId,
    });
  }

  /// Distributes Local SDP Offer/Answer to remote peer.
  void sendSdp({
    required String recipientId,
    required String sdpType, // "offer" or "answer"
    required String sdpDescription,
  }) {
    webSocketService.send('signaling:$sdpType', {
      'recipientId': recipientId,
      'sdp': {
        'type': sdpType,
        'sdp': sdpDescription,
      },
    });
  }

  /// Distributes Local ICE Candidates to remote peer.
  void sendIceCandidate({
    required String recipientId,
    required String candidate,
    required String sdpMid,
    required int sdpMLineIndex,
  }) {
    webSocketService.send('signaling:ice-candidate', {
      'recipientId': recipientId,
      'candidate': {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      },
    });
  }

  /// Closes signaling stream subscriptions.
  void dispose() {
    _subscription?.cancel();
    _invitationController.close();
    _acceptController.close();
    _endController.close();
    _sdpController.close();
    _iceController.close();
    _inviteAckController.close();
  }
}

/// Global provider for WebRTC Call Signaling Service.
final webrtcSignalingServiceProvider = Provider<WebRTCSignalingService>((ref) {
  final webSocket = ref.watch(webSocketServiceProvider);
  final service = WebRTCSignalingService(webSocketService: webSocket);
  ref.onDispose(service.dispose);
  return service;
});
