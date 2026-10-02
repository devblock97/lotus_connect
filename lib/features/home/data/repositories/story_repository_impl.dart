import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/datasources/story_remote_data_source.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:lotus_connect/features/home/domain/repositories/story_repository.dart';

/// Implementation of [StoryRepository] coordinating remote story data sources.
class StoryRepositoryImpl implements StoryRepository {
  const StoryRepositoryImpl({
    required StoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final StoryRemoteDataSource _remoteDataSource;

  @override
  FutureResult<List<UserStory>> getStoriesTray() async {
    try {
      final stories = await _remoteDataSource.getStoriesTray();
      return Right(stories);
    } on Object catch (e) {
      AppLogger.error('StoryRepositoryImpl.getStoriesTray error: $e');
      return Left(ServerFailure('Failed to load stories tray: $e'));
    }
  }

  @override
  FutureResult<void> markStoryViewed(String storyId) async {
    try {
      await _remoteDataSource.markStoryViewed(storyId);
      return const Right(null);
    } on Object catch (e) {
      AppLogger.error('StoryRepositoryImpl.markStoryViewed error: $e');
      return Left(ServerFailure('Failed to mark story as viewed: $e'));
    }
  }

  @override
  FutureResult<void> reactToStory(String storyId, String reaction) async {
    try {
      await _remoteDataSource.reactToStory(storyId, reaction);
      return const Right(null);
    } on Object catch (e) {
      AppLogger.error('StoryRepositoryImpl.reactToStory error: $e');
      return Left(ServerFailure('Failed to react to story: $e'));
    }
  }

  @override
  FutureResult<void> replyToStory(String storyId, String message) async {
    try {
      await _remoteDataSource.replyToStory(storyId, message);
      return const Right(null);
    } on Object catch (e) {
      AppLogger.error('StoryRepositoryImpl.replyToStory error: $e');
      return Left(ServerFailure('Failed to reply to story: $e'));
    }
  }
}
