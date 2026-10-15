import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
import 'package:lotus_connect/features/home/presentation/models/story_gradient_preset.dart';
import 'package:lotus_connect/features/home/presentation/models/story_sticker_item.dart';

@immutable
class CreateStoryState {
  const CreateStoryState({
    this.mediaType = 'text',
    this.selectedFilePath,
    this.caption = '',
    this.textOffset = const Offset(0.5, 0.45),
    this.textScale = 1.0,
    this.textRotation = 0.0,
    this.selectedPresetIndex = 0,
    this.selectedFilterId = 'none',
    this.visibility = 'public',
    this.stickers = const [],
    this.fontFamily = 'Inter',
    this.textColor = Colors.white,
    this.textAlign = TextAlign.center,
    this.hasTextHighlight = false,
    this.isMuted = false,
    this.isPublishing = false,
    this.errorMessage,
    this.createdStory,
  });

  final String mediaType;

  final String? selectedFilePath;

  final String caption;

  final Offset textOffset;

  final double textScale;

  final double textRotation;

  final int selectedPresetIndex;

  final String selectedFilterId;

  final String visibility;

  final List<StoryStickerItem> stickers;

  final String fontFamily;

  final Color textColor;

  final TextAlign textAlign;

  final bool hasTextHighlight;

  final bool isMuted;

  final bool isPublishing;

  final String? errorMessage;

  final Story? createdStory;

  bool get isTextMode => mediaType == 'text';
  bool get isImageMode => mediaType == 'image';
  bool get isVideoMode => mediaType == 'video';

  bool get hasContent =>
      (selectedFilePath != null && selectedFilePath!.isNotEmpty) ||
      caption.trim().isNotEmpty ||
      stickers.isNotEmpty;

  StoryGradientPreset get currentPreset =>
      kStoryGradientPresets[selectedPresetIndex % kStoryGradientPresets.length];

  CreateStoryState copyWith({
    String? mediaType,
    String? selectedFilePath,
    String? caption,
    Offset? textOffset,
    double? textScale,
    double? textRotation,
    int? selectedPresetIndex,
    String? selectedFilterId,
    String? visibility,
    List<StoryStickerItem>? stickers,
    String? fontFamily,
    Color? textColor,
    TextAlign? textAlign,
    bool? hasTextHighlight,
    bool? isMuted,
    bool? isPublishing,
    String? errorMessage,
    Story? createdStory,
    bool clearFilePath = false,
  }) {
    return CreateStoryState(
      mediaType: mediaType ?? this.mediaType,
      selectedFilePath:
          clearFilePath ? null : (selectedFilePath ?? this.selectedFilePath),
      caption: caption ?? this.caption,
      textOffset: textOffset ?? this.textOffset,
      textScale: textScale ?? this.textScale,
      textRotation: textRotation ?? this.textRotation,
      selectedPresetIndex: selectedPresetIndex ?? this.selectedPresetIndex,
      selectedFilterId: selectedFilterId ?? this.selectedFilterId,
      visibility: visibility ?? this.visibility,
      stickers: stickers ?? this.stickers,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      hasTextHighlight: hasTextHighlight ?? this.hasTextHighlight,
      isMuted: isMuted ?? this.isMuted,
      isPublishing: isPublishing ?? this.isPublishing,
      errorMessage: errorMessage,
      createdStory: createdStory ?? this.createdStory,
    );
  }
}
