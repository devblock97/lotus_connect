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

final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  return FeedRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    remoteDataSource: ref.watch(feedRemoteDataSourceProvider),
  );
});

final getFeedUseCaseProvider = Provider<GetFeedUseCase>((ref) {
  return GetFeedUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  return UpdatePostUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  return DeletePostUseCase(
    repository: ref.watch(feedRepositoryProvider),
  );
});

final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    getFeedUseCase: ref.watch(getFeedUseCaseProvider),
    deletePostUseCase: ref.watch(deletePostUseCaseProvider),
  );
});

final createPostNotifierProvider =
    StateNotifierProvider.autoDispose<CreatePostNotifier, CreatePostState>(
        (ref) {
  return CreatePostNotifier(
    createPostUseCase: ref.watch(createPostUseCaseProvider),
    updatePostUseCase: ref.watch(updatePostUseCaseProvider),
    feedNotifier: ref.watch(feedNotifierProvider.notifier),
  );
});
