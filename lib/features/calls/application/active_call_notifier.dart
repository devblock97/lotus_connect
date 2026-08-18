import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/calls/application/calls_providers.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_session.dart';
import 'package:lotus_connect/features/calls/domain/usecases/accept_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/end_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/initiate_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/send_sdp_usecase.dart';

/// StateNotifier managing active WebRTC call sessions and signaling state.
class ActiveCallNotifier extends StateNotifier<CallSession> {
  ActiveCallNotifier({
    required InitiateCallUseCase initiateCallUseCase,
    required AcceptCallUseCase acceptCallUseCase,
    required EndCallUseCase endCallUseCase,
    required SendSdpUseSase sendSdpUseCase,
  })  : _initiateCallUseCase = initiateCallUseCase,
        _acceptCallUseCase = acceptCallUseCase,
        _endCallUseCase = endCallUseCase,
        _sendSdpUseSase = sendSdpUseCase,
        super(const CallSession());

  final InitiateCallUseCase _initiateCallUseCase;
  final AcceptCallUseCase _acceptCallUseCase;
  final EndCallUseCase _endCallUseCase;
  final SendSdpUseSase _sendSdpUseSase;

  Future<void> startCall({
    required String peerId,
    required bool isVideo,
    required String channelId,
  }) async {
    state = CallSession(
      peerId: peerId,
      isVideo: isVideo,
      callId: channelId,
      state: CallState.dialing,
    );

    final result = await _initiateCallUseCase(
      InitiateCallParams(
        peerId: peerId,
        channelId: channelId,
        isVideo: isVideo,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        state: CallState.ended,
        callId: channelId,
        errorMessage: failure.message,
      ),
      (_) => null,
    );
  }

  Future<void> acceptCall(String callId, String recipientId) async {
    final result = await _acceptCallUseCase(
      AcceptCallParams(callId: callId, recipientId: recipientId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        state: CallState.ended,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(state: CallState.connected),
    );
  }

  Future<void> endCall(String callId, String recipientId) async {
    await _endCallUseCase(
      EndCallParams(callId: callId, recipientId: recipientId),
    );
    state = const CallSession();
  }

  Future<void> sendSdp(
    String recipientId,
    String sdpType,
    String sdpDescription,
  ) async {
    await _sendSdpUseSase(
      SendSdpParam(
        recipientId: recipientId,
        sdpType: sdpType,
        sdpDescription: sdpDescription,
      ),
    );
    state = const CallSession();
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleSpeaker() {
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  void toggleScreenSharing() {
    state = state.copyWith(isScreenSharing: !state.isScreenSharing);
  }
}

/// Global provider for ActiveCallNotifier.
final activeCallProvider =
    StateNotifierProvider<ActiveCallNotifier, CallSession>((ref) {
  return ActiveCallNotifier(
    initiateCallUseCase: ref.watch(initiateCallUseCaseProvider),
    acceptCallUseCase: ref.watch(acceptCallUseCaseProvider),
    endCallUseCase: ref.watch(endCallUseCaseProvider),
    sendSdpUseCase: ref.watch(sendSdpUseCaseProvider),
  );
});
