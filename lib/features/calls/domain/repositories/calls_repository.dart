import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_session.dart';

abstract class CallsRepository {
  /// Fetches historical call records for the current user.
  FutureResult<List<CallLog>> getCallHistory();

  /// Initiates an outgoing WebRTC call session to a target peer.
  FutureResult<void> initiateCall({
    required String peerId,
    required bool isVideo,
    required String channelId,
  });

  /// Accepts an incoming WebRTC call session.
  FutureResult<void> acceptCall({
    required String callId,
    required String recipientId,
  });

  /// Ends/hangs up an active call session.
  FutureResult<void> endCall({
    required String callId,
    required String recipientId,
  });

  FutureResult<void> sendSdp({
    required String recipientId,
    required String sdpType,
    required String sdpDescription,
  });

  /// Streams real-time updates for active WebRTC call sessions.
  StreamResult<CallSession> watchActiveCallSession();
}
