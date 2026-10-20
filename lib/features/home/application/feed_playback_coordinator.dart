import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class FeedPlaybackState extends Equatable {
  const FeedPlaybackState({
    this.activePostId,
    this.isGloballyMuted = true,
    this.userPausedPostIds = const {},
  });

  final String? activePostId;

  final bool isGloballyMuted;

  final Set<String> userPausedPostIds;

  FeedPlaybackState copyWith({
    String? activePostId,
    bool clearActivePostId = false,
    bool? isGloballyMuted,
    Set<String>? userPausedPostIds,
  }) {
    return FeedPlaybackState(
      activePostId:
          clearActivePostId ? null : (activePostId ?? this.activePostId),
      isGloballyMuted: isGloballyMuted ?? this.isGloballyMuted,
      userPausedPostIds: userPausedPostIds ?? this.userPausedPostIds,
    );
  }

  @override
  List<Object?> get props => [
        activePostId,
        isGloballyMuted,
        userPausedPostIds,
      ];
}

class _CandidateVisibility {
  const _CandidateVisibility({
    required this.visibleFraction,
    required this.distanceToCenter,
  });

  final double visibleFraction;
  final double distanceToCenter;
}

class FeedPlaybackCoordinator extends StateNotifier<FeedPlaybackState> {
  FeedPlaybackCoordinator({
    Duration debounceDuration = const Duration(milliseconds: 250),
    double minPlayVisibility = 0.50,
    double maxPauseVisibility = 0.40,
  })  : _debounceDuration = debounceDuration,
        _minPlayVisibility = minPlayVisibility,
        _maxPauseVisibility = maxPauseVisibility,
        super(const FeedPlaybackState());

  final Duration _debounceDuration;
  final double _minPlayVisibility;
  final double _maxPauseVisibility;

  final Map<String, _CandidateVisibility> _candidates = {};
  Timer? _debounceTimer;

  void reportVisibility({
    required String postId,
    required double visibleFraction,
    required double distanceToCenter,
  }) {
    // Immediate auto-pause if active post drops below threshold (40%)
    if (state.activePostId == postId && visibleFraction < _maxPauseVisibility) {
      _debounceTimer?.cancel();
      _candidates.remove(postId);
      state = state.copyWith(clearActivePostId: true);
      // Reset user-paused flag for this post once it leaves the viewport
      if (state.userPausedPostIds.contains(postId)) {
        final updated = Set<String>.from(state.userPausedPostIds)
          ..remove(postId);
        state = state.copyWith(userPausedPostIds: updated);
      }
      return;
    }

    // Track candidate if eligible (>= 50%)
    if (visibleFraction >= _minPlayVisibility) {
      _candidates[postId] = _CandidateVisibility(
        visibleFraction: visibleFraction,
        distanceToCenter: distanceToCenter,
      );
    } else {
      _candidates.remove(postId);
      if (state.userPausedPostIds.contains(postId)) {
        final updated = Set<String>.from(state.userPausedPostIds)
          ..remove(postId);
        state = state.copyWith(userPausedPostIds: updated);
      }
    }

    // Debounce candidate evaluation (200-300ms) to avoid thrash on scroll
    _debounceTimer?.cancel();
    if (_debounceDuration == Duration.zero) {
      _evaluateCandidates();
    } else {
      _debounceTimer = Timer(_debounceDuration, _evaluateCandidates);
    }
  }

  void _evaluateCandidates() {
    if (_candidates.isEmpty) {
      if (state.activePostId != null) {
        state = state.copyWith(clearActivePostId: true);
      }
      return;
    }

    String? bestPostId;
    var minDistance = double.infinity;

    for (final entry in _candidates.entries) {
      if (entry.value.visibleFraction >= _minPlayVisibility) {
        if (entry.value.distanceToCenter < minDistance) {
          minDistance = entry.value.distanceToCenter;
          bestPostId = entry.key;
        }
      }
    }

    if (bestPostId == null) {
      if (state.activePostId != null) {
        state = state.copyWith(clearActivePostId: true);
      }
      return;
    }

    // If user explicitly paused this post, do not auto-play it
    if (state.userPausedPostIds.contains(bestPostId)) {
      if (state.activePostId != null && state.activePostId != bestPostId) {
        state = state.copyWith(clearActivePostId: true);
      }
      return;
    }

    if (state.activePostId != bestPostId) {
      state = state.copyWith(activePostId: bestPostId);
    }
  }

  void toggleMute() {
    state = state.copyWith(isGloballyMuted: !state.isGloballyMuted);
  }

  void setGloballyMuted({required bool isMuted}) {
    if (state.isGloballyMuted != isMuted) {
      state = state.copyWith(isGloballyMuted: isMuted);
    }
  }

  void togglePlayPause(String postId) {
    if (state.activePostId == postId) {
      // User tapped active playing video -> pause
      final updated = Set<String>.from(state.userPausedPostIds)..add(postId);
      state = state.copyWith(
        clearActivePostId: true,
        userPausedPostIds: updated,
      );
    } else {
      // User tapped paused video -> play
      final updated = Set<String>.from(state.userPausedPostIds)..remove(postId);
      state = state.copyWith(
        activePostId: postId,
        userPausedPostIds: updated,
      );
    }
  }

  void reportDisposed(String postId) {
    _candidates.remove(postId);
    if (state.activePostId == postId) {
      state = state.copyWith(clearActivePostId: true);
    }
  }

  void pauseAll() {
    _debounceTimer?.cancel();
    if (state.activePostId != null) {
      state = state.copyWith(clearActivePostId: true);
    }
  }

  void resume() {
    _evaluateCandidates();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final feedPlaybackCoordinatorProvider =
    StateNotifierProvider<FeedPlaybackCoordinator, FeedPlaybackState>((ref) {
  return FeedPlaybackCoordinator();
});
