import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/application/story_notifier.dart';
import 'package:lotus_connect/features/home/data/datasources/story_remote_data_source.dart';
import 'package:lotus_connect/features/home/data/repositories/story_repository_impl.dart';
import 'package:lotus_connect/features/home/domain/repositories/story_repository.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_stories_tray_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/mark_story_viewed_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/react_to_story_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/reply_to_story_usecase.dart';

/// Provider for [StoryRemoteDataSource].
final storyRemoteDataSourceProvider = Provider<StoryRemoteDataSource>((ref) {
  return StoryRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

/// Provider for [StoryRepository].
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepositoryImpl(
    remoteDataSource: ref.watch(storyRemoteDataSourceProvider),
  );
});

/// Provider for [GetStoriesTrayUseCase].
final getStoriesTrayUseCaseProvider = Provider<GetStoriesTrayUseCase>((ref) {
  return GetStoriesTrayUseCase(
    repository: ref.watch(storyRepositoryProvider),
  );
});

/// Provider for [MarkStoryViewedUseCase].
final markStoryViewedUseCaseProvider = Provider<MarkStoryViewedUseCase>((ref) {
  return MarkStoryViewedUseCase(
    repository: ref.watch(storyRepositoryProvider),
  );
});

/// Provider for [ReactToStoryUseCase].
final reactToStoryUseCaseProvider = Provider<ReactToStoryUseCase>((ref) {
  return ReactToStoryUseCase(
    repository: ref.watch(storyRepositoryProvider),
  );
});

/// Provider for [ReplyToStoryUseCase].
final replyToStoryUseCaseProvider = Provider<ReplyToStoryUseCase>((ref) {
  return ReplyToStoryUseCase(
    repository: ref.watch(storyRepositoryProvider),
  );
});

/// Provider managing the active stories tray state.
final storiesNotifierProvider =
    StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  return StoriesNotifier(
    getStoriesTrayUseCase: ref.watch(getStoriesTrayUseCaseProvider),
    markStoryViewedUseCase: ref.watch(markStoryViewedUseCaseProvider),
    reactToStoryUseCase: ref.watch(reactToStoryUseCaseProvider),
    replyToStoryUseCase: ref.watch(replyToStoryUseCaseProvider),
  );
});
