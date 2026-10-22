import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight embedded loopback proxy server to serve pre-cached chunks
/// and manifests to VideoPlayerController with 0ms latency.
class VideoCacheProxyServer {
  VideoCacheProxyServer({required this.cacheDirGetter});

  final Future<Directory> Function() cacheDirGetter;
  HttpServer? _server;
  final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  int? get port => _server?.port;
  bool get isRunning => _server != null;

  /// Starts the loopback HTTP server.
  Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.listen(
        _handleRequest,
        onError: (Object e) {
          AppLogger.error('VideoCacheProxyServer error: $e');
        },
      );
      AppLogger.info('VideoCacheProxyServer started on port ${_server!.port}');
    } on Object catch (e) {
      AppLogger.error('VideoCacheProxyServer failed to start: $e');
    }
  }

  String _hashUrl(String url) {
    return base64Url.encode(utf8.encode(url)).replaceAll('=', '');
  }

  /// Handles incoming video chunk / manifest proxy requests.
  Future<void> _handleRequest(HttpRequest request) async {
    final targetUrl = request.uri.queryParameters['url'];
    if (targetUrl == null || targetUrl.isEmpty) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }

    try {
      final cacheDir = await cacheDirGetter();
      final urlHash = _hashUrl(targetUrl);
      final postDir = Directory('${cacheDir.path}/$urlHash');

      // Check if we have a cached chunk or manifest
      final isHls = targetUrl.toLowerCase().contains('.m3u8');
      File? cachedFile;

      if (isHls) {
        final masterFile = File('${postDir.path}/master.m3u8');
        if (masterFile.existsSync()) {
          cachedFile = masterFile;
        }
      } else {
        final chunkFile = File('${postDir.path}/chunk_0.bin');
        if (chunkFile.existsSync()) {
          cachedFile = chunkFile;
        }
      }

      if (cachedFile != null) {
        // Serve pre-cached file directly from disk (0ms latency)
        request.response.headers.contentType = isHls
            ? ContentType('application', 'x-mpegURL')
            : ContentType('video', 'mp4');
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        await cachedFile.openRead().pipe(request.response);
        return;
      }

      // If not in cache, proxy request to remote server
      final clientRequest = await _httpClient.getUrl(Uri.parse(targetUrl));
      // Copy incoming headers (Range, User-Agent, etc.)
      request.headers.forEach((name, values) {
        if (name.toLowerCase() != 'host') {
          for (final value in values) {
            clientRequest.headers.add(name, value);
          }
        }
      });

      final clientResponse = await clientRequest.close();
      request.response.statusCode = clientResponse.statusCode;
      clientResponse.headers.forEach((name, values) {
        for (final value in values) {
          request.response.headers.add(name, value);
        }
      });
      request.response.headers.set('Access-Control-Allow-Origin', '*');

      await clientResponse.pipe(request.response);
    } on Object catch (e) {
      AppLogger.error('VideoCacheProxyServer proxy error for $targetUrl: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } on Object catch (_) {}
    }
  }

  /// Stops the server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _httpClient.close(force: true);
  }
}

/// Manages predictive pre-caching for upcoming feed video posts (posts
/// N+1 and N+2). Pre-caches master playlist, primary rendition, and Chunk 0.
class VideoPreCacheManager {
  VideoPreCacheManager({
    Dio? dio,
    Future<Directory> Function()? cacheDirGetter,
    String Function()? serverHostGetter,
  })  : _dio = dio ?? Dio(),
        _serverHostGetter = serverHostGetter ?? (() => ''),
        _cacheDirGetter = cacheDirGetter ??
            (() async {
              final appDir = await getTemporaryDirectory();
              final dir = Directory('${appDir.path}/lotus_video_precache');
              if (!dir.existsSync()) {
                dir.createSync(recursive: true);
              }
              return dir;
            }) {
    _proxyServer = VideoCacheProxyServer(cacheDirGetter: _cacheDirGetter);
    _proxyServer.start();
  }

  final Dio _dio;
  final Future<Directory> Function() _cacheDirGetter;
  final String Function() _serverHostGetter;
  late final VideoCacheProxyServer _proxyServer;

  final Set<String> _inFlightUrls = {};
  final Set<String> _preCachedUrls = {};

  String _hashUrl(String url) {
    return base64Url.encode(utf8.encode(url)).replaceAll('=', '');
  }

  bool isPreCached(String videoUrl) {
    final activeHost = _serverHostGetter();
    final normalized = normalizeMediaUrl(videoUrl, serverHost: activeHost);
    return _preCachedUrls.contains(normalized);
  }

  /// Returns playable URL (served through 0ms local proxy if pre-cached,
  /// otherwise returns normalized active URL).
  String getPlayableUrl(String remoteUrl) {
    final activeHost = _serverHostGetter();
    final normalized = normalizeMediaUrl(remoteUrl, serverHost: activeHost);
    if (_proxyServer.isRunning &&
        _proxyServer.port != null &&
        isPreCached(normalized)) {
      final encoded = Uri.encodeComponent(normalized);
      return 'http://127.0.0.1:${_proxyServer.port}/video?url=$encoded';
    }
    return normalized;
  }

