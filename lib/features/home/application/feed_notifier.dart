import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_post_usecase.dart';
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
    DeletePostUseCase? deletePostUseCase,
  })  : _getFeedUseCase = getFeedUseCase,
        _deletePostUseCase = deletePostUseCase,
        super(const FeedState()) {
    loadFeed();
  }

  final GetFeedUseCase _getFeedUseCase;
  final DeletePostUseCase? _deletePostUseCase;

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

  /// Prepends a newly created post at the very top of the home feed.
  void addPost(PostItem post) {
    state = state.copyWith(
      posts: [post, ...state.posts],
    );
  }

  /// Updates an existing post in the feed with newly edited data.
  void updatePost(PostItem updatedPost) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        return p.id == updatedPost.id ? updatedPost : p;
      }).toList(),
    );
  }

  /// Removes a post from the current feed (e.g. after deletion).
  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }

  /// Deletes a post via the backend API and removes it from the local feed.
  Future<bool> deletePost(String postId) async {
    if (_deletePostUseCase != null) {
      final result = await _deletePostUseCase(DeletePostParams(postId));
      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
          return false;
        },
        (success) {
          removePost(postId);
          return true;
        },
      );
    }
    removePost(postId);
    return true;
  }
}
