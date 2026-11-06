import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chill/chill.dart';

enum ChillStatus {
  initial,
  loading,
  success,
  failure,
  reactionLoading,
  reactionSuccess,
  reactionFailure,
  commentLoading,
  commentSuccess,
  commentFailure,
  shareLoading,
  shareSuccess,
  shareFailure,
}

class ChillState extends Equatable {
  const ChillState({
    this.chills = const [],
    this.status = ChillStatus.initial,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasReachedMax = false,
    this.isMuted = false,
    this.cursor,
    this.activeTag,
    this.message,
  });

  final List<ChillItem> chills;
  final ChillStatus status;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasReachedMax;
  final bool isMuted;
  final String? cursor;
  final String? activeTag;
  final String? message;

  ChillState copyWith({
    List<ChillItem>? chills,
    ChillStatus? status,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasReachedMax,
    bool? isMuted,
    String? cursor,
    bool clearCursor = false,
    String? activeTag,
    bool clearActiveTag = false,
    String? message,
  }) {
    return ChillState(
      chills: chills ?? this.chills,
      status: status ?? this.status,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isMuted: isMuted ?? this.isMuted,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      activeTag: clearActiveTag ? null : (activeTag ?? this.activeTag),
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        chills,
        status,
        isLoadingMore,
        isRefreshing,
        hasReachedMax,
        isMuted,
        cursor,
        activeTag,
        message,
      ];
}

class ChillNotifier extends StateNotifier<ChillState> {
  ChillNotifier({
    required GetChillFeedUseCase getChillFeedUseCase,
    required ToggleLikeChillUseCase toggleLikeChillUseCase,
    ToggleSaveChillUseCase? toggleSaveChillUseCase,
    ShareChillUseCase? shareChillUseCase,
    RecordChillViewUseCase? recordChillViewUseCase,
    DeleteChillUseCase? deleteChillUseCase,
    CreateChillUseCase? createChillUseCase,
    UpdateChillUseCase? updateChillUseCase,
  })  : _getChillFeedUseCase = getChillFeedUseCase,
        _toggleLikeChillUseCase = toggleLikeChillUseCase,
        _toggleSaveChillUseCase = toggleSaveChillUseCase,
        _shareChillUseCase = shareChillUseCase,
        _recordChillViewUseCase = recordChillViewUseCase,
        _deleteChillUseCase = deleteChillUseCase,
        _createChillUseCase = createChillUseCase,
        _updateChillUseCase = updateChillUseCase,
        super(const ChillState());

  final GetChillFeedUseCase _getChillFeedUseCase;
  final ToggleLikeChillUseCase _toggleLikeChillUseCase;
  final ToggleSaveChillUseCase? _toggleSaveChillUseCase;
  final ShareChillUseCase? _shareChillUseCase;
  final RecordChillViewUseCase? _recordChillViewUseCase;
  final DeleteChillUseCase? _deleteChillUseCase;
  final CreateChillUseCase? _createChillUseCase;
  final UpdateChillUseCase? _updateChillUseCase;

  static const int _defaultPageSize = 15;

  /// Loads initial Chills feed (optionally filtered by [tag]).
  Future<void> getChill({String? tag, int limit = _defaultPageSize}) async {
    state = state.copyWith(
      status: ChillStatus.loading,
      activeTag: tag,
      clearActiveTag: tag == null,
      clearCursor: true,
      hasReachedMax: false,
    );

    final result = await _getChillFeedUseCase(
      GetChillFeedParams(
        limit: limit,
        tag: tag,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          message: failure.message,
          status: ChillStatus.failure,
        );
      },
      (chills) {
        state = state.copyWith(
          chills: chills,
          status: ChillStatus.success,
          cursor: chills.isNotEmpty ? chills.last.id : null,
          hasReachedMax: chills.length < limit,
        );
      },
    );
  }

  /// Refreshes the Chills feed without blanking the screen while loading.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true);

