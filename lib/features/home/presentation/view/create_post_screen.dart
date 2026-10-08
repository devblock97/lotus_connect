import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/features/home/application/create_post_notifier.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_feeling_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_location_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_privacy_sheet.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';

class ColorPreset {
  const ColorPreset({
    required this.id,
    required this.colors,
    this.name = '',
  });

  final String id;
  final List<Color> colors;
  final String name;

  bool get isNone => id == 'none';
}

const List<ColorPreset> kColorPresets = [
  ColorPreset(id: 'none', colors: [], name: 'Default'),
  ColorPreset(
    id: 'sunset',
    name: 'Sunset',
    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
  ),
  ColorPreset(
    id: 'ocean',
    name: 'Ocean',
    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
  ),
  ColorPreset(
    id: 'cosmic',
    name: 'Cosmic',
    colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
  ),
  ColorPreset(
    id: 'emerald',
    name: 'Emerald',
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  ),
  ColorPreset(
    id: 'midnight',
    name: 'Midnight',
    colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
  ),
  ColorPreset(
    id: 'lavender',
    name: 'Lavender',
    colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
  ),
];

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({
    super.key,
    this.initialMediaPaths = const [],
    this.postToEdit,
  });

  final List<String> initialMediaPaths;
  final PostItem? postToEdit;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  String _selectedPresetId = 'none';
  bool _showColorPicker = false;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _textController.text = widget.postToEdit!.content;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.postToEdit != null) {
        ref
            .read(createPostNotifierProvider.notifier)
            .initializeForEdit(widget.postToEdit!);
      } else if (widget.initialMediaPaths.isNotEmpty) {
        ref
            .read(createPostNotifierProvider.notifier)
            .addMediaPaths(widget.initialMediaPaths);
      }
    });

    _textController.addListener(() {
      ref
          .read(createPostNotifierProvider.notifier)
          .updateContent(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(createPostNotifierProvider);
    if (!state.canSubmit) {
      return true;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard post?'),
        content: const Text(
          'If you go back now, your current post draft and attachments will '
          'be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  Future<void> _handlePickGallery() async {
    try {
      final medias = await _picker.pickMultipleMedia();
      if (medias.isNotEmpty) {
        setState(() {
          _selectedPresetId = 'none';
          _showColorPicker = false;
        });
        ref.read(createPostNotifierProvider.notifier).addMediaPaths(
              medias.map((m) => m.path).toList(),
            );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  Future<void> _handlePickCamera() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedPresetId = 'none';
          _showColorPicker = false;
        });
        ref.read(createPostNotifierProvider.notifier).addMediaPaths(
          [photo.path],
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(createPostNotifierProvider.notifier);
    _focusNode.unfocus();

    final isEditing = widget.postToEdit != null;
    final post = await notifier.submitPost();
    if (post != null && mounted) {
      HapticFeedback.mediumImpact().ignore();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isEditing
                    ? 'Post updated successfully!'
                    : 'Post shared successfully!',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    final state = ref.watch(createPostNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider).settings;

    final displayName = settings.fullName.isNotEmpty
        ? settings.fullName
        : (settings.username.isNotEmpty ? settings.username : 'You');
    final avatarUrl = settings.avatarUrl;

    final activePreset = kColorPresets.firstWhere(
      (p) => p.id == _selectedPresetId,
      orElse: () => kColorPresets.first,
    );

    return PopScope(
      canPop: !state.canSubmit,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: primaryTextColor),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                navigator.pop();
              }
            },
          ),
          title: Text(
            widget.postToEdit != null ? 'Edit post' : 'Create post',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
              child: AnimatedOpacity(
                opacity: state.canSubmit ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: FilledButton(
                  onPressed: state.canSubmit && !state.isSubmitting
                      ? _handleSubmit
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.postToEdit != null ? 'Save' : 'Post',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Author header row with Privacy Selector
                        _buildAuthorHeader(
                          context,
                          theme,
                          displayName,
                          avatarUrl,
                          state,
                          primaryTextColor,
                          subtextColor,
                        ),

                        const SizedBox(height: 16),

                        // Error Banner if present
                        if (state.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Text Field / Facebook Colored Background Card
                        if (activePreset.isNone ||
                            state.mediaPaths.isNotEmpty ||
                            state.existingMediaItems.isNotEmpty)
                          _buildStandardTextField(displayName, primaryTextColor)
                        else
                          _buildColoredBackgroundCard(
                            displayName,
                            activePreset,
                          ),

                        const SizedBox(height: 16),

                        // Media items gallery if any attached
                        if (state.mediaPaths.isNotEmpty ||
                            state.existingMediaItems.isNotEmpty)
                          _buildMediaGallery(
                            theme,
                            state.existingMediaItems,
                            state.mediaPaths,
                          ),

                        // Facebook-style Color Swatches
                        if (_showColorPicker &&
                            state.mediaPaths.isEmpty &&
                            state.existingMediaItems.isEmpty)
                          _buildColorSwatches(theme),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // Facebook & Instagram style bottom "Add to your post" toolbar
                _buildBottomToolbar(context, theme, primaryTextColor),
              ],
            ),

            // Loading / Submitting Overlay
            if (state.isSubmitting)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.mediaPaths.isNotEmpty
                            ? 'Uploading media & publishing...'
                            : (widget.postToEdit != null
                                ? 'Saving changes...'
                                : 'Publishing post...'),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader(
    BuildContext context,
    ThemeData theme,
    String displayName,
    String avatarUrl,
    CreatePostState state,
    Color primaryTextColor,
    Color subtextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: avatarUrl.isNotEmpty
              ? CachedNetworkImageProvider(avatarUrl)
              : null,
          child: avatarUrl.isEmpty
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Name + Feeling + Location
              RichText(
                text: TextSpan(
                  text: displayName,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                  children: [
                    if (state.feeling != null) ...[
                      TextSpan(
                        text: ' is feeling ',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: subtextColor,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: '${state.feelingEmoji ?? ''} ${state.feeling}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (state.location != null) ...[
                      TextSpan(
                        text: ' at ',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: subtextColor,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: state.location,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Privacy Selector Button
              GestureDetector(
                onTap: () async {
                  final chosen = await PostPrivacySheet.show(
                    context,
                    state.visibility,
                  );
                  if (chosen != null) {
                    ref
                        .read(createPostNotifierProvider.notifier)
                        .updateVisibility(chosen);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getVisibilityIcon(state.visibility),
                        size: 13,
                        color: subtextColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _getVisibilityLabel(state.visibility),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: subtextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'friends':
        return CupertinoIcons.person_2_fill;
      case 'private':
        return CupertinoIcons.lock_fill;
      default:
        return CupertinoIcons.globe;
    }
  }

  String _getVisibilityLabel(String visibility) {
    switch (visibility) {
      case 'friends':
        return 'Friends';
      case 'private':
        return 'Only me';
      default:
        return 'Public';
    }
  }

  Widget _buildStandardTextField(String displayName, Color primaryTextColor) {
    final firstName = displayName.split(' ').first;
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      maxLines: null,
      minLines: 3,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
        fontSize: 17,
        height: 1.4,
        color: primaryTextColor,
      ),
      decoration: InputDecoration(
        hintText: "What's on your mind, $firstName?",
        hintStyle: TextStyle(
          fontSize: 17,
          color: primaryTextColor.withValues(alpha: 0.45),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildColoredBackgroundCard(
    String displayName,
    ColorPreset preset,
  ) {
    final firstName = displayName.split(' ').first;
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: preset.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: preset.colors.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: null,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.35,
        ),
        decoration: InputDecoration(
          hintText: "What's on your mind, $firstName?",
          hintStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.65),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildColorSwatches(ThemeData theme) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kColorPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final preset = kColorPresets[index];
          final isSelected = preset.id == _selectedPresetId;

          if (preset.isNone) {
            return GestureDetector(
              onTap: () => setState(() => _selectedPresetId = 'none'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor.withValues(alpha: 0.2),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: const Icon(Icons.block, size: 18),
              ),
            );
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedPresetId = preset.id),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: preset.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: isSelected ? 3 : 0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: preset.colors.first.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaGallery(
    ThemeData theme,
    List<PostMediaItem> existingItems,
    List<String> paths,
  ) {
    final totalCount = existingItems.length + paths.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$totalCount ${totalCount == 1 ? 'item' : 'items'} '
              'selected',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _handlePickGallery,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
              label: const Text('Add more', style: TextStyle(fontSize: 12.5)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: totalCount,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final isExisting = index < existingItems.length;

              if (isExisting) {
                final media = existingItems[index];
                final isVideo = media.isVideo;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 140,
                        height: 180,
                        color: Colors.black12,
                        child: CachedNetworkImage(
                          imageUrl: media.url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      ),
                    ),
                    if (isVideo)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(createPostNotifierProvider.notifier)
                              .removeExistingMediaAt(index);
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final localIndex = index - existingItems.length;
              final path = paths[localIndex];
              final isVideo = path.toLowerCase().endsWith('.mp4') ||
                  path.toLowerCase().endsWith('.mov');

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 140,
                      height: 180,
                      color: Colors.black12,
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                  ),
                  if (isVideo)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(createPostNotifierProvider.notifier)
                            .removeMediaPathAt(localIndex);
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(
    BuildContext context,
    ThemeData theme,
    Color primaryTextColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Add to your post',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Photo / Video
            IconButton(
              tooltip: 'Photo / Video',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFF4CAF50),
                size: 22,
              ),
              splashRadius: 18,
              onPressed: _handlePickGallery,
            ),

            // Camera
            IconButton(
              tooltip: 'Camera',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF2196F3),
                size: 22,
              ),
              splashRadius: 18,
              onPressed: _handlePickCamera,
            ),

            // Feeling
            IconButton(
              tooltip: 'Feeling / Activity',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.emoji_emotions_rounded,
                color: Color(0xFFFFB300),
                size: 22,
              ),
              splashRadius: 18,
              onPressed: () async {
                final item = await PostFeelingSheet.show(
                  context,
                  current: ref.read(createPostNotifierProvider).feeling,
                );
                if (item != null) {
                  ref
                      .read(createPostNotifierProvider.notifier)
                      .setFeeling(item.label, item.emoji);
                }
              },
            ),

            // Location
            IconButton(
              tooltip: 'Location',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFFE91E63),
                size: 22,
              ),
              splashRadius: 18,
              onPressed: () async {
                final loc = await PostLocationSheet.show(
                  context,
                  current: ref.read(createPostNotifierProvider).location,
                );
                if (loc != null) {
                  ref
                      .read(createPostNotifierProvider.notifier)
                      .setLocation(loc);
                }
              },
            ),

            // Facebook Color Palette
            IconButton(
              tooltip: 'Background Color',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.palette_rounded,
                color: Color(0xFF9C27B0),
                size: 22,
              ),
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _showColorPicker = !_showColorPicker;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
