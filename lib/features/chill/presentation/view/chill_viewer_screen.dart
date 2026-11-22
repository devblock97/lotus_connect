import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';
import 'package:lotus_connect/features/chill/chill.dart';
import 'package:lotus_connect/features/chill/presentation/widgets/video_item.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/features/settings/application/settings_providers.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:lotus_connect/main_shell_screen.dart';
import 'package:video_player/video_player.dart';

class ChillViewerScreen extends ConsumerStatefulWidget {
  const ChillViewerScreen({
    this.initialChills,
    this.initialIndex = 0,
    this.initialPosition = Duration.zero,
    this.isModal = false,
    super.key,
  });

  final List<ChillItem>? initialChills;
  final int initialIndex;
  final Duration initialPosition;
  final bool isModal;

  static Future<void> open(
    BuildContext context, {
    List<ChillItem>? initialChills,
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, __, ___) => ChillViewerScreen(
          initialChills: initialChills,
          initialIndex: initialIndex,
          initialPosition: initialPosition,
          isModal: true,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  ConsumerState<ChillViewerScreen> createState() => _ChillViewerScreenState();
}

class _ChillVideoEntry {
  _ChillVideoEntry({required this.controller});

  final VideoPlayerController controller;
  bool isInitialized = false;
  bool hasError = false;
  bool isDisposed = false;
}

class _ChillViewerScreenState extends ConsumerState<ChillViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  // Sliding-window controller pool (max 3: current - 1, current, current + 1)
  final Map<String, _ChillVideoEntry> _videoPool = {};
  final Set<String> _pendingInits = {};
  final Set<String> _queuedPreCacheUrls = {};
  VideoPreCacheManager? _preCacheManager;
  bool _appliedInitialPosition = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(chillNotifierProvider.notifier);
      if (widget.initialChills != null && widget.initialChills!.isNotEmpty) {
        notifier.setInitialChills(widget.initialChills!);
        _syncChillWindow(_currentIndex, widget.initialChills!);
      } else {
        notifier.getChill();
      }
    });
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
    _pendingInits.clear();

    for (final entry in _videoPool.values) {
      _disposeEntry(entry);
    }
    _videoPool.clear();

    _pageController.dispose();
    super.dispose();
  }

  void _disposeEntry(_ChillVideoEntry entry) {
    if (entry.isDisposed) return;
    entry.isDisposed = true;
    unawaited(entry.controller.dispose().catchError((Object _) {}));
  }

  Set<String> _windowIds(int index, List<ChillItem> chills) {
    final keep = <String>{};
    for (final i in [index, index + 1, index - 1]) {
      if (i >= 0 && i < chills.length && chills[i].videoUrl.isNotEmpty) {
        keep.add(chills[i].id);
      }
    }
    return keep;
  }

  bool _isCurrentlyScreenVisible() {
    return widget.isModal || ref.read(shellIndexProvider) == 1;
  }

  void _precacheThumbnails(int index, List<ChillItem> chills) {
    final serverHost = ref.read(settingsNotifierProvider).settings.serverHost;
    for (final i in [index, index + 1, index - 1]) {
      if (i < 0 || i >= chills.length) continue;
      final thumb = chills[i].thumbnailUrl;
      if (thumb == null || thumb.isEmpty) continue;
      final normalized = normalizeMediaUrl(thumb, serverHost: serverHost);
      if (normalized.startsWith('http')) {
        unawaited(
          precacheImage(
            CachedNetworkImageProvider(normalized),
            context,
            onError: (_, __) {},
          ),
        );
      }
    }
  }

  void _syncChillWindow(int index, List<ChillItem> chills) {
    if (chills.isEmpty || index < 0 || index >= chills.length) return;
    if (!_isCurrentlyScreenVisible()) return;

    final keepIds = _windowIds(index, chills);

    // 1. Evict controllers outside [index - 1, index, index + 1]
    final toEvict =
        _videoPool.keys.where((id) => !keepIds.contains(id)).toList();
    for (final id in toEvict) {
      final entry = _videoPool.remove(id);
      if (entry != null) _disposeEntry(entry);
    }
    _pendingInits.removeWhere((id) => !keepIds.contains(id));

    // 2. Warm poster thumbnails around active index
    _precacheThumbnails(index, chills);

    // 3. Prioritize active video first; pre-warm neighbors once active is ready
    final activeChill = chills[index];
    if (activeChill.videoUrl.isEmpty) {
      _warmNeighborsAndBytes(index, chills);
      return;
    }

    final existing = _videoPool[activeChill.id];
    if (existing != null && existing.isInitialized && !existing.hasError) {
      _warmNeighborsAndBytes(index, chills);
    } else {
      unawaited(
        _ensureChillEntry(
          activeChill,
          isInitialItem: index == widget.initialIndex,
          onFinished: () {
            if (mounted && _currentIndex == index) {
              final latestChills = ref.read(chillNotifierProvider).chills;
              _warmNeighborsAndBytes(index, latestChills);
            }
          },
        ),
      );
    }
  }

  void _warmNeighborsAndBytes(int index, List<ChillItem> chills) {
    if (chills.isEmpty) return;
    final preCache = ref.read(videoPreCacheManagerProvider);
    _preCacheManager = preCache;

    // Collect URLs in [index - 1 .. index + 2] and cancel stale downloads
    final windowUrls = <String>{};
    for (final delta in [0, 1, -1, 2]) {
      final i = index + delta;
      if (i >= 0 && i < chills.length && chills[i].videoUrl.isNotEmpty) {
        windowUrls.add(chills[i].videoUrl);
      }
    }

    final stale =
        _queuedPreCacheUrls.where((url) => !windowUrls.contains(url)).toList();
    for (final url in stale) {
      preCache.cancelPreCache(url);
      _queuedPreCacheUrls.remove(url);
    }

    // Immediate neighbors (+1 first, then -1): pre-cache bytes then warm
    // controller decoder paused at frame 0.
    for (final i in [index + 1, index - 1]) {
      if (i < 0 || i >= chills.length) continue;
      final chill = chills[i];
      if (chill.videoUrl.isEmpty) continue;

      _queuedPreCacheUrls.add(chill.videoUrl);
      unawaited(
        preCache
            .preCacheUrl(
          chill.videoUrl,
          highPriority: i == index + 1,
        )
            .whenComplete(() {
          if (!mounted || !_isCurrentlyScreenVisible()) return;
          final latest = ref.read(chillNotifierProvider).chills;
          if (_windowIds(_currentIndex, latest).contains(chill.id)) {
            unawaited(_ensureChillEntry(chill, isInitialItem: false));
          }
        }),
      );
    }

    // Disk-only byte pre-cache for N+2 (no decoder allocated yet)
    final lookAheadIndex = index + 2;
    if (lookAheadIndex >= 0 && lookAheadIndex < chills.length) {
      final chill = chills[lookAheadIndex];
      if (chill.videoUrl.isNotEmpty) {
        _queuedPreCacheUrls.add(chill.videoUrl);
        unawaited(preCache.preCacheUrl(chill.videoUrl));
      }
    }
  }

  Future<void> _ensureChillEntry(
    ChillItem chill, {
    required bool isInitialItem,
    VoidCallback? onFinished,
  }) async {
    if (chill.videoUrl.isEmpty) {
      onFinished?.call();
      return;
    }

    final existing = _videoPool[chill.id];
    if (existing != null) {
      onFinished?.call();
      return;
    }
    if (_pendingInits.contains(chill.id)) return;

    _pendingInits.add(chill.id);
    final settings = ref.read(settingsNotifierProvider).settings;
    final preCache = ref.read(videoPreCacheManagerProvider);
    _preCacheManager = preCache;

    final normalizedUrl = normalizeMediaUrl(
      chill.videoUrl,
      serverHost: settings.serverHost,
    );
    final playableUrl = await preCache.getPlayableUrlAsync(normalizedUrl);
    _pendingInits.remove(chill.id);

    if (!mounted) return;
    final latestChills = ref.read(chillNotifierProvider).chills;
    if (!_windowIds(_currentIndex, latestChills).contains(chill.id)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(playableUrl));
    final entry = _ChillVideoEntry(controller: controller);
    _videoPool[chill.id] = entry;

    try {
      await controller.initialize();
      if (entry.isDisposed || !mounted) return;

      final isMuted = ref.read(chillNotifierProvider).isMuted;
      await controller.setLooping(true);
      await controller.setVolume(isMuted ? 0.0 : 1.0);

      if (isInitialItem &&
          !_appliedInitialPosition &&
          widget.initialPosition > Duration.zero) {
        _appliedInitialPosition = true;
        await controller.seekTo(widget.initialPosition);
      }

      if (entry.isDisposed || !mounted) return;
      entry.isInitialized = true;
      setState(() {});
      onFinished?.call();
    } on Object catch (_) {
      if (entry.isDisposed || !mounted) return;

      final activeId = _currentIndex >= 0 && _currentIndex < latestChills.length
          ? latestChills[_currentIndex].id
          : null;
      if (chill.id != activeId) {
        _videoPool.remove(chill.id);
        _disposeEntry(entry);
      } else {
        entry.hasError = true;
        setState(() {});
      }
      onFinished?.call();
    }
  }

  void _onPageChanged(int index, List<ChillItem> chills) {
    setState(() {
      _currentIndex = index;
    });
    _syncChillWindow(index, chills);

    // Trigger infinite scroll pagination when within 3 items of the end
    if (index >= chills.length - 3) {
      ref.read(chillNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chillState = ref.watch(chillNotifierProvider);
    final shellIndex = ref.watch(shellIndexProvider);

    // If embedded inside MainShellScreen (tab index 1),
    // pause playback when another tab is selected
    final isScreenVisible = widget.isModal || shellIndex == 1;

    // Sync sliding window once chills load
    ref
      ..listen<List<ChillItem>>(
        chillNotifierProvider.select((s) => s.chills),
        (previous, next) {
          if ((previous == null || previous.isEmpty) && next.isNotEmpty) {
            _syncChillWindow(_currentIndex, next);
          }
        },
      )
      // Keep global mute synced across all pooled controllers (active + warm)
      ..listen<bool>(
        chillNotifierProvider.select((s) => s.isMuted),
        (previous, next) {
          for (final entry in _videoPool.values) {
            if (entry.isInitialized && !entry.isDisposed) {
              unawaited(
                entry.controller
                    .setVolume(next ? 0.0 : 1.0)
                    .catchError((Object _) {}),
              );
            }
          }
        },
      )
      // Trigger window warming when switching back to the Chills tab
      ..listen<int>(shellIndexProvider, (previous, next) {
        if (!widget.isModal && next == 1 && previous != 1) {
          final chills = ref.read(chillNotifierProvider).chills;
          _syncChillWindow(_currentIndex, chills);
        }
      });

    return Scaffold(
      backgroundColor: AppColor.mediaBackdrop.of(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(context, chillState, isScreenVisible: isScreenVisible),
          _buildTopBar(context, chillState),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChillState chillState, {
    required bool isScreenVisible,
  }) {
    final loc = AppLocalizations.of(context)!;

    if (chillState.status == ChillStatus.loading && chillState.chills.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColor.onMedia.of(context),
          strokeWidth: AppSize.loaderStrokeWidth,
        ),
      );
    }

    if (chillState.status == ChillStatus.failure && chillState.chills.isEmpty) {
      return Center(
        child: Padding(
          padding: AppPadding.hXxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                color: AppColor.onMedia60.of(context),
                size: AppSize.iconXxl,
              ),
              AppGap.vMd,
              Text(
                chillState.message ?? loc.unableToLoadChills,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.onMedia70.of(context),
                  fontSize: 14,
                ),
              ),
              AppGap.vLg,
              FilledButton.icon(
                onPressed: () {
                  ref.read(chillNotifierProvider.notifier).getChill(
                        tag: chillState.activeTag,
                      );
                },
                icon: const Icon(Icons.refresh_rounded, size: AppSize.iconSm),
                label: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (chillState.chills.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.film,
              color: AppColor.onMedia54.of(context),
              size: AppSize.iconXxl,
            ),
            AppGap.vMd,
            Text(
              chillState.activeTag != null
                  ? loc.noChillsFoundForTag(chillState.activeTag!)
                  : loc.noChillsAvailableYet,
              style: TextStyle(
                color: AppColor.onMedia70.of(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (chillState.activeTag != null) ...[
              AppGap.vMd,
              TextButton(
                onPressed: () {
                  ref.read(chillNotifierProvider.notifier).setTagFilter(null);
                },
                child: Text(loc.clearTagFilter),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chillNotifierProvider.notifier).refresh(),
      color: AppColor.dangerAccent.of(context),
      backgroundColor: AppColor.mediaDarkTrack.of(context),
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: chillState.chills.length,
        onPageChanged: (index) => _onPageChanged(index, chillState.chills),
        itemBuilder: (context, index) {
          final chill = chillState.chills[index];
          final isInitial = index == widget.initialIndex;
          final entry = _videoPool[chill.id];
          return VideoItem(
            key: ValueKey('chill_item_${chill.id}'),
            chill: chill,
            isActive: isScreenVisible && index == _currentIndex,
            initialPosition: isInitial ? widget.initialPosition : Duration.zero,
            usesExternalController: true,
            externalController: entry?.controller,
            isExternalInitialized: entry?.isInitialized ?? false,
            hasExternalError: entry?.hasError ?? false,
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ChillState chillState) {
    final topPadding = MediaQuery.of(context).padding.top;
    final loc = AppLocalizations.of(context)!;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.mediaScrim87.of(context),
              AppColor.mediaScrim38.of(context),
              AppColor.transparent.of(context),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding + AppSize.sm,
            left: AppSize.md,
            right: AppSize.md,
            bottom: AppSize.lg,
          ),
          child: Row(
            children: [
              if (widget.isModal) ...[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColor.onMedia.of(context),
                    size: AppSize.iconSm,
                  ),
                ),
                AppGap.hXs,
              ] else
                AppGap.hXs,
              Text(
                loc.chillsTitle,
                style: TextStyle(
                  color: AppColor.onMedia.of(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 0.3,
                ),
              ),
              if (chillState.activeTag != null) ...[
                AppGap.hSm,
                GestureDetector(
                  onTap: () {
                    ref.read(chillNotifierProvider.notifier).setTagFilter(null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.md,
                      vertical: AppSize.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.dangerAccent
                          .of(context)
                          .withValues(alpha: 0.85),
                      borderRadius: AppRadius.lg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${chillState.activeTag}',
                          style: TextStyle(
                            color: AppColor.onMedia.of(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppGap.hXs,
                        Icon(
                          Icons.close_rounded,
                          color: AppColor.onMedia.of(context),
                          size: AppSize.iconXs,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Mute / Unmute button
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(chillNotifierProvider.notifier).toggleMute();
                },
                child: Container(
                  padding: AppPadding.sm,
                  decoration: BoxDecoration(
                    color: AppColor.mediaBackdrop
                        .of(context)
                        .withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    chillState.isMuted
                        ? CupertinoIcons.volume_off
                        : CupertinoIcons.volume_up,
                    color: AppColor.onMedia.of(context),
                    size: AppSize.iconSm,
                  ),
                ),
              ),
              AppGap.hSm,
              // Refresh button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(chillNotifierProvider.notifier).refresh();
                },
                child: Container(
                  padding: AppPadding.sm,
                  decoration: BoxDecoration(
                    color: AppColor.mediaBackdrop
                        .of(context)
                        .withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.refresh,
                    color: AppColor.onMedia.of(context),
                    size: AppSize.iconSm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
