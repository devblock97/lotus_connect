import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comment_by_id_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comment_replies_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/pin_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/react_to_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/upload_comment_media_usecase.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';

enum CommentStatus { initial, loading, success, failure, refresh }

@immutable
class CommentState {
  const CommentState({
    this.postId,
    this.comments = const [],
    this.status = CommentStatus.initial,
    this.isSubmitting = false,
    this.errorMessage,
    this.sort = CommentSortOrder.popular,
    this.replyingTo,
    this.loadingReplyCommentIds = const {},
    this.isInitialized = false,
    this.hasReachedMax = false,
    this.cursor,
  });

  final String? postId;
  final List<CommentUiModel> comments;
  final bool isSubmitting;
  final String? errorMessage;
  final CommentSortOrder sort;
  final CommentUiModel? replyingTo;
  final Set<String> loadingReplyCommentIds;
  final bool isInitialized;
  final CommentStatus status;
  final bool hasReachedMax;
  final String? cursor;

  bool get isEmpty => comments.isEmpty;

  CommentState copyWith({
    String? postId,
    List<CommentUiModel>? comments,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    CommentSortOrder? sort,
    CommentUiModel? replyingTo,
    bool clearReplyingTo = false,
    Set<String>? loadingReplyCommentIds,
    bool? isInitialized,
    CommentStatus? status,
    bool? hasReachedMax,
    String? cursor,
    bool clearCursor = false,
  }) {
    return CommentState(
      postId: postId ?? this.postId,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sort: sort ?? this.sort,
      replyingTo: clearReplyingTo ? null : (replyingTo ?? this.replyingTo),
      loadingReplyCommentIds:
          loadingReplyCommentIds ?? this.loadingReplyCommentIds,
      isInitialized: isInitialized ?? this.isInitialized,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
    );
  }
}

class CommentNotifier extends StateNotifier<CommentState> {
  CommentNotifier({
    required GetCommentsUseCase getCommentsUseCase,
    required CreateCommentUseCase createCommentUseCase,
    required GetCommentByIdUseCase getCommentByIdUseCase,
    required GetCommentRepliesUseCase getCommentRepliesUseCase,
    required UpdateCommentUseCase updateCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
    required ReactToCommentUseCase reactToCommentUseCase,
    required PinCommentUseCase pinCommentUseCase,
    UploadCommentMediaUseCase? uploadCommentMediaUseCase,
    String? postId,
    List<CommentUiModel>? initialComments,
    Duration debounceDuration = const Duration(milliseconds: 300),
  })  : _getCommentsUseCase = getCommentsUseCase,
        _createCommentUseCase = createCommentUseCase,
        _getCommentByIdUseCase = getCommentByIdUseCase,
        _getCommentRepliesUseCase = getCommentRepliesUseCase,
        _updateCommentUseCase = updateCommentUseCase,
        _deleteCommentUseCase = deleteCommentUseCase,
        _reactToCommentUseCase = reactToCommentUseCase,
        _pinCommentUseCase = pinCommentUseCase,
        _uploadCommentMediaUseCase = uploadCommentMediaUseCase,
        _debounceDuration = debounceDuration,
        super(
          CommentState(
            postId: postId,
            comments: initialComments ?? const [],
            isInitialized: initialComments != null,
          ),
        );

  final GetCommentsUseCase _getCommentsUseCase;
  final CreateCommentUseCase _createCommentUseCase;
  final GetCommentByIdUseCase _getCommentByIdUseCase;
  final GetCommentRepliesUseCase _getCommentRepliesUseCase;
  final UpdateCommentUseCase _updateCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;
  final ReactToCommentUseCase _reactToCommentUseCase;
  final PinCommentUseCase _pinCommentUseCase;
  final UploadCommentMediaUseCase? _uploadCommentMediaUseCase;

  final int _pageSize = 10;

  Timer? _debounceTimer;
  Completer<void>? _debounceCompleter;
  final Duration _debounceDuration;

