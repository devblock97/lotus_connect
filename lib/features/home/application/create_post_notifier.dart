import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/domain/entities/create_post_params.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_post_usecase.dart';

@immutable
class CreatePostState {
  const CreatePostState({
    this.content = '',
    this.mediaPaths = const [],
    this.existingMediaItems = const [],
    this.visibility = 'public',
    this.feeling,
    this.feelingEmoji,
    this.location,
    this.backgroundColorHex,
    this.isSubmitting = false,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.createdPost,
    this.postIdToEdit,
  });

  final String content;
  final List<String> mediaPaths;
  final List<PostMediaItem> existingMediaItems;
  final String visibility;
  final String? feeling;
  final String? feelingEmoji;
  final String? location;
  final String? backgroundColorHex;
  final bool isSubmitting;
  final double uploadProgress;
  final String? errorMessage;
  final PostItem? createdPost;
  final String? postIdToEdit;

  bool get isEditMode => postIdToEdit != null;

  bool get canSubmit =>
      content.trim().isNotEmpty ||
      mediaPaths.isNotEmpty ||
      existingMediaItems.isNotEmpty;

  CreatePostState copyWith({
    String? content,
    List<String>? mediaPaths,
    List<PostMediaItem>? existingMediaItems,
    String? visibility,
    String? feeling,
    String? feelingEmoji,
    String? location,
    String? backgroundColorHex,
    bool clearBackgroundColor = false,
    bool? isSubmitting,
    double? uploadProgress,
    String? errorMessage,
    bool clearErrorMessage = false,
    PostItem? createdPost,
    String? postIdToEdit,
    bool clearPostIdToEdit = false,
  }) {
    return CreatePostState(
      content: content ?? this.content,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      existingMediaItems: existingMediaItems ?? this.existingMediaItems,
      visibility: visibility ?? this.visibility,
      feeling: feeling ?? this.feeling,
      feelingEmoji: feelingEmoji ?? this.feelingEmoji,
      location: location ?? this.location,
      backgroundColorHex: clearBackgroundColor
          ? null
          : (backgroundColorHex ?? this.backgroundColorHex),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      createdPost: createdPost ?? this.createdPost,
      postIdToEdit:
          clearPostIdToEdit ? null : (postIdToEdit ?? this.postIdToEdit),
    );
  }
}

class CreatePostNotifier extends StateNotifier<CreatePostState> {
  CreatePostNotifier({
    required CreatePostUseCase createPostUseCase,
    required FeedNotifier feedNotifier,
    UpdatePostUseCase? updatePostUseCase,
  })  : _createPostUseCase = createPostUseCase,
        _feedNotifier = feedNotifier,
        _updatePostUseCase = updatePostUseCase,
        super(const CreatePostState());

  final CreatePostUseCase _createPostUseCase;
  final FeedNotifier _feedNotifier;
  final UpdatePostUseCase? _updatePostUseCase;

  void initializeForEdit(PostItem post) {
    state = state.copyWith(
      postIdToEdit: post.id,
      content: post.content,
      visibility: post.visibility,
      existingMediaItems: post.mediaItems,
      mediaPaths: const [],
      clearErrorMessage: true,
    );
  }

  void updateContent(String text) {
    state = state.copyWith(
      content: text,
      clearErrorMessage: true,
    );
  }

  void updateVisibility(String visibility) {
    state = state.copyWith(visibility: visibility);
  }

  void addMediaPaths(List<String> paths) {
    final existing = Set<String>.from(state.mediaPaths);
    final merged = [...state.mediaPaths];
    for (final p in paths) {
      if (existing.add(p)) {
        merged.add(p);
      }
    }
    state = state.copyWith(
      mediaPaths: merged,
      // Media posts don't use colored text backgrounds
      clearBackgroundColor: true,
      clearErrorMessage: true,
    );
  }

  void removeMediaPathAt(int index) {
    if (index < 0 || index >= state.mediaPaths.length) return;
    final updated = [...state.mediaPaths]..removeAt(index);
    state = state.copyWith(mediaPaths: updated);
  }

  void removeExistingMediaAt(int index) {
    if (index < 0 || index >= state.existingMediaItems.length) return;
    final updated = [...state.existingMediaItems]..removeAt(index);
    state = state.copyWith(existingMediaItems: updated);
  }

  void clearMedia() {
    state = state.copyWith(
      mediaPaths: const [],
      existingMediaItems: const [],
    );
  }

  void setFeeling(String? feeling, String? emoji) {
    state = state.copyWith(
      feeling: feeling,
      feelingEmoji: emoji,
    );
  }

  void setLocation(String? location) {
    state = state.copyWith(location: location);
  }

  void setBackgroundColor(String? colorHex) {
    if (colorHex == null) {
      state = state.copyWith(clearBackgroundColor: true);
    } else {
      state = state.copyWith(
        backgroundColorHex: colorHex,
        mediaPaths: const [],
        existingMediaItems: const [],
      );
    }
  }

  Future<PostItem?> submitPost() async {
    if (!state.canSubmit) {
      state = state.copyWith(
        errorMessage: 'Please enter some text or select media to share.',
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      uploadProgress: 0.1,
    );

    // If editing existing post
    if (state.isEditMode && _updatePostUseCase != null) {
      final params = UpdatePostParams(
        postId: state.postIdToEdit!,
        content: state.content,
        mediaItems: state.existingMediaItems,
        filePaths: state.mediaPaths,
        visibility: state.visibility,
      );

      final result = await _updatePostUseCase(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          );
          return null;
        },
        (updatedPost) {
          _feedNotifier.updatePost(updatedPost);
          state = state.copyWith(
            isSubmitting: false,
            createdPost: updatedPost,
          );
          return updatedPost;
        },
      );
    }

    // Creating new post
    final params = CreatePostParams(
      content: state.content,
      filePaths: state.mediaPaths,
      visibility: state.visibility,
      feeling: state.feeling,
      feelingEmoji: state.feelingEmoji,
      location: state.location,
    );

    final result = await _createPostUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (newPost) {
        // Prepend directly into the live feed
        _feedNotifier.addPost(newPost);
        state = state.copyWith(
          isSubmitting: false,
          createdPost: newPost,
        );
        return newPost;
      },
    );
  }

  void reset() {
    state = const CreatePostState();
  }
}
