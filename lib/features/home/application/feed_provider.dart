import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/data/datasources/feed_remote_data_source.dart';
import 'package:lotus_connect/features/home/data/repositories/feed_repository_impl.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';

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

/// Provider managing the active feed state.
final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    getFeedUseCase: ref.watch(getFeedUseCaseProvider),
  );
});
