import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaViewer extends StatefulWidget {
  const FullScreenMediaViewer({
    required this.medias,
    this.initialIndex = 0,
    super.key,
  });

  final List<MediaEntity> medias;
  final int initialIndex;

  /// Helper to open the full screen viewer.
  static void show(
    BuildContext context, {
    List<MediaEntity>? medias,
    String? imageUrl,
    int initialIndex = 0,
  }) {
    final mediaList = medias ??
        (imageUrl != null ? [MediaEntity(url: imageUrl)] : <MediaEntity>[]);
    if (mediaList.isEmpty) return;

    final safeInitialIndex = initialIndex.clamp(0, mediaList.length - 1);

    Navigator.push<void>(
      context,
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => FullScreenMediaViewer(
          medias: mediaList,
          initialIndex: safeInitialIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;

  bool _isOverlaysVisible = true;
  bool _isZoomed = false;

  // Vertical drag-to-dismiss state
  double _dragOffset = 0;
  late final AnimationController _resetDragController;
  Animation<double>? _resetDragAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _resetDragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_resetDragAnimation != null) {
          setState(() {
            _dragOffset = _resetDragAnimation!.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _resetDragController.dispose();
    super.dispose();
  }

  void _toggleOverlays() {
    setState(() {
      _isOverlaysVisible = !_isOverlaysVisible;
    });
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    if (_isZoomed) return;
    _resetDragController.stop();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isZoomed) return;
    setState(() {
      _dragOffset += details.delta.dy;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_isZoomed) return;

    final velocity = details.primaryVelocity ?? 0;
    // Dismiss if dragged down/up past 110 pixels or flicked fast
    if (_dragOffset.abs() > 110 || velocity.abs() > 750) {
      Navigator.of(context).pop();
    } else {
      // Smoothly spring back to center
      _resetDragAnimation = Tween<double>(
        begin: _dragOffset,
        end: 0,
      ).animate(
        CurvedAnimation(
          parent: _resetDragController,
          curve: Curves.easeOutCubic,
        ),
      );
      _resetDragController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic backdrop opacity fading from 1.0 down to 0.0 as dragged
    final dragFraction = (_dragOffset.abs() / 320).clamp(0.0, 1.0);
    final backdropOpacity = 1.0 - dragFraction;
    final scale = (1.0 - (_dragOffset.abs() / 1400)).clamp(0.8, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: backdropOpacity),
            ),
          ),
          GestureDetector(
            onVerticalDragStart: _handleVerticalDragStart,
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            onVerticalDragEnd: _handleVerticalDragEnd,
            onTap: _toggleOverlays,
            behavior: HitTestBehavior.opaque,
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Transform.scale(
                scale: scale,
                child: PageView.builder(
                  controller: _pageController,
                  physics: _isZoomed
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  itemCount: widget.medias.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _isZoomed = false;
                    });
                  },
                  itemBuilder: (context, index) {
                    final media = widget.medias[index];
                    final isVideo =
                        media.mimeType?.toLowerCase().contains('video') ??
                            media.url.toLowerCase().endsWith('.mp4');

                    if (isVideo) {
                      return _VideoMediaItem(
                        media: media,
                        isActive: index == _currentIndex,
                        onTap: _toggleOverlays,
                      );
                    }

                    return _ImageMediaItem(
                      media: media,
                      onZoomChanged: (zoomed) {
                        if (_isZoomed != zoomed) {
                          setState(() {
                            _isZoomed = zoomed;
                          });
                        }
                      },
                      onTap: _toggleOverlays,
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isOverlaysVisible && _dragOffset == 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_isOverlaysVisible || _dragOffset != 0,
                child: _buildTopBar(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final media = widget.medias[_currentIndex];
    final title = media.fileName;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: 12,
        left: 12,
        right: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87,
            Colors.black45,
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 28,
            ),
            splashRadius: 24,
            tooltip: 'Close',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.medias.length > 1)
                  Text(
                    '${_currentIndex + 1} / ${widget.medias.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageMediaItem extends StatefulWidget {
  const _ImageMediaItem({
    required this.media,
    required this.onZoomChanged,
    required this.onTap,
  });

  final MediaEntity media;
  final ValueChanged<bool> onZoomChanged;
  final VoidCallback onTap;

  @override
  State<_ImageMediaItem> createState() => _ImageMediaItemState();
}

class _ImageMediaItemState extends State<_ImageMediaItem>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late final AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;

  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });

    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController
      ..removeListener(_onTransformationChanged)
      ..dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.05);
  }

  void _handleDoubleTap() {
    if (_zoomAnimationController.isAnimating) return;

    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final Matrix4 targetMatrix;

    if (currentScale > 1.05) {
      targetMatrix = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      targetMatrix = Matrix4.identity()
        ..setTranslationRaw(-position.dx * 1.5, -position.dy * 1.5, 0)
        ..scaleByDouble(2.5, 2.5, 1, 1);
    }

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _zoomAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1,
          maxScale: 4,
          clipBehavior: Clip.none,
          child: Hero(
            tag: widget.media.url,
            child: CachedNetworkImage(
              imageUrl: widget.media.url,
              fit: BoxFit.contain,
              placeholder: (context, _) => Center(
                child: widget.media.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.media.thumbnailUrl!,
                        fit: BoxFit.contain,
                      )
                    : const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2.5,
                        ),
                      ),
              ),
              errorWidget: (_, __, dynamic ___) => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoMediaItem extends StatefulWidget {
  const _VideoMediaItem({
    required this.media,
    required this.isActive,
    required this.onTap,
  });

  final MediaEntity media;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_VideoMediaItem> createState() => _VideoMediaItemState();
}

class _VideoMediaItemState extends State<_VideoMediaItem> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.media.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          if (widget.isActive) {
            _controller.play();
          }
        }
      }).catchError((Object _) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant _VideoMediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive && _isInitialized) {
        _controller.play();
      } else if (!widget.isActive && _isInitialized) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _toggleMute() {
    HapticFeedback.selectionClick();
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white54,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'Unable to play video',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            color: Colors.white70,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final duration = _controller.value.duration;
    final position = _controller.value.position;
    final isPlaying = _controller.value.isPlaying;

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: _togglePlayPause,
            behavior: HitTestBehavior.translucent,
            child: AnimatedOpacity(
              opacity: isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: Colors.white,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble(),
                      max: duration.inMilliseconds > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1.0,
                      onChanged: (value) {
                        _controller.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _toggleMute,
                  icon: Icon(
                    _isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                  ),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
