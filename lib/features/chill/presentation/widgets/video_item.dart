import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';
import 'package:lotus_connect/features/chill/application/chill_provider.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_comments_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_options_sheet.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_providers.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends ConsumerStatefulWidget {
  const VideoItem({
    required this.chill,
    required this.isActive,
    required this.initialPosition,
    super.key,
  });

  final ChillItem chill;
  final bool isActive;
  final Duration initialPosition;

  @override
  ConsumerState<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends ConsumerState<VideoItem>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isExpandCaption = false;
  bool _showHeartAnimation = false;
  bool _hasRecordedCompletion = false;

  final Stopwatch _watchStopwatch = Stopwatch();

  late final AnimationController _heartAnimController;
  late final AnimationController _discAnimController;

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

    if (widget.isActive) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    _reportWatchTimeIfNeeded();
    _heartAnimController.dispose();
    _discAnimController.dispose();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (_controller == null) {
        _initVideo();
      } else if (_isInitialized) {
        _controller?.play();
        _watchStopwatch.start();
        _discAnimController.repeat();
        setState(() {
          _isPlaying = true;
        });
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
      _watchStopwatch.stop();
      _discAnimController.stop();
      _reportWatchTimeIfNeeded();
      setState(() {
        _isPlaying = false;
      });
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
      setState(() => _hasError = true);
      return;
    }

    final settings = ref.read(settingsNotifierProvider).settings;
    final isMuted = ref.read(chillNotifierProvider).isMuted;
    final preCache = ref.read(videoPreCacheManagerProvider);

    final normalizedUrl = normalizeMediaUrl(
      rawUrl,
      serverHost: settings.serverHost,
    );
    final playableUrl = preCache.getPlayableUrl(normalizedUrl);

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(playableUrl),
    );
    _controller = controller;

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
          _isInitialized = true;
          _isPlaying = true;
          _hasError = false;
        });
        _watchStopwatch.start();
        unawaited(_discAnimController.repeat());
        await controller.play();
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
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
            color: Colors.black,
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
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
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
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: Colors.white54,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Unable to play video',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
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
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.play_fill,
                  color: Colors.white,
                  size: 42,
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
                child: const Icon(
                  CupertinoIcons.heart_fill,
                  color: Colors.redAccent,
                  size: 96,
                ),
              ),
            ),
          ),

        // 5. Right Action Column (Like, Comment, Share, Save, Options, Audio Disc)
        Positioned(
          right: 12,
          bottom: MediaQuery.of(context).padding.bottom + 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: chill.userHasLiked
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: chill.userHasLiked ? Colors.redAccent : Colors.white,
                label: _formatCount(chill.likeCount),
                onPressed: _toggleLike,
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: CupertinoIcons.chat_bubble_fill,
                color: Colors.white,
                label: _formatCount(chill.commentCount),
                onPressed: () => _openComments(context),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: CupertinoIcons.arrowshape_turn_up_right_fill,
                color: Colors.white,
                label: _formatCount(chill.shareCount),
                onPressed: () => _handleShare(context),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: chill.userHasSaved
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                color: chill.userHasSaved ? Colors.amber : Colors.white,
                label: chill.userHasSaved ? 'Saved' : 'Save',
                onPressed: _toggleSave,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: CupertinoIcons.ellipsis,
                color: Colors.white,
                label: '',
                onPressed: () => _openOptions(context, isAuthor: isAuthor),
              ),
              const SizedBox(height: 16),
              // Rotating Audio Disc
              RotationTransition(
                turns: _discAnimController,
                child: Container(
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade900,
                    border: Border.all(
                      color: Colors.white38,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(
                            CupertinoIcons.music_note,
                            color: Colors.white,
                            size: 14,
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
          left: 14,
          right: 76,
          bottom: MediaQuery.of(context).padding.bottom + 20,
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
                      radius: 18,
                      backgroundColor: Colors.white24,
                      backgroundImage: avatarUrl != null
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              chill.author.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chill.author.fullName ?? chill.author.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '@${chill.author.username}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // View count pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.eye_fill,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(chill.viewCount),
                            style: const TextStyle(
                              color: Colors.white,
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
              const SizedBox(height: 10),

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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                      if (chill.caption.length > 70)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _isExpandCaption ? 'Less' : 'More',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Clickable #tags
              if (chill.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Audio Track Info Row
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.music_note_2,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      chill.audioTitle ??
                          chill.audio?.title ??
                          'Original Audio - ${chill.author.fullName ?? chill.author.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (chill.isRemix) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Remix',
                        style: TextStyle(
                          color: Colors.white,
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
              colors: const VideoProgressColors(
                playedColor: Colors.redAccent,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _togglePlayPause() async {
    HapticFeedback.selectionClick();
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
    await Clipboard.setData(
      ClipboardData(
        text: 'https://lotusconnect.app/chills/${widget.chill.id}',
      ),
    );
    await ref.read(chillNotifierProvider.notifier).shareChill(widget.chill.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chill link copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openOptions(BuildContext context, {required bool isAuthor}) {
    HapticFeedback.selectionClick();
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
                deleted
                    ? 'Chill deleted successfully.'
                    : 'Failed to delete Chill.',
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
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
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
