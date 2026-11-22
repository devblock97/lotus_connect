import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';
import 'package:lotus_connect/features/chill/application/chill_provider.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_comments_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_options_sheet.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_providers.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends ConsumerStatefulWidget {
  const VideoItem({
    required this.chill,
    required this.isActive,
    required this.initialPosition,
    this.externalController,
    this.isExternalInitialized = false,
    this.hasExternalError = false,
    this.usesExternalController = false,
    super.key,
  });

  final ChillItem chill;
  final bool isActive;
  final Duration initialPosition;
  final VideoPlayerController? externalController;
  final bool isExternalInitialized;
  final bool hasExternalError;
  final bool usesExternalController;

  @override
  ConsumerState<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends ConsumerState<VideoItem>
    with TickerProviderStateMixin {
  VideoPlayerController? _ownedController;
  bool _ownedInitialized = false;
  bool _isPlaying = false;
  bool _ownedError = false;
  bool _isExpandCaption = false;
  bool _showHeartAnimation = false;
  bool _hasRecordedCompletion = false;

  final Stopwatch _watchStopwatch = Stopwatch();

  late final AnimationController _heartAnimController;
  late final AnimationController _discAnimController;

  VideoPlayerController? get _controller => widget.usesExternalController
      ? widget.externalController
      : _ownedController;

  bool get _isInitialized => widget.usesExternalController
      ? (widget.isExternalInitialized && widget.externalController != null)
      : _ownedInitialized;

  bool get _hasError =>
      widget.chill.videoUrl.isEmpty ||
      (widget.usesExternalController ? widget.hasExternalError : _ownedError);

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    if (widget.usesExternalController) {
      _attachExternalController(widget.externalController);
      if (widget.isActive && _isInitialized) {
        _startActivePlayback();
      }
    } else if (widget.isActive) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    _reportWatchTimeIfNeeded();
    _heartAnimController.dispose();
    _discAnimController.dispose();
    if (widget.usesExternalController) {
      widget.externalController?.removeListener(_videoListener);
    } else {
      _ownedController?.removeListener(_videoListener);
      _ownedController?.dispose();
    }
    super.dispose();
  }

  void _attachExternalController(VideoPlayerController? controller) {
    controller?.addListener(_videoListener);
  }

  void _startActivePlayback() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
    unawaited(controller.play().catchError((Object _) {}));
    _watchStopwatch.start();
    unawaited(_discAnimController.repeat());
    _isPlaying = true;
  }

  void _pauseActivePlayback() {
    unawaited(_controller?.pause().catchError((Object _) {}));
    _watchStopwatch.stop();
    _discAnimController.stop();
    _reportWatchTimeIfNeeded();
    _isPlaying = false;
  }

  @override
  void didUpdateWidget(covariant VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.usesExternalController) {
      if (oldWidget.externalController != widget.externalController) {
        oldWidget.externalController?.removeListener(_videoListener);
        _attachExternalController(widget.externalController);
      }

      final becameReadyWhileActive = widget.isActive &&
          _isInitialized &&
          (!oldWidget.isExternalInitialized ||
              oldWidget.externalController != widget.externalController);

      if (widget.isActive && !oldWidget.isActive) {
        if (_isInitialized) {
          _startActivePlayback();
          setState(() {});
        }
      } else if (!widget.isActive && oldWidget.isActive) {
        _pauseActivePlayback();
        setState(() {});
      } else if (becameReadyWhileActive) {
        _startActivePlayback();
        setState(() {});
      }
      return;
    }

    if (widget.isActive && !oldWidget.isActive) {
      if (_ownedController == null) {
        _initVideo();
      } else if (_ownedInitialized) {
        _startActivePlayback();
        setState(() {});
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _pauseActivePlayback();
      setState(() {});
    }
  }

  void _reportWatchTimeIfNeeded() {
    final watchedSeconds = _watchStopwatch.elapsedMilliseconds / 1000.0;
    if (watchedSeconds >= 1.5 && mounted) {
      _watchStopwatch.reset();
      unawaited(
        ref.read(chillNotifierProvider.notifier).recordView(
              widget.chill.id,
              watchTimeSeconds: watchedSeconds,
              isCompleted: _hasRecordedCompletion,
            ),
      );
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) {
      return;
    }
    final value = _controller!.value;
    final duration = value.duration;
    final position = value.position;

    if (!_hasRecordedCompletion &&
        duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 400) {
      _hasRecordedCompletion = true;
    }

    if (value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = value.isPlaying;
      });
    }
  }

  Future<void> _initVideo() async {
    final rawUrl = widget.chill.videoUrl;
    if (rawUrl.isEmpty) {
      setState(() => _ownedError = true);
      return;
    }

    final settings = ref.read(settingsNotifierProvider).settings;
    final isMuted = ref.read(chillNotifierProvider).isMuted;
    final preCache = ref.read(videoPreCacheManagerProvider);

    final normalizedUrl = normalizeMediaUrl(
      rawUrl,
      serverHost: settings.serverHost,
    );
    final playableUrl = await preCache.getPlayableUrlAsync(normalizedUrl);
    if (!mounted) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(playableUrl),
    );
    _ownedController = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(isMuted ? 0.0 : 1.0);

      if (widget.initialPosition > Duration.zero) {
        await controller.seekTo(widget.initialPosition);
      }

      controller.addListener(_videoListener);

      if (mounted && widget.isActive) {
        setState(() {
          _ownedInitialized = true;
          _isPlaying = true;
          _ownedError = false;
        });
        _watchStopwatch.start();
        unawaited(_discAnimController.repeat());
        await controller.play();
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _ownedError = true;
        });
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsNotifierProvider).settings;
    final isAuthor = (settings.userId.isNotEmpty &&
            settings.userId == widget.chill.author.id) ||
        (settings.username.isNotEmpty &&
            settings.username.toLowerCase() ==
                widget.chill.author.username.toLowerCase());

    // Listen to global mute state changes
    ref.listen<bool>(
      chillNotifierProvider.select((s) => s.isMuted),
      (prev, next) {
        _controller?.setVolume(next ? 0.0 : 1.0);
      },
    );

    final chill = widget.chill;
    final thumbUrl =
        chill.thumbnailUrl != null && chill.thumbnailUrl!.isNotEmpty
            ? normalizeMediaUrl(
                chill.thumbnailUrl!,
                serverHost: settings.serverHost,
              )
            : null;
    final avatarUrl =
        chill.author.avatarUrl != null && chill.author.avatarUrl!.isNotEmpty
            ? normalizeMediaUrl(
                chill.author.avatarUrl!,
                serverHost: settings.serverHost,
              )
            : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video & Thumbnail Layer with Gesture Detector
        GestureDetector(
          onTap: _togglePlayPause,
          onDoubleTap: _handleDoubleTap,
          behavior: HitTestBehavior.opaque,
          child: ColoredBox(
            color: AppColor.mediaBackdrop.of(context),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbUrl != null)
                  Center(
                    child: AspectRatio(
                      aspectRatio:
                          chill.aspectRatio > 0 ? chill.aspectRatio : 9 / 16,
                      child: CachedNetworkImage(
                        imageUrl: thumbUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => AppGap.shrink,
                      ),
                    ),
                  ),
                if (_isInitialized && _controller != null && !_hasError)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio > 0
                          ? _controller!.value.aspectRatio
                          : chill.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                else if (_hasError)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: AppColor.onMedia54.of(context),
                          size: AppSize.iconXl,
                        ),
                        AppGap.vSm,
                        Text(
                          loc.unableToPlayVideo,
                          style: TextStyle(
                            color: AppColor.onMedia60.of(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: CircularProgressIndicator(
                      color: AppColor.onMedia.of(context),
                      strokeWidth: AppSize.borderThick,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 2. Bottom Gradient Shadow for text legibility
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 260,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColor.mediaBackdrop.of(context).withValues(alpha: 0.85),
                    AppColor.mediaBackdrop.of(context).withValues(alpha: 0.35),
                    AppColor.transparent.of(context),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 3. Center Play Indicator when Paused
        if (_isInitialized && !_isPlaying)
          IgnorePointer(
            child: Center(
              child: Container(
                padding: AppPadding.lg,
                decoration: BoxDecoration(
                  color: AppColor.mediaBackdrop
                      .of(context)
                      .withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.play_fill,
                  color: AppColor.onMedia.of(context),
                  size: AppSize.iconXxl,
                ),
              ),
            ),
          ),

        // 4. Double-Tap Heart Burst Animation
        if (_showHeartAnimation)
          IgnorePointer(
            child: Center(
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.7,
                  end: 1.4,
                ).animate(
                  CurvedAnimation(
                    parent: _heartAnimController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Icon(
                  CupertinoIcons.heart_fill,
                  color: AppColor.dangerAccent.of(context),
                  size: AppSize.avatarProfile,
                ),
              ),
            ),
          ),

        // 5. Right Action Column (Like, Comment, Share, Save, Options, Disc)
        Positioned(
          right: AppSize.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSize.xxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: chill.userHasLiked
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: chill.userHasLiked
                    ? AppColor.dangerAccent.of(context)
                    : AppColor.onMedia.of(context),
                label: _formatCount(chill.likeCount),
                onPressed: _toggleLike,
              ),
              AppGap.vLg,
              _buildActionButton(
                icon: CupertinoIcons.chat_bubble_fill,
                color: AppColor.onMedia.of(context),
                label: _formatCount(chill.commentCount),
                onPressed: () => _openComments(context),
              ),
              AppGap.vLg,
              _buildActionButton(
                icon: CupertinoIcons.arrowshape_turn_up_right_fill,
                color: AppColor.onMedia.of(context),
                label: _formatCount(chill.shareCount),
                onPressed: () => _handleShare(context),
              ),
              AppGap.vLg,
              _buildActionButton(
                icon: chill.userHasSaved
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                color: chill.userHasSaved
                    ? AppColor.amber.of(context)
                    : AppColor.onMedia.of(context),
                label: chill.userHasSaved ? loc.saved : loc.save,
                onPressed: _toggleSave,
              ),
              AppGap.vMd,
              _buildActionButton(
                icon: CupertinoIcons.ellipsis,
                color: AppColor.onMedia.of(context),
                label: '',
                onPressed: () => _openOptions(context, isAuthor: isAuthor),
              ),
              AppGap.vLg,
              // Rotating Audio Disc
              RotationTransition(
                turns: _discAnimController,
                child: Container(
                  width: AppSize.avatarMd,
                  height: AppSize.avatarMd,
                  padding: const EdgeInsets.all(AppSize.chipVertical),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.mediaLoaderBg.of(context),
                    border: AppBorder.all(
                      AppColor.onMedia38.of(context),
                      width: AppSize.borderMedium,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColor.dangerAccent.of(context),
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Icon(
                            CupertinoIcons.music_note,
                            color: AppColor.onMedia.of(context),
                            size: AppSize.iconXs,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 6. Bottom Author, Caption, Tags & Audio Metadata
        Positioned(
          left: AppSize.md,
          right: AppSize.giant + AppSize.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSize.xl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Author Row
              GestureDetector(
                onTap: () {
                  _controller?.pause();
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        userId: chill.author.id,
                        initialUsername: chill.author.username,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: AppSize.avatarMd / 2,
                      backgroundColor: AppColor.onMedia24.of(context),
                      backgroundImage: avatarUrl != null
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              chill.author.initials,
                              style: TextStyle(
                                color: AppColor.onMedia.of(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            )
                          : null,
                    ),
                    AppGap.hSm,
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chill.author.fullName ?? chill.author.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.onMedia.of(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '@${chill.author.username}',
                            style: TextStyle(
                              color: AppColor.onMedia70.of(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGap.hSm,
                    // View count pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.sm,
                        vertical: AppSize.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.mediaScrim45.of(context),
                        borderRadius: AppRadius.md,
                        border: AppBorder.all(
                          AppColor.onMedia24.of(context),
                          width: AppSize.borderHairline,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.eye_fill,
                            color: AppColor.onMedia70.of(context),
                            size: AppSize.iconXxs,
                          ),
                          AppGap.hXs,
                          Text(
                            _formatCount(chill.viewCount),
                            style: TextStyle(
                              color: AppColor.onMedia.of(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.vMd,

              // Caption
              if (chill.caption.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpandCaption = !_isExpandCaption;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chill.caption,
                        maxLines: _isExpandCaption ? 12 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.onMedia.of(context),
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                      if (chill.caption.length > 70)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSize.xxs),
                          child: Text(
                            _isExpandCaption ? loc.showLess : loc.showMore,
                            style: TextStyle(
                              color: AppColor.onMedia60.of(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AppGap.vSm,
              ],

              // Clickable #tags
              if (chill.tags.isNotEmpty) ...[
                Wrap(
                  spacing: AppSize.sm,
                  runSpacing: AppSize.xs,
                  children: chill.tags.map((tag) {
                    final cleanTag = tag.replaceFirst('#', '');
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(chillNotifierProvider.notifier)
                            .setTagFilter(cleanTag);
                      },
                      child: Text(
                        '#$cleanTag',
                        style: TextStyle(
                          color: AppColor.onMedia.of(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppGap.vSm,
              ],

              // Audio Track Info Row
              Row(
                children: [
                  Icon(
                    CupertinoIcons.music_note_2,
                    color: AppColor.onMedia.of(context),
                    size: AppSize.iconXs,
                  ),
                  AppGap.hSm,
                  Expanded(
                    child: Text(
                      chill.audioTitle ??
                          chill.audio?.title ??
                          loc.originalAudioByAuthor(
                            chill.author.fullName ?? chill.author.username,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.onMedia.of(context),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (chill.isRemix) ...[
                    AppGap.hSm,
                    Container(
                      padding: AppPadding.badge,
                      decoration: BoxDecoration(
                        color: AppColor.onMedia24.of(context),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Text(
                        loc.remix,
                        style: TextStyle(
                          color: AppColor.onMedia.of(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // 7. Bottom Interactive Video Progress Indicator
        if (_isInitialized && _controller != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColor.dangerAccent.of(context),
                bufferedColor: AppColor.onMedia24.of(context),
                backgroundColor: AppColor.onMedia10.of(context),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _togglePlayPause() async {
    unawaited(HapticFeedback.selectionClick());
    if (_controller != null && _isInitialized) {
      if (_isPlaying) {
        await _controller!.pause();
        _watchStopwatch.stop();
        _discAnimController.stop();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _controller!.play();
        _watchStopwatch.start();
        unawaited(_discAnimController.repeat());
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    unawaited(HapticFeedback.lightImpact());
    final newLiked = !widget.chill.userHasLiked;
    await ref.read(chillNotifierProvider.notifier).reactions(
          widget.chill.id,
          newLiked,
        );
  }

  Future<void> _toggleSave() async {
    unawaited(HapticFeedback.selectionClick());
    final newSaved = !widget.chill.userHasSaved;
    await ref.read(chillNotifierProvider.notifier).toggleSave(
          widget.chill.id,
          isSaved: newSaved,
        );
  }

  Future<void> _handleDoubleTap() async {
    unawaited(HapticFeedback.mediumImpact());
    if (!widget.chill.userHasLiked) {
      await _toggleLike();
    }
    setState(() => _showHeartAnimation = true);
    await _heartAnimController.forward(from: 0);
    if (mounted) {
      setState(() => _showHeartAnimation = false);
    }
  }

  void _openComments(BuildContext context) {
    HapticFeedback.selectionClick();
    PostCommentsSheet.show(
      context,
      post: widget.chill.toPostItem(),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    unawaited(HapticFeedback.selectionClick());
    final loc = AppLocalizations.of(context)!;
    await Clipboard.setData(
      ClipboardData(
        text: 'https://lotusconnect.app/chills/${widget.chill.id}',
      ),
    );
    await ref.read(chillNotifierProvider.notifier).shareChill(widget.chill.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.chillLinkCopied),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openOptions(BuildContext context, {required bool isAuthor}) {
    HapticFeedback.selectionClick();
    final loc = AppLocalizations.of(context)!;
    PostOptionsSheet.show(
      context,
      post: widget.chill.toPostItem(),
      isAuthor: isAuthor,
      onDelete: () async {
        final deleted = await ref
            .read(chillNotifierProvider.notifier)
            .deleteChill(widget.chill.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                deleted ? loc.chillDeletedSuccess : loc.chillDeleteFailed,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: AppPadding.sm,
            decoration: BoxDecoration(
              color: AppColor.mediaBackdrop.of(context).withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSize.iconLg,
            ),
          ),
          if (label.isNotEmpty) ...[
            AppGap.vXs,
            Text(
              label,
              style: TextStyle(
                color: AppColor.onMedia.of(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
