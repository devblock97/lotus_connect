import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';

@immutable
class FeedState {
  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasReachedMax = false,
    this.errorMessage,
    this.cursor,
  });

  final List<PostItem> posts;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final String? cursor;
  final bool hasReachedMax;

  FeedState copyWith({
    List<PostItem>? posts,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    String? cursor,
    bool? hasReachedMax,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      cursor: cursor ?? this.cursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier({
    required GetFeedUseCase getFeedUseCase,
    DeletePostUseCase? deletePostUseCase,
    Duration debounceDuration = const Duration(milliseconds: 300),
  })  : _getFeedUseCase = getFeedUseCase,
        _deletePostUseCase = deletePostUseCase,
        _debounceDuration = debounceDuration,
        super(const FeedState()) {
    loadFeed();
  }

  final GetFeedUseCase _getFeedUseCase;
  final DeletePostUseCase? _deletePostUseCase;
  final Duration _debounceDuration;

  Timer? _debounceTimer;
  Completer<void>? _debounceCompleter;

  @visibleForTesting
  bool get isDebouncing => _debounceTimer?.isActive ?? false;

  Future<void> loadFeed() async {
    _cancelDebounce();
    state = state.copyWith(isLoading: true);

    final result = await _getFeedUseCase(
      const GetFeedParam(limit: 20),
    );

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
          cursor: posts.isNotEmpty ? posts.last.id : state.cursor,
          hasReachedMax: posts.isEmpty,
        );
      },
    );
  }

  /// Fetches next page of feed posts with debounce to prevent excessive API
  /// calls while scrolling.
  Future<void> loadMoreFeed({bool immediate = false}) {
    if (state.hasReachedMax || state.isLoading) {
      return Future.value();
    }

    _debounceTimer?.cancel();
    _debounceCompleter ??= Completer<void>();

    if (immediate || _debounceDuration == Duration.zero) {
      _executeLoadMore();
    } else {
      _debounceTimer = Timer(_debounceDuration, _executeLoadMore);
    }

    return _debounceCompleter!.future;
  }

  Future<void> _executeLoadMore() async {
    if (state.hasReachedMax || state.isLoading) {
      _completeDebounce();
      return;
    }

    state = state.copyWith(isLoading: true);

    final result = await _getFeedUseCase(
      GetFeedParam(cursor: state.cursor, limit: 10),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        final mergePosts = [...state.posts, ...posts];
        state = state.copyWith(
          posts: mergePosts,
          isLoading: false,
          cursor: mergePosts.isNotEmpty ? mergePosts.last.id : state.cursor,
          hasReachedMax: posts.isEmpty,
        );
      },
    );

    _completeDebounce();
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _completeDebounce();
  }

  void _completeDebounce() {
    if (_debounceCompleter != null && !_debounceCompleter!.isCompleted) {
      _debounceCompleter!.complete();
    }
    _debounceCompleter = null;
  }

  Future<void> refreshFeed() async {
    _cancelDebounce();
    state = state.copyWith(isRefreshing: true);

    final result = await _getFeedUseCase(const GetFeedParam(limit: 20));

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
          cursor: posts.isNotEmpty ? posts.last.id : state.cursor,
          hasReachedMax: false,
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _completeDebounce();
    super.dispose();
  }
}