    final result = await _getChillFeedUseCase(
      GetChillFeedParams(
        limit: _defaultPageSize,
        tag: state.activeTag,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isRefreshing: false,
          message: failure.message,
        );
      },
      (chills) {
        state = state.copyWith(
          chills: chills,
          status: ChillStatus.success,
          isRefreshing: false,
          cursor: chills.isNotEmpty ? chills.last.id : null,
          hasReachedMax: chills.length < _defaultPageSize,
        );
      },
    );
  }

  /// Loads the next page of Chills for infinite vertical scrolling.
  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.status == ChillStatus.loading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final result = await _getChillFeedUseCase(
      GetChillFeedParams(
        cursor: state.cursor,
        limit: _defaultPageSize,
        tag: state.activeTag,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          message: failure.message,
        );
      },
      (newChills) {
        final existingIds = state.chills.map((c) => c.id).toSet();
        final uniqueNew =
            newChills.where((c) => !existingIds.contains(c.id)).toList();
        final merged = [...state.chills, ...uniqueNew];

        state = state.copyWith(
          chills: merged,
          status: ChillStatus.success,
          isLoadingMore: false,
          cursor: newChills.isNotEmpty ? newChills.last.id : state.cursor,
          hasReachedMax: newChills.isEmpty,
        );
      },
    );
  }

  /// Filters the feed by hashtag/topic or clears the filter when [tag] is null.
  Future<void> setTagFilter(String? tag) async {
    if (state.activeTag == tag && state.status == ChillStatus.success) return;
    await getChill(tag: tag);
  }

  /// Seeds the state with an initial list of Chills (e.g. when opened from Home feed).
  void setInitialChills(List<ChillItem> initialChills) {
    state = state.copyWith(
      chills: initialChills,
      status: ChillStatus.success,
      cursor: initialChills.isNotEmpty ? initialChills.last.id : null,
    );
  }

  /// Toggles global audio mute for Chills playback.
  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void setMuted({required bool isMuted}) {
    if (state.isMuted != isMuted) {
      state = state.copyWith(isMuted: isMuted);
    }
  }

  Future<void> reactions(
    String chillId,
    bool isLiked, {
    String? reaction,
  }) async {
    final previousChills = state.chills;

    // Optimistic update in place so the PageView stays active
    final updatedChills = state.chills.map((item) {
      if (item.id == chillId) {
        final delta = isLiked && !item.userHasLiked
            ? 1
            : (!isLiked && item.userHasLiked ? -1 : 0);
        final nextCount = (item.likeCount + delta).clamp(0, 1 << 30);
        return item.copyWith(
          userHasLiked: isLiked,
          userReaction: isLiked ? (reaction ?? 'like') : null,
          likeCount: nextCount,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      chills: updatedChills,
      status: ChillStatus.reactionLoading,
    );

    final result = await _toggleLikeChillUseCase(
      ToggleLikeChillParams(
        chillId: chillId,
        isLiked: isLiked,
        reaction: reaction,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(
          chills: previousChills,
          status: ChillStatus.reactionFailure,
          message: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: ChillStatus.reactionSuccess,
        );
      },
    );
  }

  Future<void> toggleSave(String chillId, {required bool isSaved}) async {
    final previousChills = state.chills;

    state = state.copyWith(
      chills: state.chills.map((item) {
        if (item.id == chillId) {
          return item.copyWith(userHasSaved: isSaved);
        }
        return item;
      }).toList(),
    );

    final useCase = _toggleSaveChillUseCase;
    if (useCase == null) return;

    final result = await useCase(
      ToggleSaveChillParams(chillId: chillId, isSaved: isSaved),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          chills: previousChills,
          message: failure.message,
        );
      },
      (_) {},
    );
  }

  Future<void> shareChill(String chillId) async {
    // Optimistically increment shareCount
    final previousChills = state.chills;
    state = state.copyWith(
      status: ChillStatus.shareLoading,
      chills: state.chills.map((item) {
        if (item.id == chillId) {
          return item.copyWith(shareCount: item.shareCount + 1);
        }
        return item;
      }).toList(),
    );

    final useCase = _shareChillUseCase;
    if (useCase == null) {
      state = state.copyWith(status: ChillStatus.shareSuccess);
      return;
    }

    final result = await useCase(ShareChillParams(chillId: chillId));
    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          chills: previousChills,
          status: ChillStatus.shareFailure,
          message: failure.message,
        );
      },
      (updatedItem) {
        state = state.copyWith(
          status: ChillStatus.shareSuccess,
          chills: state.chills.map((item) {
            return item.id == chillId ? updatedItem : item;
          }).toList(),
        );
      },
    );
  }

  Future<void> recordView(
    String chillId, {
    double? watchTimeSeconds,
    bool? isCompleted,
  }) async {
    final useCase = _recordChillViewUseCase;
    if (useCase == null) return;

    final result = await useCase(
      RecordChillViewParams(
        chillId: chillId,
        watchTimeSeconds: watchTimeSeconds,
        isCompleted: isCompleted,
      ),
    );

    if (!mounted) return;

    result.fold(
      (_) {},
      (viewResult) {
        state = state.copyWith(
          chills: state.chills.map((item) {
            if (item.id == chillId) {
              return item.copyWith(viewCount: viewResult.viewCount);
            }
            return item;
          }).toList(),
        );
      },
    );
  }

  void updateCommentCount(String chillId, {required int delta}) {
    state = state.copyWith(
      chills: state.chills.map((item) {
        if (item.id == chillId) {
          final nextCount = (item.commentCount + delta).clamp(0, 1 << 30);
          return item.copyWith(commentCount: nextCount);
        }
        return item;
      }).toList(),
    );
  }

  /// Deletes a Chill from backend and removes it from the state list.
  Future<bool> deleteChill(String chillId) async {
    final useCase = _deleteChillUseCase;
    if (useCase != null) {
      final result = await useCase(DeleteChillParams(chillId: chillId));
      if (!mounted) return false;
      return result.fold(
        (failure) {
          state = state.copyWith(message: failure.message);
          return false;
        },
        (success) {
          state = state.copyWith(
            chills: state.chills.where((c) => c.id != chillId).toList(),
          );
          return true;
        },
      );
    }

    state = state.copyWith(
      chills: state.chills.where((c) => c.id != chillId).toList(),
    );
    return true;
  }

  /// Creates a new Chill and prepends it to the feed.
  Future<ChillItem?> createChill(CreateChillParams params) async {
    final useCase = _createChillUseCase;
    if (useCase == null) return null;

    final result = await useCase(params);
    if (!mounted) return null;

    return result.fold(
      (failure) {
        state = state.copyWith(message: failure.message);
        return null;
      },
      (created) {
        state = state.copyWith(
          chills: [created, ...state.chills],
          status: ChillStatus.success,
        );
        return created;
      },
    );
  }

  /// Updates an existing Chill and replaces it in the feed.
  Future<ChillItem?> updateChill(UpdateChillParams params) async {
    final useCase = _updateChillUseCase;
    if (useCase == null) return null;

    final result = await useCase(params);
    if (!mounted) return null;

    return result.fold(
      (failure) {
        state = state.copyWith(message: failure.message);
        return null;
      },
      (updated) {
        state = state.copyWith(
          chills: state.chills
              .map((c) => c.id == updated.id ? updated : c)
              .toList(),
        );
        return updated;
      },
    );
  }
}
