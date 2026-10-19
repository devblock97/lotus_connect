import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/data/datasources/livestream_remote_data_source.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_cohost.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_leaderboard_item.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_viewer.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class LiveStreamRepositoryImpl implements LiveStreamRepository {
  const LiveStreamRepositoryImpl({
    required LiveStreamRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final LiveStreamRemoteDataSource _remoteDataSource;

  @override
  FutureResult<LiveStream> createStream({
    required String title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) async {
    try {
      final response = await _remoteDataSource.createStream(
        title: title,
        description: description,
        thumbnailUrl: thumbnailUrl,
        privacy: privacy,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to create stream: $e', e));
    }
  }

  @override
  FutureResult<LiveStream> getStream(String streamId) async {
    try {
      final response = await _remoteDataSource.getStream(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to get stream: $e', e));
    }
  }

  @override
  Future<LiveStream> updateStream(
    String streamId, {
    String? title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) {
    return _remoteDataSource.updateStream(
      streamId,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      privacy: privacy,
    );
  }

  @override
  FutureResult<LiveStream> startStream(String streamId) async {
    try {
      final response = await _remoteDataSource.startStream(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to start stream: $e', e));
    }
  }

  @override
  Future<LiveStream> endStream(String streamId, {String? recordingUrl}) {
    return _remoteDataSource.endStream(
      streamId,
      recordingUrl: recordingUrl,
    );
  }

  @override
  Future<List<LiveStream>> listStreams({
    String? status,
    String? cursor,
    int? limit,
  }) {
    return _remoteDataSource.listStreams(
      status: status,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<List<LiveStream>> listMyStreams({
    String? cursor,
    int? limit,
  }) {
    return _remoteDataSource.listMyStreams(
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<void> joinStream(String streamId) {
    return _remoteDataSource.joinStream(streamId);
  }

  @override
  Future<void> leaveStream(String streamId) {
    return _remoteDataSource.leaveStream(streamId);
  }

  @override
  Future<List<LiveViewer>> listViewers(String streamId, {int? limit}) {
    return _remoteDataSource.listViewers(streamId, limit: limit);
  }

  @override
  Future<List<LiveComment>> listComments(
    String streamId, {
    String? cursor,
    int? limit,
  }) {
    return _remoteDataSource.listComments(
      streamId,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<LiveComment> sendComment(String streamId, String content) {
    return _remoteDataSource.sendComment(streamId, content);
  }

  @override
  Future<void> pinComment(String streamId, String commentId) {
    return _remoteDataSource.pinComment(streamId, commentId);
  }

  @override
  Future<void> unpinComment(String streamId, String commentId) {
    return _remoteDataSource.unpinComment(streamId, commentId);
  }

  @override
  Future<int> sendReaction(
    String streamId, {
    String reaction = 'heart',
    int count = 1,
  }) {
    return _remoteDataSource.sendReaction(
      streamId,
      reaction: reaction,
      count: count,
    );
  }

  @override
  Future<LiveGiftEvent> sendGift(
    String streamId, {
    required String giftType,
    int count = 1,
  }) {
    return _remoteDataSource.sendGift(
      streamId,
      giftType: giftType,
      count: count,
    );
  }

  @override
  Future<List<LiveLeaderboardItem>> getLeaderboard(String streamId) {
    return _remoteDataSource.getLeaderboard(streamId);
  }

  @override
  Future<LiveCohost> requestCohost(String streamId) {
    return _remoteDataSource.requestCohost(streamId);
  }

  @override
  Future<LiveCohost> respondCohost(
    String streamId, {
    required String userId,
    required String action,
  }) {
    return _remoteDataSource.respondCohost(
      streamId,
      userId: userId,
      action: action,
    );
  }

  @override
  Future<void> leaveCohost(String streamId) {
    return _remoteDataSource.leaveCohost(streamId);
  }

  @override
  Future<List<LiveCohost>> listCohosts(String streamId) {
    return _remoteDataSource.listCohosts(streamId);
  }
}
