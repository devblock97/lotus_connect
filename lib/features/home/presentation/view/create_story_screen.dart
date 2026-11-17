import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/home/application/create_story_notifier.dart';
import 'package:lotus_connect/features/home/application/create_story_state.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/presentation/models/story_filter.dart';
import 'package:lotus_connect/features/home/presentation/models/story_sticker_item.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_audience_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_draggable_item.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_sticker_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_text_editor_modal.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_trash_bin.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({
    super.key,
    this.initialImagePath,
    this.initialVideoPath,
  });

  final String? initialImagePath;
  final String? initialVideoPath;

  @override
  ConsumerState<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;

  bool _isDragging = false;
  bool _isOverTrash = false;
  String? _activeDraggingId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(createStoryNotifierProvider.notifier);
      if (widget.initialImagePath != null) {
        notifier.setImagePath(widget.initialImagePath!);
      } else if (widget.initialVideoPath != null) {
        notifier.setVideoPath(widget.initialVideoPath!);
        _initVideoController(widget.initialVideoPath!);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initVideoController(String path) async {
    await _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(File(path));
    try {
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      await _videoPlayerController!.play();
      if (mounted) setState(() {});
    } on Object catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (picked != null) {
        await _videoPlayerController?.dispose();
        _videoPlayerController = null;
        ref
            .read(createStoryNotifierProvider.notifier)
            .setImagePath(picked.path);
      }
    } on Object catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc?.failedToPickImage(e.toString()) ??
                  'Failed to pick image: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picked = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );
      if (picked != null) {
        ref
            .read(createStoryNotifierProvider.notifier)
            .setVideoPath(picked.path);
        await _initVideoController(picked.path);
      }
    } on Object catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc?.failedToPickVideo(e.toString()) ??
                  'Failed to pick video: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openTextEditor() async {
    final state = ref.read(createStoryNotifierProvider);
    final notifier = ref.read(createStoryNotifierProvider.notifier);

    final result = await StoryTextEditorModal.show(
      context,
      initialText: state.caption,
      initialFontFamily: state.fontFamily,
      initialColor: state.textColor,
      initialAlign: state.textAlign,
      initialHighlight: state.hasTextHighlight,
    );

    if (result != null) {
      notifier
        ..updateCaption(result.text)
        ..updateTextStyle(
          fontFamily: result.fontFamily,
          textColor: result.textColor,
          textAlign: result.textAlign,
          hasTextHighlight: result.hasHighlight,
        );
    }
  }

  Future<void> _openStickers() async {
    final sticker = await StoryStickerSheet.show(context);
    if (sticker != null) {
      ref.read(createStoryNotifierProvider.notifier).addSticker(sticker);
    }
  }

  void _cycleFilter() {
    final state = ref.read(createStoryNotifierProvider);
    final currentIndex =
        kStoryFilters.indexWhere((f) => f.id == state.selectedFilterId);
    final nextIndex = (currentIndex + 1) % kStoryFilters.length;
    final nextFilter = kStoryFilters[nextIndex];
    ref.read(createStoryNotifierProvider.notifier).setFilter(nextFilter.id);

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc?.filterApplied(nextFilter.name) ?? 'Filter: ${nextFilter.name}',
        ),
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _checkTrashHover(Offset focalPoint) {
    final size = MediaQuery.of(context).size;
    final trashCenter = Offset(size.width / 2, size.height - 70);
    final distance = (focalPoint - trashCenter).distance;

    final overTrash = distance < 85;
    if (overTrash != _isOverTrash) {
      if (overTrash) {
        HapticFeedback.selectionClick();
      }
      setState(() => _isOverTrash = overTrash);
    }
  }

  void _handleDragEnd() {
    if (_isOverTrash && _activeDraggingId != null) {
      HapticFeedback.mediumImpact();
      if (_activeDraggingId == 'caption') {
        ref.read(createStoryNotifierProvider.notifier).removeCaption();
      } else {
        ref
            .read(createStoryNotifierProvider.notifier)
            .removeSticker(_activeDraggingId!);
      }
    }

    setState(() {
      _isDragging = false;
      _isOverTrash = false;
      _activeDraggingId = null;
    });
  }

  Future<void> _submitStory({String? customVisibility}) async {
    await HapticFeedback.mediumImpact();
    final notifier = ref.read(createStoryNotifierProvider.notifier);
    final story =
        await notifier.submitStory(customVisibility: customVisibility);

    if (!mounted) return;

    final loc = AppLocalizations.of(context);
    if (story != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            customVisibility == 'close_friends'
                ? (loc?.sharedToCloseFriends ?? 'Shared to Close Friends! ⭐️')
                : (loc?.sharedToYourStory ?? 'Shared to your story! ✨'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      final error = ref.read(createStoryNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ??
                (loc?.failedToShareStory ??
                    'Failed to share story. Please try again.'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleClose() async {
    final state = ref.read(createStoryNotifierProvider);
    if (state.hasContent) {
      final loc = AppLocalizations.of(context);
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF24242A),
          title: Text(
            loc?.discardStoryTitle ?? 'Discard story?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            loc?.discardStoryMessage ??
                "If you go back now, you'll lose any edits you made.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(loc?.keepEditing ?? 'Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(loc?.discard ?? 'Discard'),
            ),
          ],
        ),
      );

      if ((shouldDiscard ?? false) && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final storyState = ref.watch(createStoryNotifierProvider);
    final notifier = ref.read(createStoryNotifierProvider.notifier);
    final settings = ref.watch(settingsNotifierProvider).settings;
    final canvasSize = MediaQuery.of(context).size;

    final currentFilter = kStoryFilters.firstWhere(
      (f) => f.id == storyState.selectedFilterId,
      orElse: () => kStoryFilters.first,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Story Canvas
          GestureDetector(
            onTap: _openTextEditor,
            child: _buildStoryCanvas(storyState, currentFilter, loc),
          ),

          // Stickers overlay layer (freely draggable & scalable)
          ...storyState.stickers.map((sticker) {
            return _buildInteractiveSticker(sticker, notifier, canvasSize);
          }),

          // Text overlay layer (freely draggable & scalable)
          if (storyState.caption.isNotEmpty)
            _buildCaptionOverlay(storyState, notifier, canvasSize),

          StoryTrashBin(
            isVisible: _isDragging,
            isOverTrash: _isOverTrash,
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isDragging ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: IgnorePointer(
                ignoring: _isDragging,
                child: SafeArea(
                  child: Padding(
                    padding: AppPadding.buttonCompact,
                    child: Row(
                      children: [
                        // Close button
                        _buildTopIconButton(
                          icon: Icons.close,
                          onTap: _handleClose,
                        ),

                        const Spacer(),

                        // Text tool button (Aa)
                        _buildTopIconButton(
                          icon: Icons.title,
                          tooltip: loc?.textToolTooltip ?? 'Text',
                          onTap: _openTextEditor,
                        ),
                        AppGap.hSm,

                        // Color palette button (gradients)
                        _buildTopIconButton(
                          icon: Icons.palette_outlined,
                          tooltip: loc?.backgroundGradientTooltip ??
                              'Background gradient',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.cycleBackgroundPreset();
                          },
                        ),
                        AppGap.hSm,

                        // Filter button (Stars)
                        _buildTopIconButton(
                          icon: Icons.auto_awesome_outlined,
                          tooltip: loc?.photoFilterTooltip ?? 'Photo filter',
                          onTap: _cycleFilter,
                        ),
                        AppGap.hSm,

                        // Stickers button
                        _buildTopIconButton(
                          icon: CupertinoIcons.smiley,
                          tooltip: loc?.stickersTooltip ?? 'Stickers',
                          onTap: _openStickers,
                        ),

                        // Video audio mute toggle if video
                        if (storyState.isVideoMode) ...[
                          AppGap.hSm,
                          _buildTopIconButton(
                            icon: storyState.isMuted
                                ? CupertinoIcons.volume_off
                                : CupertinoIcons.volume_up,
                            onTap: () {
                              notifier.toggleMute();
                              _videoPlayerController?.setVolume(
                                storyState.isMuted ? 1.0 : 0.0,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls & Sharing Bar
          Positioned(
            bottom: AppSize.none,
            left: AppSize.none,
            right: AppSize.none,
            child: AnimatedOpacity(
              opacity: _isDragging ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: IgnorePointer(
                ignoring: _isDragging,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mode Picker Pills (Create / Gallery / Camera)
                      _buildModeSelector(storyState, notifier, loc),
                      AppGap.vMd,

                      _buildInstagramShareBar(settings, storyState, loc),
                      AppGap.vSm,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Publishing Loading Indicator Overlay
          if (storyState.isPublishing)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: AppSize.iconXxl,
                    height: AppSize.iconXxl,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSize.borderHeavy,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  AppGap.vLg,
                  Text(
                    loc?.sharingStory ?? 'Sharing story...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryCanvas(
    CreateStoryState state,
    StoryFilter filter,
    AppLocalizations? loc,
  ) {
    Widget content;

    if (state.isImageMode && state.selectedFilePath != null) {
      final file = File(state.selectedFilePath!);
      Widget imageWidget = Image.file(
        file,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );

      if (filter.colorFilter != null) {
        imageWidget = ColorFiltered(
          colorFilter: filter.colorFilter!,
          child: imageWidget,
        );
      }
      content = imageWidget;
    } else if (state.isVideoMode &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      content = Center(
        child: AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController!),
        ),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          gradient: state.currentPreset.gradient,
        ),
        alignment: Alignment.center,
        child: state.caption.isEmpty
            ? Center(
                child: Text(
                  loc?.tapToType ?? 'Tap to type',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : AppGap.shrink,
      );
    }

    return content;
  }

  Widget _buildCaptionOverlay(
    CreateStoryState state,
    CreateStoryNotifier notifier,
    Size canvasSize,
  ) {
    return StoryDraggableItem(
      offset: state.textOffset,
      scale: state.textScale,
      rotation: state.textRotation,
      canvasSize: canvasSize,
      onTap: _openTextEditor,
      onDragStart: () {
        setState(() {
          _isDragging = true;
          _activeDraggingId = 'caption';
        });
      },
      onDragUpdate: _checkTrashHover,
      onTransformUpdate: (newOffset, newScale, newRotation) {
        notifier.updateTextTransform(
          offset: newOffset,
          scale: newScale,
          rotation: newRotation,
        );
      },
      onDragEnd: _handleDragEnd,
      child: _buildCaptionContent(state),
    );
  }

  Widget _buildCaptionContent(CreateStoryState state) {
    TextStyle base;
    switch (state.fontFamily) {
      case 'RobotoMono':
        base = GoogleFonts.robotoMono();
      case 'Caveat':
        base = GoogleFonts.caveat();
      case 'PlayfairDisplay':
        base = GoogleFonts.playfairDisplay();
      case 'BebasNeue':
        base = GoogleFonts.bebasNeue();
      case 'Inter':
      default:
        base = GoogleFonts.inter();
    }

    final effectiveColor =
        state.hasTextHighlight && state.textColor == Colors.white
            ? Colors.black
            : state.textColor;

    final style = base.copyWith(
      color: effectiveColor,
      fontSize: state.fontFamily == 'Caveat' ? 34 : 26,
      fontWeight: FontWeight.w700,
      letterSpacing: state.fontFamily == 'BebasNeue' ? 1.5 : -0.3,
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding:
          state.hasTextHighlight ? AppPadding.buttonCompact : AppPadding.zero,
      decoration: state.hasTextHighlight
          ? BoxDecoration(
              color: state.textColor == Colors.white
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.75),
              borderRadius: AppRadius.md,
            )
          : null,
      child: Text(
        state.caption,
        textAlign: state.textAlign,
        style: style,
      ),
    );
  }

  Widget _buildInteractiveSticker(
    StoryStickerItem sticker,
    CreateStoryNotifier notifier,
    Size canvasSize,
  ) {
    return StoryDraggableItem(
      key: ValueKey(sticker.id),
      offset: sticker.offset,
      scale: sticker.scale,
      rotation: sticker.rotation,
      canvasSize: canvasSize,
      onTap: HapticFeedback.selectionClick,
      onDragStart: () {
        setState(() {
          _isDragging = true;
          _activeDraggingId = sticker.id;
        });
      },
      onDragUpdate: _checkTrashHover,
      onTransformUpdate: (newOffset, newScale, newRotation) {
        notifier.updateStickerTransform(
          sticker.id,
          offset: newOffset,
          scale: newScale,
          rotation: newRotation,
        );
      },
      onDragEnd: _handleDragEnd,
      child: _buildStickerBadge(sticker),
    );
  }

  Widget _buildStickerBadge(StoryStickerItem sticker) {
    switch (sticker.type) {
      case StoryStickerType.location:
        return Container(
          padding: AppPadding.buttonCompact,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.xl,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFFFF3B30),
                size: AppSize.iconSm,
              ),
              AppGap.hSm,
              Text(
                sticker.text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      case StoryStickerType.time:
        return Container(
          padding: AppPadding.buttonCompact,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: AppRadius.xl,
            border: AppBorder.all(Colors.white30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.time,
                color: Colors.white,
                size: AppSize.iconXs,
              ),
              AppGap.hSm,
              Text(
                sticker.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      case StoryStickerType.mention:
        return Container(
          padding: AppPadding.buttonCompact,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF2D55), Color(0xFFFF9500)],
            ),
            borderRadius: AppRadius.xl,
          ),
          child: Text(
            sticker.text.startsWith('@') ? sticker.text : '@${sticker.text}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        );
      case StoryStickerType.tag:
        return Container(
          padding: AppPadding.buttonCompact,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: AppRadius.xl,
          ),
          child: Text(
            sticker.text,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        );
      case StoryStickerType.emoji:
        return Text(
          sticker.text,
          style: const TextStyle(
            fontSize: 48,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildTopIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.iconButtonMd,
        height: AppSize.iconButtonMd,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: AppSize.iconSm),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }
    return button;
  }

  Widget _buildModeSelector(
    CreateStoryState state,
    CreateStoryNotifier notifier,
    AppLocalizations? loc,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.sm,
        vertical: AppSize.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: AppRadius.xxl,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeChip(
            label: loc?.modeCreate ?? 'Create',
            icon: Icons.title,
            isSelected: state.isTextMode,
            onTap: () {
              notifier.clearMedia();
              _videoPlayerController?.pause();
            },
          ),
          AppGap.hXs,
          _buildModeChip(
            label: loc?.modeGallery ?? 'Gallery',
            icon: Icons.photo_library_outlined,
            isSelected: state.isImageMode || state.isVideoMode,
            onTap: _showMediaPickerSheet,
          ),
          AppGap.hXs,
          _buildModeChip(
            label: loc?.modeCamera ?? 'Camera',
            icon: Icons.camera_alt_outlined,
            isSelected: false,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.chip,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: AppRadius.lg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: AppSize.iconXs),
            AppGap.hXs,
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaPickerSheet() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSize.radiusXl),
        ),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.white),
              title: Text(
                loc?.pickPhoto ?? 'Pick Photo',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.white),
              title: Text(
                loc?.pickVideo ?? 'Pick Video',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _pickVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramShareBar(
    AppSettings settings,
    CreateStoryState storyState,
    AppLocalizations? loc,
  ) {
    final avatarUrl = settings.avatarUrl;
    final initials =
        settings.fullName.isNotEmpty ? settings.fullName[0].toUpperCase() : 'U';

    return Padding(
      padding: AppPadding.hLg,
      child: Row(
        children: [
          // "Your story" Button (Instant Public share)
          Expanded(
            child: GestureDetector(
              onTap: () => _submitStory(customVisibility: 'public'),
              child: Container(
                height: AppSize.buttonHeightMd,
                padding: AppPadding.hSm,
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: AppRadius.xxl,
                  border: AppBorder.all(Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // User Avatar Thumbnail
                    Container(
                      width: AppSize.avatarXs,
                      height: AppSize.avatarXs,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3E3E48),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: avatarUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, dynamic ___) => Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    AppGap.hSm,
                    Flexible(
                      child: Text(
                        loc?.yourStory ?? 'Your story',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppGap.hSm,

          // "Close Friends" Button
          // (Instant Close Friends share with green star)
          Expanded(
            child: GestureDetector(
              onTap: () => _submitStory(customVisibility: 'close_friends'),
              child: Container(
                height: AppSize.buttonHeightMd,
                padding: AppPadding.hSm,
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: AppRadius.xxl,
                  border: AppBorder.all(Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Green Star Badge
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                      child: SizedBox(
                        width: AppSize.avatarBadgeMd,
                        height: AppSize.avatarBadgeMd,
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                          size: AppSize.iconXs,
                        ),
                      ),
                    ),
                    AppGap.hSm,
                    Flexible(
                      child: Text(
                        loc?.closeFriends ?? 'Close Friends',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppGap.hSm,

          // Custom Send Arrow Button (Opens Audience selector Sheet)
          GestureDetector(
            onTap: () async {
              final audience = await StoryAudienceSheet.show(
                context,
                storyState.visibility,
              );
              if (audience != null) {
                await _submitStory(customVisibility: audience);
              }
            },
            child: Container(
              width: AppSize.buttonHeightMd,
              height: AppSize.buttonHeightMd,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.black,
                size: AppSize.iconLg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
