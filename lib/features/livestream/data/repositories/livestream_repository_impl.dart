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
  FutureResult<LiveStream> updateStream(
    String streamId, {
    String? title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) async {
    try {
      final response = await _remoteDataSource.updateStream(
        streamId,
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
      return Left(ServerFailure('Failed to get stream $e', e));
    }
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
  FutureResult<LiveStream> endStream(
    String streamId, {
    String? recordingUrl,
  }) async {
    try {
      final response = await _remoteDataSource.endStream(
        streamId,
        recordingUrl: recordingUrl,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to end stream $e', e));
    }
  }

  @override
  FutureResult<List<LiveStream>> listStreams({
    String? status,
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.listStreams(
        status: status,
        cursor: cursor,
        limit: limit,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to load list streams: $e', e));
    }
  }

  @override
  FutureResult<List<LiveStream>> listMyStreams({
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.listMyStreams(
        cursor: cursor,
        limit: limit,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to load your streams list: $e', e));
    }
  }

  @override
  FutureResult<void> joinStream(String streamId) async {
    try {
      final response = await _remoteDataSource.joinStream(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(NetworkFailure('Failed to join stream: $e', e));
    }
  }

  @override
  FutureResult<void> leaveStream(String streamId) async {
    try {
      final response = await _remoteDataSource.leaveStream(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(NetworkFailure('Failed to leave stream: $e', e));
    }
  }

  @override
  FutureResult<List<LiveViewer>> listViewers(
    String streamId, {
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.listViewers(
        streamId,
        limit: limit,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(NetworkFailure('Failed to get list viewers: $e', e));
    }
  }

  @override
  FutureResult<List<LiveComment>> listComments(
    String streamId, {
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.listComments(
        streamId,
        cursor: cursor,
        limit: limit,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(NetworkFailure('Failed to get list comments: $e', e));
    }
  }

  @override
  FutureResult<LiveComment> sendComment(String streamId, String content) async {
    try {
      final response = await _remoteDataSource.sendComment(streamId, content);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(NetworkFailure('Failed to send comment: $e', e));
    }
  }

  @override
  FutureResult<void> pinComment(String streamId, String commentId) async {
    try {
      final response = await _remoteDataSource.pinComment(streamId, commentId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on NetworkFailure catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to pin comment: $e', e));
    }
  }

  @override
  FutureResult<void> unpinComment(String streamId, String commentId) async {
    try {
      final response =
          await _remoteDataSource.unpinComment(streamId, commentId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to unpin comment: $e', e));
    }
  }

  @override
  FutureResult<int> sendReaction(
    String streamId, {
    String reaction = 'heart',
    int count = 1,
  }) async {
    try {
      final response = await _remoteDataSource.sendReaction(
        streamId,
        reaction: reaction,
        count: count,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to send reaction: $e', e));
    }
  }

  @override
  FutureResult<LiveGiftEvent> sendGift(
    String streamId, {
    required String giftType,
    int count = 1,
  }) async {
    try {
      final response = await _remoteDataSource.sendGift(
        streamId,
        giftType: giftType,
        count: count,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to send gift: $e', e));
    }
  }

  @override
  FutureResult<List<LiveLeaderboardItem>> getLeaderboard(
    String streamId,
  ) async {
    try {
      final response = await _remoteDataSource.getLeaderboard(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to get leader board: $e', e));
    }
  }

  @override
  FutureResult<LiveCohost> requestCohost(String streamId) async {
    try {
      final response = await _remoteDataSource.requestCohost(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to request cohost: $e', e));
    }
  }

  @override
  FutureResult<LiveCohost> respondCohost(
    String streamId, {
    required String userId,
    required String action,
  }) async {
    try {
      final response = await _remoteDataSource.respondCohost(
        streamId,
        userId: userId,
        action: action,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(NetworkFailure('Failed to request cohost: $e', e));
    }
  }

  @override
  FutureResult<void> leaveCohost(String streamId) async {
    try {
      final response = await _remoteDataSource.leaveCohost(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to leave cohost: $e', e));
    }
  }

  @override
  FutureResult<List<LiveCohost>> listCohosts(String streamId) async {
    try {
      final response = await _remoteDataSource.listCohosts(streamId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to load list cohosts: $e', e));
    }
  }
}
