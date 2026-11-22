import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/features/home/application/feed_playback_coordinator.dart';
import 'package:video_player/video_player.dart';

class PooledVideoPlayerEntry {
  PooledVideoPlayerEntry({
    required this.postId,
    required this.url,
    required this.controller,
    required this.lastAccessed,
  });

  final String postId;
  final String url;
  final VideoPlayerController controller;
  DateTime lastAccessed;
}

class _InitToken {
  bool cancelled = false;
}

class VideoPlayerPool {
  VideoPlayerPool({
    this.maxControllers = 2,
    VideoPlayerController Function(Uri uri)? controllerFactory,
  }) : _controllerFactory =
            controllerFactory ?? VideoPlayerController.networkUrl;

  final int maxControllers;
  final VideoPlayerController Function(Uri uri) _controllerFactory;

  final Map<String, PooledVideoPlayerEntry> _pool = {};
  final Map<String, Future<VideoPlayerController?>> _initializing = {};
  final Map<String, String> _initializingUrls = {};
  final Map<String, _InitToken> _initTokens = {};

  int get pooledCount => _pool.length;

  bool isWarmOrInitializing(String postId, String videoUrl) {
    final existing = _pool[postId];
    if (existing != null && existing.url == videoUrl) return true;
    return _initializingUrls[postId] == videoUrl;
  }

  VideoPlayerController? getController(String postId) {
    final entry = _pool[postId];
    if (entry != null) {
      entry.lastAccessed = DateTime.now();
      return entry.controller;
    }
    return null;
  }

  /// Pre-initializes a controller for an upcoming video post in the background
  /// (paused at frame 0) so scrolling onto it starts playback immediately.
  Future<void> preWarmController({
    required String postId,
    required String videoUrl,
    required bool isMuted,
  }) async {
    if (isWarmOrInitializing(postId, videoUrl)) return;
    await acquireController(
      postId: postId,
      videoUrl: videoUrl,
      isMuted: isMuted,
    );
  }

  Future<VideoPlayerController?> acquireController({
    required String postId,
    required String videoUrl,
    required bool isMuted,
  }) async {
    final uri = Uri.tryParse(videoUrl);
    if (uri == null || !uri.hasScheme) {
      AppLogger.error('VideoPlayerPool: Invalid video URL "$videoUrl"');
      return null;
    }

    // If already pooled for this post and URL matches, reuse
    final existing = _pool[postId];
    if (existing != null) {
      if (existing.url == videoUrl) {
        existing.lastAccessed = DateTime.now();
        await existing.controller.setVolume(isMuted ? 0 : 1);
        return existing.controller;
      } else {
        // Post media URL changed -> dispose old entry
        await disposeController(postId);
      }
    }

    // Deduplicate concurrent initialize calls (e.g. pre-warm + active scroll)
    final pending = _initializing[postId];
    if (pending != null && _initializingUrls[postId] == videoUrl) {
      final controller = await pending;
      if (controller != null && _pool[postId]?.controller == controller) {
        _pool[postId]!.lastAccessed = DateTime.now();
        await controller.setVolume(isMuted ? 0 : 1);
        return controller;
      }
      return null;
    }

    final token = _InitToken();
    _initTokens[postId]?.cancelled = true;
    _initTokens[postId] = token;
    _initializingUrls[postId] = videoUrl;

    final initFuture = _initializeAndPool(
      postId: postId,
      uri: uri,
      videoUrl: videoUrl,
      isMuted: isMuted,
      token: token,
    );
    _initializing[postId] = initFuture;

    try {
      return await initFuture;
    } finally {
      if (identical(_initializing[postId], initFuture)) {
        unawaited(_initializing.remove(postId));
        _initializingUrls.remove(postId);
      }
      if (identical(_initTokens[postId], token)) {
        _initTokens.remove(postId);
      }
    }
  }

