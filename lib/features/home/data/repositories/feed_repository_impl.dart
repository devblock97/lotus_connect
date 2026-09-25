import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/datasources/feed_remote_data_source.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';

/// Implementation of [FeedRepository] coordinating data sources.
class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl({
    required FeedRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final FeedRemoteDataSource _remoteDataSource;

  @override
  FutureResult<List<PostItem>> getFeed() async {
    try {
      final posts = await _remoteDataSource.getFeed();
      return Right(posts);
    } on Object catch (e) {
      AppLogger.error('FeedRepositoryImpl.getFeed error: $e');
      return Left(ServerFailure('Failed to load feed: $e'));
    }
  }
}
