import 'package:equatable/equatable.dart';

/// Enumeration of possible WebRTC call session states.
enum CallState {
  idle,
  dialing,
  ringing,
  connected,
  ended,
}

/// Pure Dart domain entity representing an active WebRTC call session.
class CallSession extends Equatable {
  const CallSession({
    this.callId,
    this.peerId,
    this.peerName,
    this.isVideo = false,
    this.state = CallState.idle,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isScreenSharing = false,
    this.errorMessage,
  });

  final String? callId;
  final String? peerId;
  final String? peerName;
  final bool isVideo;
  final CallState state;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isScreenSharing;
  final String? errorMessage;

  bool get isActive =>
      state == CallState.dialing ||
      state == CallState.ringing ||
      state == CallState.connected;

  CallSession copyWith({
    String? callId,
    String? peerId,
    String? peerName,
    bool? isVideo,
    CallState? state,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isScreenSharing,
    String? errorMessage,
  }) {
    return CallSession(
      callId: callId ?? this.callId,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      isVideo: isVideo ?? this.isVideo,
      state: state ?? this.state,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        callId,
        peerId,
        peerName,
        isVideo,
        state,
        isMuted,
        isSpeakerOn,
        isScreenSharing,
        errorMessage,
      ];
}
