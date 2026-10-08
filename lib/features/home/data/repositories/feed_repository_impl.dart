import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/datasources/feed_remote_data_source.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
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

  @override
  FutureResult<PostItem> createPost({
    String? content,
    List<PostMediaItem>? mediaItems,
    String visibility = 'public',
  }) async {
    try {
      final post = await _remoteDataSource.createPost(
        content: content,
        mediaItems: mediaItems,
        visibility: visibility,
      );
      return Right(post);
    } on Object catch (e) {
      AppLogger.error('FeedRepositoryImpl.createPost error: $e');
      return Left(ServerFailure('Failed to create post: $e'));
    }
  }

  @override
  FutureResult<PostItem> updatePost({
    required String postId,
    String? content,
    List<PostMediaItem>? mediaItems,
    String? visibility,
  }) async {
    try {
      final post = await _remoteDataSource.updatePost(
        postId: postId,
        content: content,
        mediaItems: mediaItems,
        visibility: visibility,
      );
      return Right(post);
    } on Object catch (e) {
      AppLogger.error('FeedRepositoryImpl.updatePost error: $e');
      return Left(ServerFailure('Failed to update post: $e'));
    }
  }

  @override
  FutureResult<List<PostMediaItem>> uploadFiles(List<String> filePaths) async {
    try {
      final items = await _remoteDataSource.uploadFiles(filePaths);
      return Right(items);
    } on Object catch (e) {
      AppLogger.error('FeedRepositoryImpl.uploadFiles error: $e');
      return Left(ServerFailure('Failed to upload media: $e'));
    }
  }

  @override
  FutureResult<bool> deletePost(String postId) async {
    try {
      final success = await _remoteDataSource.deletePost(postId);
      return Right(success);
    } on Object catch (e) {
      AppLogger.error('FeedRepositoryImpl.deletePost error: $e');
      return Left(ServerFailure('Failed to delete post: $e'));
    }
  }
}
