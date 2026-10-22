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

class VideoPlayerPool {
  VideoPlayerPool({
    this.maxControllers = 2,
    VideoPlayerController Function(Uri uri)? controllerFactory,
  }) : _controllerFactory =
            controllerFactory ?? VideoPlayerController.networkUrl;

  final int maxControllers;
  final VideoPlayerController Function(Uri uri) _controllerFactory;

  final Map<String, PooledVideoPlayerEntry> _pool = {};

  int get pooledCount => _pool.length;

  VideoPlayerController? getController(String postId) {
    final entry = _pool[postId];
    if (entry != null) {
      entry.lastAccessed = DateTime.now();
      return entry.controller;
    }
    return null;
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

    // Evict least-recently-used controller if at or above capacity
    while (_pool.length >= maxControllers) {
      final oldestEntryKey = _findOldestKey(excludeKey: postId);
      if (oldestEntryKey != null) {
        await disposeController(oldestEntryKey);
      } else {
        break;
      }
    }

    // Instantiate and initialize controller
    try {
      final controller = _controllerFactory(uri);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(isMuted ? 0 : 1);

      final entry = PooledVideoPlayerEntry(
        postId: postId,
        url: videoUrl,
        controller: controller,
        lastAccessed: DateTime.now(),
      );

      _pool[postId] = entry;
      return controller;
    } on Object catch (e, st) {
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
    final keys = List<String>.from(_pool.keys);
    for (final key in keys) {
      await disposeController(key);
    }
    _pool.clear();
  }

  String? _findOldestKey({String? excludeKey}) {
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _pool.entries) {
      if (entry.key == excludeKey) continue;
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestTime = entry.value.lastAccessed;
        oldestKey = entry.key;
      }
    }

    return oldestKey ?? (excludeKey != null ? null : _pool.keys.firstOrNull);
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