  @visibleForTesting
  bool get isDebouncing => _debounceTimer?.isActive ?? false;

  void _completeDebounce() {
    if (_debounceCompleter != null && !_debounceCompleter!.isCompleted) {
      _debounceCompleter!.complete();
    }
    _debounceCompleter = null;
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _completeDebounce();
  }

  void initialize({
    String? postId,
    List<CommentUiModel>? initialComments,
    bool? isLoading,
  }) {
    final effectiveSort = state.sort;
    final effectiveComments = initialComments != null
        ? _sortComments(initialComments, effectiveSort)
        : state.comments;
    state = state.copyWith(
      postId: postId ?? state.postId,
      comments: effectiveComments,
      status:
          (isLoading ?? false) ? CommentStatus.loading : CommentStatus.success,
      isInitialized: true,
      clearError: true,
      cursor: effectiveComments.isNotEmpty ? effectiveComments.last.id : null,
      clearCursor: effectiveComments.isEmpty,
    );
  }

  void setLoading({required bool isLoading}) {
    state = state.copyWith(
      status: isLoading ? CommentStatus.loading : CommentStatus.success,
      isInitialized: true,
    );
  }

  Future<CommentUiModel?> getCommentById(String commentId) async {
    final targetPostId = state.postId;
    if (targetPostId == null || targetPostId.trim().isEmpty) return null;

    final result = await _getCommentByIdUseCase(
      GetCommentByIdParams(
        postId: targetPostId,
        commentId: commentId,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (model) => model.toUiModel(),
    );
  }

  Future<void> loadComments({
    String? postId,
    CommentSortOrder? sort,
    bool isSilent = false,
  }) async {
    _cancelDebounce();
    final targetPostId = postId ?? state.postId;
    if (targetPostId == null || targetPostId.trim().isEmpty) return;

    if (!isSilent) {
      state = state.copyWith(status: CommentStatus.loading, clearError: true);
    }

    final targetSort = sort ?? state.sort;
    final result = await _getCommentsUseCase(
      GetCommentsParams(
        postId: targetPostId,
        sort: targetSort.value,
        limit: _pageSize,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CommentStatus.failure,
          errorMessage: failure.message,
          isInitialized: true,
        );
      },
      (models) {
        final lastCursor = models.isNotEmpty ? models.last.id : null;
        final uiModels = models.map((m) => m.toUiModel()).toList();
        final sortedList = _sortComments(uiModels, targetSort);
        state = state.copyWith(
          postId: targetPostId,
          comments: sortedList,
          sort: targetSort,
          status: CommentStatus.success,
          isInitialized: true,
          clearError: true,
          cursor: lastCursor,
          clearCursor: lastCursor == null,
          hasReachedMax: models.length < _pageSize,
        );
      },
    );
  }

  Future<void> loadMoreComment({
    bool immediate = false,
    CommentSortOrder? sort,
  }) {
    if (state.hasReachedMax || state.status == CommentStatus.loading) {
      return Future.value();
    }

    _debounceTimer?.cancel();
    _debounceCompleter ??= Completer<void>();

    if (immediate || _debounceDuration == Duration.zero) {
      _executeLoadMore(sort);
    } else {
      _debounceTimer = Timer(_debounceDuration, () => _executeLoadMore(sort));
    }

    return _debounceCompleter!.future;
  }

