import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chill/chill.dart';
import 'package:lotus_connect/features/chill/presentation/widgets/video_item.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/main_shell_screen.dart';

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

class _ChillViewerScreenState extends ConsumerState<ChillViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

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
        _preCacheAround(_currentIndex, widget.initialChills!);
      } else {
        notifier.getChill();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _preCacheAround(int index, List<ChillItem> chills) {
    if (chills.isEmpty) return;
    final preCache = ref.read(videoPreCacheManagerProvider);
    final end = (index + 2).clamp(0, chills.length - 1);
    for (var i = index + 1; i <= end; i++) {
      final chill = chills[i];
      if (chill.videoUrl.isNotEmpty) {
        unawaited(
          preCache.preCacheMedia(
            PostMediaItem(
              url: chill.videoUrl,
              thumbnailUrl: chill.thumbnailUrl,
              mimeType: 'video/mp4',
            ),
          ),
        );
      }
    }
  }

  void _onPageChanged(int index, List<ChillItem> chills) {
    setState(() {
      _currentIndex = index;
    });
    _preCacheAround(index, chills);

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

    // Pre-cache initial items once loaded
    ref.listen<List<ChillItem>>(
      chillNotifierProvider.select((s) => s.chills),
      (previous, next) {
        if ((previous == null || previous.isEmpty) && next.isNotEmpty) {
          _preCacheAround(_currentIndex, next);
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(chillState, isScreenVisible: isScreenVisible),
          _buildTopBar(context, chillState),
        ],
      ),
    );
  }

  Widget _buildBody(
    ChillState chillState, {
    required bool isScreenVisible,
  }) {
    if (chillState.status == ChillStatus.loading && chillState.chills.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }

    if (chillState.status == ChillStatus.failure && chillState.chills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_circle,
                color: Colors.white60,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                chillState.message ?? 'Unable to load Chills',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.read(chillNotifierProvider.notifier).getChill(
                        tag: chillState.activeTag,
                      );
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
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
            const Icon(
              CupertinoIcons.film,
              color: Colors.white54,
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(
              chillState.activeTag != null
                  ? 'No Chills found for #${chillState.activeTag}'
                  : 'No Chills available yet',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (chillState.activeTag != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(chillNotifierProvider.notifier).setTagFilter(null);
                },
                child: const Text('Clear tag filter'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chillNotifierProvider.notifier).refresh(),
      color: Colors.redAccent,
      backgroundColor: Colors.grey.shade900,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: chillState.chills.length,
        onPageChanged: (index) => _onPageChanged(index, chillState.chills),
        itemBuilder: (context, index) {
          final chill = chillState.chills[index];
          final isInitial = index == widget.initialIndex;
          return VideoItem(
            key: ValueKey('chill_item_${chill.id}'),
            chill: chill,
            isActive: isScreenVisible && index == _currentIndex,
            initialPosition: isInitial ? widget.initialPosition : Duration.zero,
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ChillState chillState) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black87,
              Colors.black38,
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding + 8,
            left: 12,
            right: 12,
            bottom: 16,
          ),
          child: Row(
            children: [
              if (widget.isModal) ...[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 4),
              ] else
                const SizedBox(width: 4),
              const Text(
                'Chills',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 0.3,
                ),
              ),
              if (chillState.activeTag != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    ref.read(chillNotifierProvider.notifier).setTagFilter(null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${chillState.activeTag}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 14,
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    chillState.isMuted
                        ? CupertinoIcons.volume_off
                        : CupertinoIcons.volume_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(chillNotifierProvider.notifier).refresh();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.refresh,
                    color: Colors.white,
                    size: 20,
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
