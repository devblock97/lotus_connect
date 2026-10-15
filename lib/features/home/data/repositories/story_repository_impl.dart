import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/datasources/story_remote_data_source.dart';
import 'package:lotus_connect/features/home/domain/entities/create_story_params.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
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

  @override
  FutureResult<Story> createStory(CreateStoryParams params) async {
    try {
      final story = await _remoteDataSource.createStory(
        mediaType: params.mediaType,
        mediaUrl: params.mediaUrl ?? '',
        thumbnailUrl: params.thumbnailUrl,
        caption: params.caption,
        duration: params.duration,
        visibility: params.visibility,
        backgroundColor: params.backgroundColor,
        metadata: params.metadata,
      );
      return Right(story);
    } on Object catch (e) {
      AppLogger.error('StoryRepositoryImpl.createStory error: $e');
      return Left(ServerFailure('Failed to create story: $e'));
    }
  }

  @override
  FutureResult<List<String>> uploadStoryMedia(List<String> filePaths) async {
    try {
      final urls = await _remoteDataSource.uploadFiles(filePaths);
      return Right(urls);
    } on Object catch (e) {
      AppLogger.error('StoryRepositoryImpl.uploadStoryMedia error: $e');
      return Left(ServerFailure('Failed to upload story media: $e'));
    }
  }

  @override
  FutureResult<bool> deleteStory(String storyId) async {
    try {
      final success = await _remoteDataSource.deleteStory(storyId);
      return Right(success);
    } on Object catch (e) {
      AppLogger.error('StoryRepositoryImpl.deleteStory error: $e');
      return Left(ServerFailure('Failed to delete story: $e'));
    }
  }
}