  Future<void> _executeLoadMore([CommentSortOrder? sort]) async {
    if (state.hasReachedMax || state.status == CommentStatus.loading) {
      _completeDebounce();
      return;
    }

    final targetPostId = state.postId;
    if (targetPostId == null || targetPostId.trim().isEmpty) {
      _completeDebounce();
      return;
    }

    final targetSorted = sort ?? state.sort;

    state = state.copyWith(
      status: CommentStatus.loading,
    );

    final result = await _getCommentsUseCase(
      GetCommentsParams(
        postId: targetPostId,
        limit: _pageSize,
        cursor: state.cursor,
        sort: targetSorted.value,
      ),
    );

    result.fold(
      (error) {
        state = state.copyWith(
          errorMessage: error.message,
          status: CommentStatus.failure,
        );
      },
      (comments) {
        final commentUiModel = comments.map((m) => m.toUiModel()).toList();
        final sortedList = _sortComments(commentUiModel, targetSorted);
        final existingIds = state.comments.map((c) => c.id).toSet();
        final newComments =
            sortedList.where((c) => !existingIds.contains(c.id)).toList();
        final mergeComments = [...state.comments, ...newComments];
        final nextCursor = comments.isNotEmpty
            ? comments.last.id
            : (mergeComments.isNotEmpty ? mergeComments.last.id : state.cursor);
        state = state.copyWith(
          comments: mergeComments,
          status: CommentStatus.success,
          cursor: nextCursor,
          clearError: true,
          hasReachedMax: comments.length < _pageSize,
        );
      },
    );

    _completeDebounce();
  }

