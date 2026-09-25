import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:video_player/video_player.dart';

/// A sleek Instagram-style feed video player supporting:
/// - Thumbnail display while loading or before playing
/// - Tap to play/pause with animated central indicator
/// - Mute/unmute speaker toggle with transient volume indicator
/// - Continuous video looping
/// - Thin progress bar tracking playback
/// - Graceful fallback to thumbnail if video network fails
class FeedVideoPlayer extends StatefulWidget {
  const FeedVideoPlayer({
    required this.media,
    super.key,
    this.autoPlay = false,
    this.aspectRatio,
    this.onDoubleTap,
    this.onTap,
  });

  final PostMediaItem media;
  final bool autoPlay;
  final double? aspectRatio;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _hasError = false;
  bool _showMuteFeedback = false;
  Timer? _muteFeedbackTimer;

  // Animation controller for play/pause pulse
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

    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    final videoUri = Uri.tryParse(widget.media.url);
    if (videoUri == null || !videoUri.hasScheme) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(videoUri);
      _controller = controller;

      await controller.initialize();
      if (!mounted) return;

      await controller.setLooping(true);
      await controller.setVolume(_isMuted ? 0 : 1);

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      if (widget.autoPlay) {
        await controller.play();
        if (mounted) setState(() => _isPlaying = true);
      }

      controller.addListener(_videoListener);
    } on Object catch (e) {
      AppLogger.error('FeedVideoPlayer failed to initialize: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
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

  @override
  void didUpdateWidget(FeedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.url != widget.media.url) {
      _controller?.removeListener(_videoListener);
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _hasError = false;
      _isPlaying = false;
      _initVideoPlayer();
    }
  }

  @override
  void dispose() {
    _muteFeedbackTimer?.cancel();
    _indicatorAnimController.dispose();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    HapticFeedback.selectionClick();
    if (_controller == null || !_isInitialized) return;

    if (_isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      _indicatorAnimController.forward(from: 0);
    }

    widget.onTap?.call();
  }

  void _toggleMute() {
    HapticFeedback.selectionClick();
    setState(() {
      _isMuted = !_isMuted;
      _showMuteFeedback = true;
    });

    _controller?.setVolume(_isMuted ? 0 : 1);

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
    final effectiveAspectRatio = widget.aspectRatio ??
        (_isInitialized && _controller != null
            ? _controller!.value.aspectRatio
            : widget.media.aspectRatio);

    return AspectRatio(
      aspectRatio: effectiveAspectRatio,
      child: GestureDetector(
        onDoubleTap: widget.onDoubleTap,
        onTap: _togglePlayPause,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Thumbnail Layer (always rendered as background/placeholder)
              _buildThumbnail(theme),

              // 2. Video Player Layer (fades in once initialized)
              if (_isInitialized && _controller != null && !_hasError)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),

              // 3. Center Play Icon Overlay (when paused or error)
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

              // 4. Center Play Pulse Indicator (flashes when unpaused)
              AnimatedBuilder(
                animation: _indicatorAnimController,
                builder: (context, child) {
                  if (_indicatorAnimController.isDismissed) {
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

              // 5. Video Progress Bar (at the bottom)
              if (_isInitialized && _controller != null && _isPlaying)
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

              // 6. Top Right Video Badge (Instagram Reel / Video Icon)
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

              // 7. Bottom Right Mute/Unmute Button
              if (_isInitialized && !_hasError)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleMute,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isMuted
                            ? CupertinoIcons.volume_off
                            : CupertinoIcons.volume_up,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

              // 8. Transient Mute Feedback Center Banner
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
                          _isMuted
                              ? CupertinoIcons.volume_off
                              : CupertinoIcons.volume_up,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isMuted ? 'Muted' : 'Unmuted',
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
    );
  }

  Widget _buildThumbnail(ThemeData theme) {
    // 1. Try thumbnailUrl first, then fallback to url if it's an image
    final thumb = widget.media.thumbnailUrl;
    final primaryUrl = widget.media.url;

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