  /// Predictively pre-caches upcoming feed video posts (N+1 and N+2).
  void preCacheUpcoming({
    required List<PostItem> posts,
    required int currentIndex,
    int lookAhead = 2,
  }) {
    if (posts.isEmpty || currentIndex < 0 || currentIndex >= posts.length) {
      return;
    }

    final startIndex = currentIndex + 1;
    final endIndex = (currentIndex + lookAhead).clamp(0, posts.length - 1);

    for (var i = startIndex; i <= endIndex; i++) {
      final post = posts[i];
      final primaryMedia = post.primaryMedia;
      if (primaryMedia != null && primaryMedia.isVideo) {
        unawaited(preCacheMedia(primaryMedia));
      }
    }
  }

  /// Pre-caches a specific post's media item (manifest + Chunk 0).
  Future<void> preCacheMedia(PostMediaItem media) async {
    final activeHost = _serverHostGetter();
    final url = normalizeMediaUrl(media.url, serverHost: activeHost);
    if (url.isEmpty || !url.startsWith('http')) return;
    if (_preCachedUrls.contains(url) || _inFlightUrls.contains(url)) return;

    _inFlightUrls.add(url);

    try {
      final cacheDir = await _cacheDirGetter();
      final urlHash = _hashUrl(url);
      final postDir = Directory('${cacheDir.path}/$urlHash');
      if (!postDir.existsSync()) {
        postDir.createSync(recursive: true);
      }

      if (media.isHls) {
        await _preCacheHls(url, postDir);
      } else {
        await _preCacheStandardVideo(url, postDir);
      }

      _preCachedUrls.add(url);
      AppLogger.info('Successfully pre-cached Chunk 0 for video: $url');
    } on Object catch (e, st) {
      AppLogger.error(
        'VideoPreCacheManager failed to pre-cache $url: $e',
        e,
        st,
      );
    } finally {
      _inFlightUrls.remove(url);
    }
  }

  /// Pre-caches HLS master playlist, primary rendition, and first 2s segment.
  Future<void> _preCacheHls(String masterUrl, Directory postDir) async {
    // Fetch master playlist
    final masterRes = await _dio.get<String>(
      masterUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final masterContent = masterRes.data ?? '';
    final masterFile = File('${postDir.path}/master.m3u8');
    await masterFile.writeAsString(masterContent);

    // Parse media playlist rendition (e.g. 360p or first stream)
    final mediaPlaylistUrl = _resolveFirstRenditionUrl(
      masterUrl,
      masterContent,
    );
    if (mediaPlaylistUrl == null) return;

    // Fetch media playlist
    final mediaRes = await _dio.get<String>(
      mediaPlaylistUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final mediaContent = mediaRes.data ?? '';
    final mediaFile = File('${postDir.path}/media.m3u8');
    await mediaFile.writeAsString(mediaContent);

    // Parse Chunk 0 (first .ts or .mp4 segment)
    final chunk0Url = _resolveFirstSegmentUrl(mediaPlaylistUrl, mediaContent);
    if (chunk0Url == null) return;

    // Download Chunk 0 (2-second initial segment)
    final chunkRes = await _dio.get<List<int>>(
      chunk0Url,
      options: Options(responseType: ResponseType.bytes),
    );
    final chunkBytes = chunkRes.data;
    if (chunkBytes != null) {
      final chunkFile = File('${postDir.path}/chunk_0.ts');
      await chunkFile.writeAsBytes(chunkBytes);
    }
  }

  /// Pre-caches initial chunk (first 1MB / ~2s) of direct MP4/video file.
  Future<void> _preCacheStandardVideo(
    String videoUrl,
    Directory postDir,
  ) async {
    final response = await _dio.get<List<int>>(
      videoUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Range': 'bytes=0-1048575'},
      ),
    );
    final bytes = response.data;
    if (bytes != null) {
      final chunkFile = File('${postDir.path}/chunk_0.bin');
      await chunkFile.writeAsBytes(bytes);
    }
  }

  /// Helper to parse first stream rendition URL from an HLS master playlist.
  String? _resolveFirstRenditionUrl(String masterUrl, String content) {
    final lines = content.split('\n');
    final masterUri = Uri.parse(masterUrl);

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXT-X-STREAM-INF')) {
        // Next non-comment line is rendition URI
        for (var j = i + 1; j < lines.length; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
            return masterUri.resolve(nextLine).toString();
          }
        }
      }
    }

    if (content.contains('#EXTINF')) {
      return masterUrl;
    }

    return null;
  }

  /// Helper to parse first segment URL from an HLS media playlist.
  String? _resolveFirstSegmentUrl(String mediaUrl, String content) {
    final lines = content.split('\n');
    final mediaUri = Uri.parse(mediaUrl);

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXTINF')) {
        // Next non-comment line is Chunk 0
        for (var j = i + 1; j < lines.length; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
            return mediaUri.resolve(nextLine).toString();
          }
        }
      }
    }

    return null;
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await _cacheDirGetter();
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
      }
      _preCachedUrls.clear();
      _inFlightUrls.clear();
    } on Object catch (e) {
      AppLogger.error('Failed to clear video pre-cache: $e');
    }
  }

  Future<void> dispose() async {
    await _proxyServer.stop();
  }
}

final videoPreCacheManagerProvider = Provider<VideoPreCacheManager>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final manager = VideoPreCacheManager(
    dio: dioClient.dio,
    serverHostGetter: () =>
        ref.read(settingsNotifierProvider).settings.serverHost,
  );

  ref.onDispose(manager.dispose);

  return manager;
});