  Future<VideoPlayerController?> _initializeAndPool({
    required String postId,
    required Uri uri,
    required String videoUrl,
    required bool isMuted,
    required _InitToken token,
  }) async {
    // Evict least-recently-used controller if at or above capacity
    while (_pool.length >= maxControllers) {
      final oldestEntryKey = _findOldestKey(excludeKey: postId);
      if (oldestEntryKey != null) {
        await disposeController(oldestEntryKey);
      } else {
        break;
      }
    }

    if (token.cancelled) return null;

    VideoPlayerController? controller;
    try {
      controller = _controllerFactory(uri);
      await controller.initialize();
      if (token.cancelled) {
        await controller.dispose();
        return null;
      }
      await controller.setLooping(true);
      await controller.setVolume(isMuted ? 0 : 1);

      if (token.cancelled) {
        await controller.dispose();
        return null;
      }

      // Re-check pool capacity in case another concurrent init filled the pool
      while (_pool.length >= maxControllers) {
        final oldestEntryKey = _findOldestKey(excludeKey: postId);
        if (oldestEntryKey != null) {
          await disposeController(oldestEntryKey);
        } else {
          break;
        }
      }

      final entry = PooledVideoPlayerEntry(
        postId: postId,
        url: videoUrl,
        controller: controller,
        lastAccessed: DateTime.now(),
      );

      _pool[postId] = entry;
      return controller;
    } on Object catch (e, st) {
      if (controller != null) {
        try {
          await controller.dispose();
        } on Object catch (_) {}
      }
      AppLogger.error(
        'VideoPlayerPool: Failed to init controller for post $postId: $e',
        e,
        st,
      );
      return null;
    }
  }

  void releaseController(String postId) {
    final entry = _pool[postId];
    if (entry != null && entry.controller.value.isPlaying) {
      entry.controller.pause();
    }
  }

  void updateGlobalMute({required bool isMuted}) {
    for (final entry in _pool.values) {
      entry.controller.setVolume(isMuted ? 0 : 1);
    }
  }

  Future<void> disposeController(String postId) async {
    _initTokens.remove(postId)?.cancelled = true;
    final entry = _pool.remove(postId);
    if (entry != null) {
      try {
        await entry.controller.pause();
        await entry.controller.dispose();
      } on Object catch (e) {
        AppLogger.error('VideoPlayerPool: Error disposing controller: $e');
      }
    }
  }

  Future<void> disposeAll() async {
    for (final token in _initTokens.values) {
      token.cancelled = true;
    }
    _initTokens.clear();
    final keys = List<String>.from(_pool.keys);
    for (final key in keys) {
      await disposeController(key);
    }
    _pool.clear();
  }

  String? _findOldestKey({String? excludeKey}) {
    // Prefer evicting paused/idle entries so pre-warming never evicts the
    // currently playing video.
    String? oldestIdleKey;
    DateTime? oldestIdleTime;
    String? oldestAnyKey;
    DateTime? oldestAnyTime;

    for (final entry in _pool.entries) {
      if (entry.key == excludeKey) continue;
      final isPlaying = entry.value.controller.value.isPlaying;
      final accessed = entry.value.lastAccessed;

      if (!isPlaying &&
          (oldestIdleTime == null || accessed.isBefore(oldestIdleTime))) {
        oldestIdleTime = accessed;
        oldestIdleKey = entry.key;
      }

      if (oldestAnyTime == null || accessed.isBefore(oldestAnyTime)) {
        oldestAnyTime = accessed;
        oldestAnyKey = entry.key;
      }
    }

    return oldestIdleKey ??
        oldestAnyKey ??
        (excludeKey != null ? null : _pool.keys.firstOrNull);
  }
}

final videoPlayerPoolProvider = Provider<VideoPlayerPool>((ref) {
  final pool = VideoPlayerPool()..disposeAll(); // initial clean state if needed

  ref
    ..listen(
      feedPlaybackCoordinatorProvider.select((s) => s.isGloballyMuted),
      (previous, next) {
        pool.updateGlobalMute(isMuted: next);
      },
    )
    ..onDispose(pool.disposeAll);

  return pool;
});
