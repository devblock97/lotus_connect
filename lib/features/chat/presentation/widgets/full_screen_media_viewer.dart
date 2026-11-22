import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaViewer extends StatefulWidget {
  const FullScreenMediaViewer({
    required this.medias,
    this.initialIndex = 0,
    this.preCacheManager,
    super.key,
  });

  final List<MediaEntity> medias;
  final int initialIndex;
  final VideoPreCacheManager? preCacheManager;

  /// Helper to open the full screen viewer.
  static void show(
    BuildContext context, {
    required List<MediaEntity> medias,
    int initialIndex = 0,
    VideoPreCacheManager? preCacheManager,
  }) {
    if (medias.isEmpty) return;

    final safeInitialIndex = initialIndex.clamp(0, medias.length - 1);

    Navigator.push<void>(
      context,
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColor.transparent.of(context),
        pageBuilder: (_, __, ___) => FullScreenMediaViewer(
          medias: medias,
          initialIndex: safeInitialIndex,
          preCacheManager: preCacheManager,
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

class _VideoPoolEntry {
  _VideoPoolEntry({required this.controller});

  final VideoPlayerController controller;
  bool isInitialized = false;
  bool hasError = false;
  bool isDisposed = false;
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

  // Sliding-window video controller cache (max 3: current - 1, current, +1)
  final Map<int, _VideoPoolEntry> _videoPool = {};
  final Set<int> _pendingVideoInits = {};
  final Set<String> _queuedPreCacheUrls = {};
  VideoPreCacheManager? _preCacheManager;
  bool _didSyncInitialWindow = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didSyncInitialWindow) {
      _didSyncInitialWindow = true;
      _preCacheManager = _resolvePreCacheManager();
      _syncMediaWindow(_currentIndex);
    }
  }

  @override
  void dispose() {
    final preCache = _preCacheManager;
    if (preCache != null) {
      for (final url in _queuedPreCacheUrls) {
        preCache.cancelPreCache(url);
      }
    }
    _queuedPreCacheUrls.clear();
    _pendingVideoInits.clear();

    for (final entry in _videoPool.values) {
      _disposeEntry(entry);
    }
    _videoPool.clear();

    _pageController.dispose();
    _resetDragController.dispose();
    super.dispose();
  }

  VideoPreCacheManager? _resolvePreCacheManager() {
    if (widget.preCacheManager != null) return widget.preCacheManager;
    try {
      return ProviderScope.containerOf(context, listen: false)
          .read(videoPreCacheManagerProvider);
    } on Object {
      return null;
    }
  }

  bool _isHlsMedia(MediaEntity media) {
    final mime = media.mimeType?.toLowerCase() ?? '';
    if (mime == 'application/x-mpegurl' ||
        mime == 'application/vnd.apple.mpegurl') {
      return true;
    }
    final path = (Uri.tryParse(media.url)?.path ?? media.url).toLowerCase();
    return path.endsWith('.m3u8');
  }

  Set<int> _controllerWindow(int activeIndex) {
    final keep = <int>{};
    for (final idx in [activeIndex, activeIndex + 1, activeIndex - 1]) {
      if (idx >= 0 &&
          idx < widget.medias.length &&
          isVideoMedia(widget.medias[idx])) {
        keep.add(idx);
      }
    }
    return keep;
  }

  void _disposeEntry(_VideoPoolEntry entry) {
    if (entry.isDisposed) return;
    entry.isDisposed = true;
    unawaited(entry.controller.dispose().catchError((Object _) {}));
  }

  void _playEntry(_VideoPoolEntry entry) {
    if (entry.isDisposed || !entry.isInitialized) return;
    final value = entry.controller.value;
    if (value.position >= value.duration && value.duration > Duration.zero) {
      unawaited(
        entry.controller.seekTo(Duration.zero).then((_) {
          if (!entry.isDisposed) {
            return entry.controller.play();
          }
        }).catchError((Object _) {}),
      );
    } else {
      unawaited(entry.controller.play().catchError((Object _) {}));
    }
  }

  void _precacheNearbyImages(int activeIndex) {
    for (final idx in [activeIndex, activeIndex + 1, activeIndex - 1]) {
      if (idx < 0 || idx >= widget.medias.length) continue;
      final media = widget.medias[idx];
      final imageUrl = isVideoMedia(media) ? media.thumbnailUrl : media.url;
      if (imageUrl != null && imageUrl.isNotEmpty && isNetworkUrl(imageUrl)) {
        unawaited(
          precacheImage(
            CachedNetworkImageProvider(imageUrl),
            context,
            onError: (_, __) {},
          ),
        );
      }
    }
  }

  void _syncMediaWindow(int activeIndex) {
    if (widget.medias.isEmpty) return;

    final keep = _controllerWindow(activeIndex);

    // 1. Evict controllers outside [active - 1, active, active + 1]
    final toEvict =
        _videoPool.keys.where((idx) => !keep.contains(idx)).toList();
    for (final idx in toEvict) {
      final entry = _videoPool.remove(idx);
      if (entry != null) _disposeEntry(entry);
    }
    _pendingVideoInits.removeWhere((idx) => !keep.contains(idx));

    // 2. Pause non-active pooled videos (unconditionally to avoid fast-swipe
    //    race before platform isPlayingStateUpdate arrives)
    for (final mapEntry in _videoPool.entries) {
      if (mapEntry.key != activeIndex &&
          mapEntry.value.isInitialized &&
          !mapEntry.value.isDisposed) {
        unawaited(mapEntry.value.controller.pause().catchError((Object _) {}));
      }
    }

    // 3. Warm image & video poster thumbnails around activeIndex
    _precacheNearbyImages(activeIndex);

    // 4. Prioritize active video first so pre-warming doesn't starve it
    final activeMedia = widget.medias[activeIndex];
    if (isVideoMedia(activeMedia)) {
      final existing = _videoPool[activeIndex];
      if (existing != null && existing.isInitialized && !existing.hasError) {
        _playEntry(existing);
        _warmNeighborsAndBytes(activeIndex);
      } else {
        unawaited(
          _ensureVideoEntry(
            activeIndex,
            autoPlay: true,
            onFinished: () {
              if (mounted && _currentIndex == activeIndex) {
                _warmNeighborsAndBytes(activeIndex);
              }
            },
          ),
        );
      }
    } else {
      _warmNeighborsAndBytes(activeIndex);
    }
  }

  void _warmNeighborsAndBytes(int activeIndex) {
    final preCache = _preCacheManager;

    // Collect URLs in the byte pre-cache window [active - 2 .. active + 2]
    final byteWindowUrls = <String>{};
    for (final delta in [0, 1, -1, 2, -2]) {
      final idx = activeIndex + delta;
      if (idx < 0 || idx >= widget.medias.length) continue;
      final media = widget.medias[idx];
      if (isVideoMedia(media) && isNetworkUrl(media.url)) {
        byteWindowUrls.add(media.url);
      }
    }

    // Cancel stale pre-cache downloads we queued outside the active window
    if (preCache != null) {
      final stale = _queuedPreCacheUrls
          .where((url) => !byteWindowUrls.contains(url))
          .toList();
      for (final url in stale) {
        preCache.cancelPreCache(url);
        _queuedPreCacheUrls.remove(url);
      }
    }

    // Pre-warm immediate neighbors (+1 first, then -1) paused at frame 0
    for (final idx in [activeIndex + 1, activeIndex - 1]) {
      if (idx < 0 || idx >= widget.medias.length) continue;
      final media = widget.medias[idx];
      if (!isVideoMedia(media)) continue;

      if (preCache != null && isNetworkUrl(media.url)) {
        _queuedPreCacheUrls.add(media.url);
        unawaited(
          preCache
              .preCacheUrl(
            media.url,
            isHls: _isHlsMedia(media),
            highPriority: idx == activeIndex + 1,
          )
              .whenComplete(() {
            if (mounted && _controllerWindow(_currentIndex).contains(idx)) {
              unawaited(_ensureVideoEntry(idx, autoPlay: false));
            }
          }),
        );
      } else {
        unawaited(_ensureVideoEntry(idx, autoPlay: false));
      }
    }

    // Disk-only byte pre-cache further ahead (+2, -2) without decoder usage
    if (preCache != null) {
      for (final idx in [activeIndex + 2, activeIndex - 2]) {
        if (idx < 0 || idx >= widget.medias.length) continue;
        final media = widget.medias[idx];
        if (!isVideoMedia(media) || !isNetworkUrl(media.url)) continue;

        _queuedPreCacheUrls.add(media.url);
        unawaited(
          preCache.preCacheUrl(
            media.url,
            isHls: _isHlsMedia(media),
          ),
        );
      }
    }
  }

  Future<void> _ensureVideoEntry(
    int index, {
    required bool autoPlay,
    VoidCallback? onFinished,
  }) async {
    if (index < 0 || index >= widget.medias.length) {
      onFinished?.call();
      return;
    }

    final existing = _videoPool[index];
    if (existing != null) {
      if (autoPlay && existing.isInitialized && !existing.hasError) {
        _playEntry(existing);
      }
      onFinished?.call();
      return;
    }

    if (_pendingVideoInits.contains(index)) {
      return;
    }

    _pendingVideoInits.add(index);
    final media = widget.medias[index];

    final VideoPlayerController controller;
    if (isNetworkUrl(media.url)) {
      final preCache = _preCacheManager;
      if (preCache != null) {
        final playableUrl = await preCache.getPlayableUrlAsync(media.url);
        if (!mounted || !_controllerWindow(_currentIndex).contains(index)) {
          _pendingVideoInits.remove(index);
          return;
        }
        controller = VideoPlayerController.networkUrl(Uri.parse(playableUrl));
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(media.url));
      }
    } else {
      controller = VideoPlayerController.file(resolveLocalFile(media.url));
    }

    _pendingVideoInits.remove(index);

    if (!mounted || !_controllerWindow(_currentIndex).contains(index)) {
      unawaited(controller.dispose().catchError((Object _) {}));
      return;
    }

    final entry = _VideoPoolEntry(controller: controller);
    _videoPool[index] = entry;

    try {
      await controller.initialize();
      if (entry.isDisposed || !mounted) return;

      entry.isInitialized = true;
      if (index == _currentIndex) {
        _playEntry(entry);
      }
      setState(() {});
      onFinished?.call();
    } on Object catch (_) {
      if (entry.isDisposed || !mounted) return;

      if (index != _currentIndex) {
        // Drop failed background pre-warm so swiping onto it retries cleanly
        _videoPool.remove(index);
        _disposeEntry(entry);
      } else {
        entry.hasError = true;
        setState(() {});
      }
      onFinished?.call();
    }
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
      backgroundColor: AppColor.transparent.of(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: AppColor.mediaBackdrop
                  .of(context)
                  .withValues(alpha: backdropOpacity),
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
                    _syncMediaWindow(index);
                  },
                  itemBuilder: (context, index) {
                    final media = widget.medias[index];
                    final isVideo = isVideoMedia(media);

                    if (isVideo) {
                      final entry = _videoPool[index];
                      return _VideoMediaItem(
                        key: ValueKey('video_${index}_${media.url}'),
                        media: media,
                        controller: entry?.controller,
                        isInitialized: entry?.isInitialized ?? false,
                        hasError: entry?.hasError ?? false,
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
    final loc = AppLocalizations.of(context);

    final onMedia = AppColor.onMedia.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSize.xs,
        bottom: AppSize.md,
        left: AppSize.md,
        right: AppSize.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.mediaScrim87.of(context),
            AppColor.mediaScrim45.of(context),
            AppColor.transparent.of(context),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: onMedia,
              size: AppSize.iconLg,
            ),
            splashRadius: AppSize.xxl,
            tooltip: loc?.close ?? 'Close',
          ),
          AppGap.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.medias.length > 1)
                  Text(
                    '${_currentIndex + 1} / ${widget.medias.length}',
                    style: TextStyle(
                      color: onMedia,
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
                      color: onMedia.withValues(alpha: 0.8),
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

  Widget _buildErrorWidget(BuildContext context, AppLocalizations? loc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: AppColor.onMedia54.of(context),
            size: AppSize.iconXxl,
          ),
          AppGap.vSm,
          Text(
            loc?.failedToLoadImage ?? 'Failed to load image',
            style: TextStyle(
              color: AppColor.onMedia54.of(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, AppLocalizations? loc) {
    if (!isNetworkUrl(widget.media.url)) {
      return Image.file(
        resolveLocalFile(widget.media.url),
        fit: BoxFit.contain,
        errorBuilder: (context, _, __) => _buildErrorWidget(context, loc),
      );
    }

    final thumbnailUrl = widget.media.thumbnailUrl;
    return CachedNetworkImage(
      imageUrl: widget.media.url,
      fit: BoxFit.contain,
      placeholder: (context, _) => Center(
        child: thumbnailUrl != null &&
                thumbnailUrl.isNotEmpty &&
                isNetworkUrl(thumbnailUrl)
            ? CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.contain,
              )
            : SizedBox(
                width: AppSize.loaderSizeLg,
                height: AppSize.loaderSizeLg,
                child: CircularProgressIndicator(
                  color: AppColor.onMedia70.of(context),
                  strokeWidth: AppSize.loaderStrokeWidth,
                ),
              ),
      ),
      errorWidget: (context, __, dynamic ___) =>
          _buildErrorWidget(context, loc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
            child: _buildImage(context, loc),
          ),
        ),
      ),
    );
  }
}

class _VideoMediaItem extends StatefulWidget {
  const _VideoMediaItem({
    required this.media,
    required this.controller,
    required this.isInitialized,
    required this.hasError,
    required this.onTap,
    super.key,
  });

  final MediaEntity media;
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool hasError;
  final VoidCallback onTap;

  @override
  State<_VideoMediaItem> createState() => _VideoMediaItemState();
}

class _VideoMediaItemState extends State<_VideoMediaItem> {
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant _VideoMediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController(oldWidget.controller);
      _attachController(widget.controller);
    }
  }

  @override
  void dispose() {
    _detachController(widget.controller);
    super.dispose();
  }

  void _attachController(VideoPlayerController? controller) {
    if (controller == null) return;
    _isMuted = controller.value.volume == 0.0;
    controller.addListener(_onControllerUpdated);
  }

  void _detachController(VideoPlayerController? controller) {
    controller?.removeListener(_onControllerUpdated);
  }

  void _onControllerUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayPause() {
    final controller = widget.controller;
    if (controller == null || !widget.isInitialized) return;
    HapticFeedback.lightImpact();
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero) {
        controller.seekTo(Duration.zero);
      }
      controller.play();
    }
  }

  void _toggleMute() {
    final controller = widget.controller;
    if (controller == null || !widget.isInitialized) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget? _buildPosterThumbnail() {
    final thumbUrl = widget.media.thumbnailUrl;
    if (thumbUrl == null || thumbUrl.isEmpty) return null;

    if (isNetworkUrl(thumbUrl)) {
      return CachedNetworkImage(
        imageUrl: thumbUrl,
        fit: BoxFit.contain,
        errorWidget: (_, __, dynamic ___) => const SizedBox.shrink(),
      );
    }

    return Image.file(
      resolveLocalFile(thumbUrl),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final onMedia = AppColor.onMedia.of(context);
    final onMedia70 = AppColor.onMedia70.of(context);
    final onMedia54 = AppColor.onMedia54.of(context);

    if (widget.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: onMedia54,
              size: AppSize.iconXxl,
            ),
            AppGap.vSm,
            Text(
              loc?.unableToPlayVideo ?? 'Unable to play video',
              style: TextStyle(color: onMedia54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final poster = _buildPosterThumbnail();
    final controller = widget.controller;
    final isReady = widget.isInitialized && controller != null;

    if (!isReady) {
      return Stack(
        alignment: Alignment.center,
        children: [
          if (poster != null) Positioned.fill(child: Center(child: poster)),
          Center(
            child: SizedBox(
              width: AppSize.loaderSizeLg,
              height: AppSize.loaderSizeLg,
              child: CircularProgressIndicator(
                color: onMedia70,
                strokeWidth: AppSize.loaderStrokeWidth,
              ),
            ),
          ),
        ],
      );
    }

    final duration = controller.value.duration;
    final position = controller.value.position;
    final isPlaying = controller.value.isPlaying;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (poster != null) Positioned.fill(child: Center(child: poster)),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: isPlaying ? 1 : 0, end: 1),
            duration: const Duration(milliseconds: 180),
            builder: (context, opacity, child) => Opacity(
              opacity: opacity,
              child: child,
            ),
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio > 0
                  ? controller.value.aspectRatio
                  : 16 / 9,
              child: VideoPlayer(controller),
            ),
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
                  color: AppColor.mediaBackdrop
                      .of(context)
                      .withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                padding: AppPadding.lg,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: onMedia,
                  size: AppSize.iconHero,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + AppSize.lg,
          left: AppSize.lg,
          right: AppSize.lg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.bubbleHorizontal,
              vertical: AppSize.sm,
            ),
            decoration: BoxDecoration(
              color: AppColor.mediaScrim54.of(context),
              borderRadius: AppRadius.xxl,
              border: AppBorder.all(AppColor.onMedia12.of(context)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: onMedia,
                  ),
                  splashRadius: AppSize.xl,
                  padding: AppPadding.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppSize.iconButtonSm,
                    minHeight: AppSize.iconButtonSm,
                  ),
                ),
                AppGap.hSm,
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: onMedia70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: onMedia,
                      activeTrackColor: onMedia,
                      inactiveTrackColor: AppColor.onMedia24.of(context),
                      trackHeight: AppSize.borderHeavy,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: AppSize.badgeHorizontal,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: AppSize.md,
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
                        controller.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: onMedia70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppGap.hSm,
                IconButton(
                  onPressed: _toggleMute,
                  tooltip: _isMuted
                      ? (loc?.unmute ?? 'Unmute')
                      : (loc?.mute ?? 'Mute'),
                  icon: Icon(
                    _isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: onMedia,
                  ),
                  splashRadius: AppSize.xl,
                  padding: AppPadding.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppSize.iconButtonSm,
                    minHeight: AppSize.iconButtonSm,
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
