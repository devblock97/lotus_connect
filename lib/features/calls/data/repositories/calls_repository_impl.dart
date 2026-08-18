import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/calls/data/data_sources/calls_remote_data_source.dart';
import 'package:lotus_connect/features/calls/data/data_sources/calls_signaling_data_source.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_session.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';

class CallsRepositoryImpl implements CallsRepository {
  CallsRepositoryImpl({
    required CallsRemoteDataSource remoteDataSource,
    required CallsSignalingDataSource signalingDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _signalingDataSource = signalingDataSource;

  final CallsRemoteDataSource _remoteDataSource;
  final CallsSignalingDataSource _signalingDataSource;

  @override
  FutureResult<List<CallLog>> getCallHistory() async {
    try {
      final models = await _remoteDataSource.getCallHistory();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to load call history: $e', e));
    }
  }

  @override
  FutureResult<void> initiateCall({
    required String peerId,
    required bool isVideo,
    required String channelId,
  }) async {
    try {
      await _signalingDataSource.sendInvite(
        targetUserId: peerId,
        isVideo: isVideo,
        channelId: channelId,
      );
      return const Right(null);
    } on Object catch (e) {
      return Left(ServerFailure('Failed to initiate call: $e', e));
    }
  }

  @override
  FutureResult<void> acceptCall({
    required String callId,
    required String recipientId,
  }) async {
    try {
      await _signalingDataSource.acceptCall(
        callId: callId,
        targetUserId: recipientId,
      );
      return const Right(null);
    } on Object catch (e) {
      return Left(ServerFailure('Failed to accept call: $e', e));
    }
  }

  @override
  FutureResult<void> endCall({
    required String callId,
    required String recipientId,
  }) async {
    try {
      await _signalingDataSource.endCall(
        callId: callId,
        targetUserId: recipientId,
      );
      return const Right(null);
    } on Object catch (e) {
      return Left(ServerFailure('Failed to end call: $e', e));
    }
  }

  @override
  StreamResult<CallSession> watchActiveCallSession() {
    return _signalingDataSource
        .watchActiveCallSession()
        .map<Result<CallSession>>(Right.new);
  }

  @override
  FutureResult<void> sendSdp({
    required String recipientId,
    required String sdpType,
    required String sdpDescription,
  }) async {
    await _signalingDataSource.sendSdp(
      recipientId: recipientId,
      sdpType: sdpType,
      sdpDescription: sdpDescription,
    );
    return const Right(null);
  }
}
