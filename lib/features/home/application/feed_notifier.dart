import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';

@immutable
class FeedState {
  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<PostItem> posts;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  FeedState copyWith({
    List<PostItem>? posts,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier({
    required GetFeedUseCase getFeedUseCase,
  })  : _getFeedUseCase = getFeedUseCase,
        super(const FeedState()) {
    loadFeed();
  }

  final GetFeedUseCase _getFeedUseCase;

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true);

    final result = await _getFeedUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          posts: state.posts,
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(
          posts: posts,
          isLoading: false,
        );
      },
    );
  }

  Future<void> refreshFeed() async {
    state = state.copyWith(isRefreshing: true);

    final result = await _getFeedUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isRefreshing: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(
          posts: posts.isNotEmpty ? posts : state.posts,
          isRefreshing: false,
        );
      },
    );
  }

  void toggleLike(String postId, {required bool isLiked}) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          final newCount = isLiked
              ? post.likeCount + 1
              : (post.likeCount > 0 ? post.likeCount - 1 : 0);
          return post.copyWith(
            userHasLiked: isLiked,
            likeCount: newCount,
          );
        }
        return post;
      }).toList(),
    );
  }

  void toggleSave(String postId, {required bool isSaved}) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isSaved: isSaved);
        }
        return post;
      }).toList(),
    );
  }
}
