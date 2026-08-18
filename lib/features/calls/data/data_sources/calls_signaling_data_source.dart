import 'dart:async';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_session.dart';

abstract class CallsSignalingDataSource {
  Future<void> sendInvite({
    required String targetUserId,
    required bool isVideo,
    required String channelId,
  });

  Future<void> acceptCall({
    required String callId,
    required String targetUserId,
  });

  Future<void> endCall({
    required String callId,
    required String targetUserId,
  });

  Future<void> sendSdp({
    required String recipientId,
    required String sdpType,
    required String sdpDescription,
  });

  Stream<CallSession> watchActiveCallSession();
}

class CallsSignalingDataSourceImpl implements CallsSignalingDataSource {
  CallsSignalingDataSourceImpl({
    required WebRTCSignalingService signalingService,
  }) : _signalingService = signalingService {
    _initListeners();
  }

  final WebRTCSignalingService _signalingService;
  final StreamController<CallSession> _sessionController =
      StreamController<CallSession>.broadcast();
  CallSession _currentSession = const CallSession();
  StreamSubscription? _invitationSub;
  StreamSubscription? _endSub;

  void _initListeners() {
    _invitationSub = _signalingService.invitationStream.listen((invitation) {
      _currentSession = CallSession(
        callId: invitation.callId,
        peerId: invitation.senderId,
        isVideo: invitation.isVideo,
        state: CallState.ringing,
      );
      _sessionController.add(_currentSession);
    });

    _endSub = _signalingService.endStream.listen((payload) {
      _currentSession = _currentSession.copyWith(state: CallState.ended);
      _sessionController.add(_currentSession);
      _currentSession = const CallSession();
      _sessionController.add(_currentSession);
    });
  }

  @override
  Future<void> sendInvite({
    required String targetUserId,
    required bool isVideo,
    required String channelId,
  }) async {
    final callId = DateTime.now().millisecondsSinceEpoch.toString();
    _currentSession = CallSession(
      callId: callId,
      peerId: targetUserId,
      isVideo: isVideo,
      state: CallState.dialing,
    );
    _sessionController.add(_currentSession);

    _signalingService.sendInvite(
      recipientId: targetUserId,
      channelId: callId,
      isVideo: isVideo,
    );
  }

  @override
  Future<void> acceptCall({
    required String callId,
    required String targetUserId,
  }) async {
    _currentSession = _currentSession.copyWith(state: CallState.connected);
    _sessionController.add(_currentSession);

    _signalingService.acceptCall(
      callId: callId,
      recipientId: targetUserId,
    );
  }

  @override
  Future<void> endCall({
    required String callId,
    required String targetUserId,
  }) async {
    _signalingService.endCall(
      callId: callId,
      recipientId: targetUserId,
    );
    _currentSession = _currentSession.copyWith(state: CallState.ended);
    _sessionController.add(_currentSession);
    _currentSession = const CallSession();
    _sessionController.add(_currentSession);
  }

  @override
  Future<void> sendSdp({
    required String recipientId,
    required String sdpType,
    required String sdpDescription,
  }) async {
    _signalingService.sendSdp(
      recipientId: recipientId,
      sdpType: sdpType,
      sdpDescription: sdpDescription,
    );
  }

  @override
  Stream<CallSession> watchActiveCallSession() => _sessionController.stream;

  void dispose() {
    _invitationSub?.cancel();
    _endSub?.cancel();
    _sessionController.close();
  }
}