  Future<void> refreshComments() async {
    _cancelDebounce();
    final targetPostId = state.postId;
    if (targetPostId == null || targetPostId.trim().isEmpty) return;

    state = state.copyWith(status: CommentStatus.refresh, clearError: true);

    final result = await _getCommentsUseCase(
      GetCommentsParams(
        postId: targetPostId,
        sort: state.sort.value,
        limit: _pageSize,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CommentStatus.failure,
          errorMessage: failure.message,
        );
      },
      (models) {
        final lastCursor = models.isNotEmpty ? models.last.id : null;
        final uiModels = models.map((m) => m.toUiModel()).toList();
        final sortedList = _sortComments(uiModels, state.sort);
        state = state.copyWith(
          comments: sortedList,
          status: CommentStatus.success,
          clearError: true,
          cursor: lastCursor,
          clearCursor: lastCursor == null,
          hasReachedMax: models.length < _pageSize,
        );
      },
    );
  }

  void changeSortOrder(
    CommentSortOrder order, {
    bool reload = true,
  }) {
    if (state.sort == order) return;
    state = state.copyWith(sort: order);

    if (reload && state.postId != null && state.postId!.isNotEmpty) {
      loadComments(postId: state.postId, sort: order);
    } else {
      state = state.copyWith(
        comments: _sortComments(state.comments, order),
      );
    }
  }

  void setReplyingTo(CommentUiModel? target) {
    state = state.copyWith(
      replyingTo: target,
      clearReplyingTo: target == null,
    );
  }

  Future<bool> addComment({
    required String content,
    PostAuthor? author,
    String? mediaUrl,
    String? parentCommentId,
    bool persist = true,
  }) async {
    final targetPostId = state.postId;
    if (targetPostId == null || targetPostId.trim().isEmpty) return false;

    final targetParentId = parentCommentId ?? state.replyingTo?.id;
    final optId = 'c_opt_${DateTime.now().millisecondsSinceEpoch}';
    final resolvedAuthor = author ??
        const PostAuthor(
          id: 'current_user',
          username: 'you',
          fullName: 'You',
        );

    final optimisticComment = CommentUiModel(
      id: optId,
      postId: targetPostId,
      author: resolvedAuthor,
      content: content.trim(),
      parentCommentId: targetParentId,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
      isOptimistic: true,
    );

    List<CommentUiModel> updatedList;
    if (targetParentId != null && targetParentId.isNotEmpty) {
      updatedList = _updateCommentInList(state.comments, targetParentId, (p) {
        return p.copyWith(
          replies: [...p.replies, optimisticComment],
          replyCount: p.replyCount + 1,
          isRepliesExpanded: true,
        );
      });
    } else {
      updatedList = [optimisticComment, ...state.comments];
    }

    state = state.copyWith(
      comments: updatedList,
      clearReplyingTo: true,
      isSubmitting: persist,
      clearError: true,
    );

    if (!persist) return true;

    var resolvedMediaUrl = mediaUrl;
    if (mediaUrl != null &&
        mediaUrl.trim().isNotEmpty &&
        !mediaUrl.startsWith('http://') &&
        !mediaUrl.startsWith('https://') &&
        !mediaUrl.startsWith('data:')) {
      if (_uploadCommentMediaUseCase != null) {
        final cleanPath = mediaUrl.startsWith('file://')
            ? mediaUrl.replaceFirst('file://', '')
            : mediaUrl;
        final uploadResult = await _uploadCommentMediaUseCase(cleanPath.trim());
        final uploadFailure =
            uploadResult.fold<Failure?>((f) => f, (_) => null);
        if (uploadFailure != null) {
          final rolledBack = _removeCommentFromList(
            state.comments,
            optId,
            parentId: targetParentId,
          );
          state = state.copyWith(
            comments: rolledBack,
            isSubmitting: false,
            errorMessage: uploadFailure.message,
          );
          return false;
        }
        resolvedMediaUrl = uploadResult.getOrElse((_) => mediaUrl);
      }
    }

    final result = await _createCommentUseCase(
      CreateCommentParams(
        postId: targetPostId,
        content: content.trim(),
        parentCommentId: targetParentId,
        mediaUrl: resolvedMediaUrl,
      ),
    );

    return result.fold(
      (failure) {
        // Rollback optimistic comment on failure
        final rolledBack = _removeCommentFromList(
          state.comments,
          optId,
          parentId: targetParentId,
        );
        state = state.copyWith(
          comments: rolledBack,
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdModel) {
        // Replace optimistic comment with confirmed response
        final confirmedList = _updateCommentInList(
          state.comments,
          optId,
          (_) => createdModel.toUiModel(),
        );
        state = state.copyWith(
          comments: confirmedList,
          isSubmitting: false,
        );
        return true;
      },
    );
  }

  Future<void> loadReplies(CommentUiModel parentComment) async {
    if (state.loadingReplyCommentIds.contains(parentComment.id)) return;

    final updatedWithLoading = _updateCommentInList(
      state.comments,
      parentComment.id,
      (p) => p.copyWith(isLoadingReplies: true),
    );

    state = state.copyWith(
      comments: updatedWithLoading,
      loadingReplyCommentIds: {
        ...state.loadingReplyCommentIds,
        parentComment.id,
      },
    );

    final result = await _getCommentRepliesUseCase(
      GetCommentRepliesParams(
        postId: state.postId ?? parentComment.postId,
        commentId: parentComment.id,
      ),
    );

    final nextLoadingIds = Set<String>.from(state.loadingReplyCommentIds)
      ..remove(parentComment.id);

    result.fold(
      (failure) {
        final resetList = _updateCommentInList(
          state.comments,
          parentComment.id,
          (p) => p.copyWith(isLoadingReplies: false),
        );
        state = state.copyWith(
          comments: resetList,
          loadingReplyCommentIds: nextLoadingIds,
          errorMessage: failure.message,
        );
      },
      (replyModels) {
        final repliesUi = replyModels.map((m) => m.toUiModel()).toList();
        final updatedList = _updateCommentInList(
          state.comments,
          parentComment.id,
          (parent) => parent.copyWith(
            isLoadingReplies: false,
            replies: repliesUi,
            replyCount: repliesUi.length > parent.replyCount
                ? repliesUi.length
                : parent.replyCount,
            isRepliesExpanded: true,
          ),
        );
        state = state.copyWith(
          comments: updatedList,
          loadingReplyCommentIds: nextLoadingIds,
        );
      },
    );
  }

  Future<void> toggleReplies(
    CommentUiModel comment, {
    bool fetchReplies = true,
  }) async {
    final willExpand = !comment.isRepliesExpanded;
    final updatedList = _updateCommentInList(
      state.comments,
      comment.id,
      (c) => c.copyWith(isRepliesExpanded: willExpand),
    );
    state = state.copyWith(comments: updatedList);

    if (willExpand && comment.replies.isEmpty && fetchReplies) {
      await loadReplies(comment);
    }
  }

  void toggleRepliesExpanded(String commentId) {
    final updatedList = _updateCommentInList(
      state.comments,
      commentId,
      (c) => c.copyWith(isRepliesExpanded: !c.isRepliesExpanded),
    );
    state = state.copyWith(comments: updatedList);
  }

  Future<bool> editComment({
    required String commentId,
    required String newContent,
    String? mediaUrl,
    bool persist = true,
  }) async {
    final existing = _findCommentInList(state.comments, commentId);
    if (existing == null) return false;

    final updatedList = _updateCommentInList(
      state.comments,
      commentId,
      (c) => c.copyWith(
        content: newContent.trim(),
        mediaUrl: mediaUrl ?? c.mediaUrl,
        updatedAt: DateTime.now(),
      ),
    );
    state = state.copyWith(comments: updatedList, clearError: true);

    if (!persist) return true;

    var resolvedMediaUrl = mediaUrl;
    if (mediaUrl != null &&
        mediaUrl.trim().isNotEmpty &&
        !mediaUrl.startsWith('http://') &&
        !mediaUrl.startsWith('https://') &&
        !mediaUrl.startsWith('data:')) {
      if (_uploadCommentMediaUseCase != null) {
        final cleanPath = mediaUrl.startsWith('file://')
            ? mediaUrl.replaceFirst('file://', '')
            : mediaUrl;
        final uploadResult = await _uploadCommentMediaUseCase(cleanPath.trim());
        final uploadFailure =
            uploadResult.fold<Failure?>((f) => f, (_) => null);
        if (uploadFailure != null) {
          final rolledBack = _updateCommentInList(
            state.comments,
            commentId,
            (_) => existing,
          );
          state = state.copyWith(
            comments: rolledBack,
            errorMessage: uploadFailure.message,
          );
          return false;
        }
        resolvedMediaUrl = uploadResult.getOrElse((_) => mediaUrl);
      }
    }

    final result = await _updateCommentUseCase(
      UpdateCommentParams(
        postId: state.postId ?? existing.postId,
        commentId: commentId,
        content: newContent.trim(),
        mediaUrl: resolvedMediaUrl,
      ),
    );

    return result.fold(
      (failure) {
        // Rollback to original content
        final rolledBack = _updateCommentInList(
          state.comments,
          commentId,
          (_) => existing,
        );
        state = state.copyWith(
          comments: rolledBack,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedModel) {
        final confirmed = _updateCommentInList(
          state.comments,
          commentId,
          (_) => updatedModel.toUiModel(),
        );
        state = state.copyWith(comments: confirmed);
        return true;
      },
    );
  }

  Future<bool> deleteComment(
    String commentId, {
    String? parentCommentId,
    bool persist = true,
  }) async {
    final existing = _findCommentInList(state.comments, commentId);
    if (existing == null) return false;

    final parentId = parentCommentId ?? existing.parentCommentId;
    final updatedList = _removeCommentFromList(
      state.comments,
      commentId,
      parentId: parentId,
    );
    state = state.copyWith(comments: updatedList, clearError: true);

    if (!persist) return true;

    final result = await _deleteCommentUseCase(
      DeleteCommentParams(
        postId: state.postId ?? existing.postId,
        commentId: commentId,
      ),
    );

    return result.fold(
      (failure) {
        // Restore comment on failure
        List<CommentUiModel> restored;
        if (parentId != null && parentId.isNotEmpty) {
          restored = _updateCommentInList(state.comments, parentId, (parent) {
            return parent.copyWith(
              replies: [...parent.replies, existing],
              replyCount: parent.replyCount + 1,
            );
          });
        } else {
          restored = _sortComments(
            [...state.comments, existing],
            state.sort,
          );
        }
        state = state.copyWith(
          comments: restored,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) => true,
    );
  }

  Future<void> toggleReaction(
    CommentUiModel comment, {
    bool persist = true,
  }) async {
    final wasLiked = comment.userHasLiked;
    final nextLiked = !wasLiked;
    final nextCount = comment.likeCount + (nextLiked ? 1 : -1);
    final nextReaction = nextLiked ? '❤️' : null;

    final updatedList = _updateCommentInList(
      state.comments,
      comment.id,
      (c) => c.copyWith(
        userHasLiked: nextLiked,
        likeCount: nextCount < 0 ? 0 : nextCount,
        userReaction: nextReaction,
      ),
    );
    state = state.copyWith(comments: updatedList);

    if (!persist) return;

    await _reactToCommentUseCase(
      ReactToCommentParams(
        postId: state.postId ?? comment.postId,
        commentId: comment.id,
        isRemove: wasLiked,
      ),
    );
  }

  Future<void> selectReaction(
    CommentUiModel comment,
    String reaction, {
    bool persist = true,
  }) async {
    final wasLiked = comment.userHasLiked;
    final nextCount = wasLiked ? comment.likeCount : comment.likeCount + 1;

    final updatedList = _updateCommentInList(
      state.comments,
      comment.id,
      (c) => c.copyWith(
        userHasLiked: true,
        likeCount: nextCount,
        userReaction: reaction,
      ),
    );
    state = state.copyWith(comments: updatedList);

    if (!persist) return;

    await _reactToCommentUseCase(
      ReactToCommentParams(
        postId: state.postId ?? comment.postId,
        commentId: comment.id,
        reaction: reaction,
      ),
    );
  }

  Future<void> togglePin(
    CommentUiModel comment, {
    bool persist = true,
  }) async {
    final nextPinned = !comment.isPinned;

    var updatedList = state.comments.map((c) {
      if (c.id == comment.id) {
        return c.copyWith(
          isPinned: nextPinned,
          pinnedAt: nextPinned ? DateTime.now() : null,
        );
      } else if (nextPinned && c.isPinned) {
        return c.copyWith(isPinned: false);
      }
      return c;
    }).toList();

    updatedList = _sortComments(updatedList, state.sort);
    state = state.copyWith(comments: updatedList);

    if (!persist) return;

    await _pinCommentUseCase(
      PinCommentParams(
        postId: state.postId ?? comment.postId,
        commentId: comment.id,
        isPinned: nextPinned,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const CommentState();
  }

  List<CommentUiModel> _updateCommentInList(
    List<CommentUiModel> list,
    String id,
    CommentUiModel Function(CommentUiModel) updater,
  ) {
    return list.map((comment) {
      if (comment.id == id) {
        return updater(comment);
      }
      if (comment.replies.isNotEmpty) {
        final updatedReplies = comment.replies.map((reply) {
          if (reply.id == id) {
            return updater(reply);
          }
          return reply;
        }).toList();
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  List<CommentUiModel> _removeCommentFromList(
    List<CommentUiModel> list,
    String commentId, {
    String? parentId,
  }) {
    if (parentId != null && parentId.isNotEmpty) {
      return _updateCommentInList(list, parentId, (parent) {
        final newReplies =
            parent.replies.where((r) => r.id != commentId).toList();
        final newCount = parent.replyCount > 0 ? parent.replyCount - 1 : 0;
        return parent.copyWith(
          replies: newReplies,
          replyCount: newCount,
        );
      });
    }
    return list.where((c) => c.id != commentId).toList();
  }

  CommentUiModel? _findCommentInList(List<CommentUiModel> list, String id) {
    for (final c in list) {
      if (c.id == id) return c;
      for (final r in c.replies) {
        if (r.id == id) return r;
      }
    }
    return null;
  }

  List<CommentUiModel> _sortComments(
    List<CommentUiModel> list,
    CommentSortOrder sortOrder,
  ) {
    return List<CommentUiModel>.from(list)
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        switch (sortOrder) {
          case CommentSortOrder.popular:
            return b.likeCount.compareTo(a.likeCount);
          case CommentSortOrder.newest:
            return b.createdAt.compareTo(a.createdAt);
          case CommentSortOrder.oldest:
            return a.createdAt.compareTo(b.createdAt);
        }
      });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _completeDebounce();
    super.dispose();
  }
}
