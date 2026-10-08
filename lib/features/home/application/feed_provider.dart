import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/application/create_post_notifier.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/data/datasources/feed_remote_data_source.dart';
import 'package:lotus_connect/features/home/data/repositories/feed_repository_impl.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_post_usecase.dart';

/// Provider for [FeedRemoteDataSource].
final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  return FeedRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

/// Provider for [FeedRepository].
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    remoteDataSource: ref.watch(feedRemoteDataSourceProvider),
  );
});

/// Provider for [GetFeedUseCase].
final getFeedUseCaseProvider = Provider<GetFeedUseCase>((ref) {
  return GetFeedUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

/// Provider for [CreatePostUseCase].
final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

/// Provider for [UpdatePostUseCase].
final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  return UpdatePostUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

/// Provider for [DeletePostUseCase].
final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  return DeletePostUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

/// Provider managing the active feed state.
final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    getFeedUseCase: ref.watch(getFeedUseCaseProvider),
    deletePostUseCase: ref.watch(deletePostUseCaseProvider),
  );
});

/// Provider managing the create/edit post screen state.
final createPostNotifierProvider =
    StateNotifierProvider.autoDispose<CreatePostNotifier, CreatePostState>(
        (ref) {
  return CreatePostNotifier(
    createPostUseCase: ref.watch(createPostUseCaseProvider),
    updatePostUseCase: ref.watch(updatePostUseCaseProvider),
    feedNotifier: ref.watch(feedNotifierProvider.notifier),
  );
});
