import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/create_story_state.dart';
import 'package:lotus_connect/features/home/application/story_notifier.dart';
import 'package:lotus_connect/features/home/domain/entities/create_story_params.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_story_usecase.dart';
import 'package:lotus_connect/features/home/presentation/models/story_gradient_preset.dart';
import 'package:lotus_connect/features/home/presentation/models/story_sticker_item.dart';

class CreateStoryNotifier extends StateNotifier<CreateStoryState> {
  CreateStoryNotifier({
    required CreateStoryUseCase createStoryUseCase,
    required StoriesNotifier storiesNotifier,
  })  : _createStoryUseCase = createStoryUseCase,
        _storiesNotifier = storiesNotifier,
        super(const CreateStoryState());

  final CreateStoryUseCase _createStoryUseCase;
  final StoriesNotifier _storiesNotifier;

  void setMediaType(String type) {
    state = state.copyWith(mediaType: type);
  }

  void setImagePath(String path) {
    state = state.copyWith(
      mediaType: 'image',
      selectedFilePath: path,
    );
  }

  void setVideoPath(String path) {
    state = state.copyWith(
      mediaType: 'video',
      selectedFilePath: path,
    );
  }

  void clearMedia() {
    state = state.copyWith(
      mediaType: 'text',
      clearFilePath: true,
    );
  }

  void cycleBackgroundPreset() {
    final nextIndex =
        (state.selectedPresetIndex + 1) % kStoryGradientPresets.length;
    state = state.copyWith(selectedPresetIndex: nextIndex);
  }

  void setPresetIndex(int index) {
    state = state.copyWith(selectedPresetIndex: index);
  }

  void setFilter(String filterId) {
    state = state.copyWith(selectedFilterId: filterId);
  }

  void setVisibility(String visibility) {
    state = state.copyWith(visibility: visibility);
  }

  void updateCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  void removeCaption() {
    state = state.copyWith(
      caption: '',
      textOffset: const Offset(0.5, 0.45),
      textScale: 1,
      textRotation: 0,
    );
  }

  void updateTextTransform({
    Offset? offset,
    double? scale,
    double? rotation,
  }) {
    state = state.copyWith(
      textOffset: offset ?? state.textOffset,
      textScale: scale ?? state.textScale,
      textRotation: rotation ?? state.textRotation,
    );
  }

  void updateTextStyle({
    String? fontFamily,
    Color? textColor,
    TextAlign? textAlign,
    bool? hasTextHighlight,
  }) {
    state = state.copyWith(
      fontFamily: fontFamily ?? state.fontFamily,
      textColor: textColor ?? state.textColor,
      textAlign: textAlign ?? state.textAlign,
      hasTextHighlight: hasTextHighlight ?? state.hasTextHighlight,
    );
  }

  void addSticker(StoryStickerItem sticker) {
    state = state.copyWith(stickers: [...state.stickers, sticker]);
  }

  void removeSticker(String stickerId) {
    final filtered = state.stickers.where((s) => s.id != stickerId).toList();
    state = state.copyWith(stickers: filtered);
  }

  void updateStickerOffset(String stickerId, Offset newOffset) {
    final updated = state.stickers.map((s) {
      if (s.id == stickerId) {
        return s.copyWith(offset: newOffset);
      }
      return s;
    }).toList();
    state = state.copyWith(stickers: updated);
  }

  void updateStickerTransform(
    String stickerId, {
    Offset? offset,
    double? scale,
    double? rotation,
  }) {
    final updated = state.stickers.map((s) {
      if (s.id == stickerId) {
        return s.copyWith(
          offset: offset ?? s.offset,
          scale: scale ?? s.scale,
          rotation: rotation ?? s.rotation,
        );
      }
      return s;
    }).toList();
    state = state.copyWith(stickers: updated);
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void reset() {
    state = const CreateStoryState();
  }

  Future<Story?> submitStory({String? customVisibility}) async {
    final effectiveVisibility = customVisibility ?? state.visibility;
    state = state.copyWith(isPublishing: true);

    final hexColor =
        state.textColor.toARGB32().toRadixString(16).padLeft(8, '0');
    final metadata = <String, dynamic>{
      'filter': state.selectedFilterId,
      'fontFamily': state.fontFamily,
      'textColor': '#${hexColor.substring(2).toUpperCase()}',
      'hasTextHighlight': state.hasTextHighlight,
      'textAlign': state.textAlign.name,
      'textOffset': {
        'x': state.textOffset.dx,
        'y': state.textOffset.dy,
      },
      'textScale': state.textScale,
      'textRotation': state.textRotation,
      'isMuted': state.isMuted,
      if (state.stickers.isNotEmpty)
        'stickers': state.stickers.map((s) => s.toJson()).toList(),
    };

    final duration = state.isVideoMode ? 15.0 : 5.0;
    final backgroundColor = state.currentPreset.primaryHex;

    final params = CreateStoryParams(
      filePath: state.selectedFilePath,
      mediaType: state.mediaType,
      caption: state.caption.trim().isNotEmpty ? state.caption.trim() : null,
      duration: duration,
      visibility: effectiveVisibility,
      backgroundColor: backgroundColor,
      metadata: metadata,
    );

    final result = await _createStoryUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isPublishing: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (story) {
        state = state.copyWith(
          isPublishing: false,
          createdStory: story,
        );
        _storiesNotifier.addCreatedStory(story);
        return story;
      },
    );
  }
}
