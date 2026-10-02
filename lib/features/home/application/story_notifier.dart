import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_stories_tray_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/mark_story_viewed_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/react_to_story_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/reply_to_story_usecase.dart';

@immutable
class StoriesState {
  const StoriesState({
    this.storyGroups = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<UserStory> storyGroups;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  StoriesState copyWith({
    List<UserStory>? storyGroups,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return StoriesState(
      storyGroups: storyGroups ?? this.storyGroups,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}

class StoriesNotifier extends StateNotifier<StoriesState> {
  StoriesNotifier({
    required GetStoriesTrayUseCase getStoriesTrayUseCase,
    required MarkStoryViewedUseCase markStoryViewedUseCase,
    required ReactToStoryUseCase reactToStoryUseCase,
    required ReplyToStoryUseCase replyToStoryUseCase,
  })  : _getStoriesTrayUseCase = getStoriesTrayUseCase,
        _markStoryViewedUseCase = markStoryViewedUseCase,
        _reactToStoryUseCase = reactToStoryUseCase,
        _replyToStoryUseCase = replyToStoryUseCase,
        super(const StoriesState()) {
    loadStories();
  }

  final GetStoriesTrayUseCase _getStoriesTrayUseCase;
  final MarkStoryViewedUseCase _markStoryViewedUseCase;
  final ReactToStoryUseCase _reactToStoryUseCase;
  final ReplyToStoryUseCase _replyToStoryUseCase;

  Future<void> loadStories() async {
    state = state.copyWith(isLoading: true);

    final result = await _getStoriesTrayUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (storyGroups) {
        state = state.copyWith(
          storyGroups: storyGroups,
          isLoading: false,
        );
      },
    );
  }

  Future<void> refreshStories() async {
    state = state.copyWith(isRefreshing: true);

    final result = await _getStoriesTrayUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isRefreshing: false,
          errorMessage: failure.message,
        );
      },
      (storyGroups) {
        state = state.copyWith(
          storyGroups: storyGroups.isNotEmpty ? storyGroups : state.storyGroups,
          isRefreshing: false,
        );
      },
    );
  }

  Future<void> markStoryViewed(String storyId, String userId) async {
    // Optimistically update local viewed status
    final updatedGroups = state.storyGroups.map((group) {
      if (group.id == userId) {
        final updatedStories = group.stories.map((story) {
          if (story.id == storyId) {
            return story.copyWith(hasViewed: true);
          }
          return story;
        }).toList();

        final allViewed = updatedStories.every((s) => s.hasViewed);

        return group.copyWith(
          stories: updatedStories,
          hasUnseen: !allViewed,
        );
      }
      return group;
    }).toList();

    state = state.copyWith(storyGroups: updatedGroups);

    // Dispatch background API call
    await _markStoryViewedUseCase(storyId);
  }

  Future<void> reactToStory(String storyId, String reaction) async {
    await _reactToStoryUseCase(
      ReactToStoryParams(storyId: storyId, reaction: reaction),
    );
  }

  Future<void> replyToStory(String storyId, String message) async {
    await _replyToStoryUseCase(
      ReplyToStoryParams(storyId: storyId, message: message),
    );
  }
}
