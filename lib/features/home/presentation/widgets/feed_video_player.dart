import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';
import 'package:lotus_connect/features/home/application/feed_playback_coordinator.dart';
import 'package:lotus_connect/features/home/application/video_player_pool.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Sleek Instagram/Facebook-grade feed video player featuring:
/// - Single active player coordination with automated scroll-based auto-play
/// - Rapid fling debounce (250ms) preventing decoder thrashing
/// - Immediate auto-pause on scroll-out (<40% visibility)
/// - Hardware decoder pooling (max 2 active controllers in memory)
/// - Buttery smooth cross-fade from poster thumbnail to video
class FeedVideoPlayer extends ConsumerStatefulWidget {
  const FeedVideoPlayer({
    required this.media,
    super.key,
    this.postId,
    this.autoPlay = false,
    this.aspectRatio,
    this.onDoubleTap,
    this.onTap,
  });

  final PostMediaItem media;
  final String? postId;
  final bool autoPlay;
  final double? aspectRatio;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;

  @override
  ConsumerState<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends ConsumerState<FeedVideoPlayer>
    with SingleTickerProviderStateMixin {
  String get _effectivePostId => widget.postId ?? widget.media.url;

  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isVideoVisible = false;

  bool _showMuteFeedback = false;
  Timer? _muteFeedbackTimer;

  // Pulse animation for play/pause user actions
  late AnimationController _indicatorAnimController;
  late Animation<double> _indicatorScaleAnimation;
  late Animation<double> _indicatorOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _indicatorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _indicatorScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _indicatorAnimController,
        curve: Curves.easeOutBack,
      ),
    );
    _indicatorOpacityAnimation = Tween<double>(begin: 0.9, end: 0).animate(
      CurvedAnimation(
        parent: _indicatorAnimController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _muteFeedbackTimer?.cancel();
    _indicatorAnimController.dispose();
    _detachCurrentController();

    // Notify coordinator of disposal
    try {
      ref
          .read(feedPlaybackCoordinatorProvider.notifier)
          .reportDisposed(_effectivePostId);
    } on Object catch (_) {}

    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    var distanceToCenter = double.infinity;

    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      final widgetCenterY = position.dy + (renderBox.size.height / 2);
      final screenCenterY = screenHeight / 2;
      distanceToCenter = (widgetCenterY - screenCenterY).abs();
    }

    ref.read(feedPlaybackCoordinatorProvider.notifier).reportVisibility(
          postId: _effectivePostId,
          visibleFraction: info.visibleFraction,
          distanceToCenter: distanceToCenter,
        );
  }

  Future<void> _activatePlayback({required bool isGloballyMuted}) async {
    final pool = ref.read(videoPlayerPoolProvider);
    final preCache = ref.read(videoPreCacheManagerProvider);
    final settings = ref.read(settingsNotifierProvider).settings;
    final normalizedUrl = normalizeMediaUrl(
      widget.media.url,
      serverHost: settings.serverHost,
    );
    final playableUrl = preCache.getPlayableUrl(normalizedUrl);

    try {
      final controller = await pool.acquireController(
        postId: _effectivePostId,
        videoUrl: playableUrl,
        isMuted: isGloballyMuted,
      );

      if (!mounted) return;

      if (controller == null) {
        setState(() => _hasError = true);
        return;
      }

      _controller = controller;
      controller.addListener(_videoListener);

      await controller.play();
      if (!mounted) return;

      setState(() {
        _hasError = false;
        _isPlaying = true;
        _isVideoVisible = true;
      });
    } on Object catch (e) {
      AppLogger.error('FeedVideoPlayer activation failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isVideoVisible = false;
        });
      }
    }
  }

  void _deactivatePlayback() {
    _detachCurrentController();
    ref.read(videoPlayerPoolProvider).releaseController(_effectivePostId);

    if (mounted) {
      setState(() {
        _controller = null;
        _isPlaying = false;
        _isVideoVisible = false;
      });
    }
  }

  void _detachCurrentController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller = null;
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    final wasPlaying = _isPlaying;
    ref
        .read(feedPlaybackCoordinatorProvider.notifier)
        .togglePlayPause(_effectivePostId);

    if (!wasPlaying) {
      _indicatorAnimController.forward(from: 0);
    }
    widget.onTap?.call();
  }

  void _handleToggleMute() {
    HapticFeedback.selectionClick();
    ref.read(feedPlaybackCoordinatorProvider.notifier).toggleMute();

    setState(() {
      _showMuteFeedback = true;
    });

    _muteFeedbackTimer?.cancel();
    _muteFeedbackTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showMuteFeedback = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playbackState = ref.watch(feedPlaybackCoordinatorProvider);
    final isGloballyMuted = playbackState.isGloballyMuted;

    // React to coordinator active state changes
    ref.listen(
      feedPlaybackCoordinatorProvider.select(
        (s) => s.activePostId == _effectivePostId,
      ),
      (previous, active) {
        if (active) {
          _activatePlayback(isGloballyMuted: isGloballyMuted);
        } else {
          _deactivatePlayback();
        }
      },
    );

    final effectiveAspectRatio = widget.aspectRatio ??
        (_controller != null && _controller!.value.isInitialized
            ? _controller!.value.aspectRatio
            : widget.media.aspectRatio);

    return VisibilityDetector(
      key: ValueKey('feed_video_${_effectivePostId}_${widget.media.url}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AspectRatio(
        aspectRatio: effectiveAspectRatio,
        child: GestureDetector(
          onDoubleTap: widget.onDoubleTap,
          onTap: _handleTap,
          child: ColoredBox(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Static Poster Thumbnail (always mounted to prevent blank)
                _buildThumbnail(theme),

                // Video Player Layer with smooth cross-fade animation
                if (_controller != null &&
                    _controller!.value.isInitialized &&
                    !_hasError)
                  AnimatedOpacity(
                    opacity: _isVideoVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeIn,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),

                // Center Play Icon Overlay (when paused or error)
                if (!_isPlaying || _hasError)
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hasError
                            ? CupertinoIcons.videocam_fill
                            : CupertinoIcons.play_fill,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                // Center Play Pulse Indicator (flashes when unpaused)
                AnimatedBuilder(
                  animation: _indicatorAnimController,
                  builder: (context, child) {
                    if (_indicatorAnimController.isDismissed ||
                        _indicatorAnimController.isCompleted) {
                      return const SizedBox.shrink();
                    }
                    return Center(
                      child: Opacity(
                        opacity: _indicatorOpacityAnimation.value,
                        child: Transform.scale(
                          scale: _indicatorScaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.play_fill,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Video Progress Bar (at the bottom)
                if (_controller != null &&
                    _controller!.value.isInitialized &&
                    _isPlaying)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: false,
                      colors: VideoProgressColors(
                        playedColor: theme.colorScheme.primary,
                        bufferedColor: Colors.white.withValues(alpha: 0.3),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.videocam_fill,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),

                if (!_hasError)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _handleToggleMute,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isGloballyMuted
                              ? CupertinoIcons.volume_off
                              : CupertinoIcons.volume_up,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                if (_showMuteFeedback)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGloballyMuted
                                ? CupertinoIcons.volume_off
                                : CupertinoIcons.volume_up,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isGloballyMuted ? 'Muted' : 'Unmuted',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ThemeData theme) {
    final settings = ref.read(settingsNotifierProvider).settings;
    final thumb = widget.media.thumbnailUrl != null
        ? normalizeMediaUrl(
            widget.media.thumbnailUrl!,
            serverHost: settings.serverHost,
          )
        : null;
    final primaryUrl = normalizeMediaUrl(
      widget.media.url,
      serverHost: settings.serverHost,
    );

    final targetUrl = (thumb != null && thumb.isNotEmpty)
        ? thumb
        : (primaryUrl.endsWith('.jpg') ||
                primaryUrl.endsWith('.jpeg') ||
                primaryUrl.endsWith('.png') ||
                primaryUrl.endsWith('.webp'))
            ? primaryUrl
            : null;

    if (targetUrl != null && targetUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: targetUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildPlaceholder(theme),
        errorWidget: (_, __, dynamic ___) => _buildFallbackThumbnail(),
      );
    }

    if (targetUrl != null && targetUrl.startsWith('assets/')) {
      return Image.asset(
        targetUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, dynamic ___) => _buildFallbackThumbnail(),
      );
    }

    return _buildFallbackThumbnail();
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return ColoredBox(
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF1E1E22)
          : const Color(0xFFF0F0F0),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF263238), Color(0xFF102027)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.videocam_circle_fill,
              size: 52,
              color: Colors.white54,
            ),
            const SizedBox(height: 6),
            if (widget.media.duration != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '0:${widget.media.duration}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
