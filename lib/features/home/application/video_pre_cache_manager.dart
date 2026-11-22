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
  VideoCacheProxyServer({
    required this.cacheDirGetter,
    String Function()? serverHostGetter,
  }) : _serverHostGetter = serverHostGetter ?? (() => '');

  final Future<Directory> Function() cacheDirGetter;
  final String Function() _serverHostGetter;
  HttpServer? _server;
  Future<void>? _startFuture;
  final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  int? get port => _server?.port;
  bool get isRunning => _server != null;

  /// Starts the loopback HTTP server (idempotent and safely awaitable).
  Future<void> start() {
    if (_server != null) return Future.value();
    return _startFuture ??= _bindServer();
  }

  Future<void> _bindServer() async {
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server = server;
      server.listen(
        _handleRequest,
        onError: (Object e) {
          AppLogger.error('VideoCacheProxyServer error: $e');
        },
      );
      AppLogger.info('VideoCacheProxyServer started on port ${server.port}');
    } on Object catch (e) {
      _startFuture = null;
      AppLogger.error('VideoCacheProxyServer failed to start: $e');
    }
  }

  String _hashUrl(String url) {
    return base64Url.encode(utf8.encode(url)).replaceAll('=', '');
  }

  String _buildProxyUrl(String remoteUrl) {
    final activeHost = _serverHostGetter();
    final normalized = normalizeMediaUrl(remoteUrl, serverHost: activeHost);
    final encoded = Uri.encodeComponent(normalized);
    return 'http://127.0.0.1:${_server!.port}/video?url=$encoded';
  }

  /// Rewrites relative/segment URLs in an HLS playlist so that rendition
  /// playlists and segments resolve properly when served from 127.0.0.1.
  String _rewriteHlsPlaylist(String content, String playlistUrl) {
    if (_server == null) return content;
    final baseUri = Uri.parse(playlistUrl);
    final uriAttrRegex = RegExp('URI="([^"]+)"');
    final lines = content.split('\n');
    final buffer = StringBuffer();

    for (var i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final trimmed = rawLine.trim();

      if (trimmed.isEmpty) {
        buffer.writeln(rawLine);
        continue;
      }

      if (trimmed.startsWith('#')) {
        if (trimmed.contains('URI="')) {
          final rewrittenTag = rawLine.replaceAllMapped(uriAttrRegex, (match) {
            final rawUri = match.group(1)!;
            final resolved = baseUri.resolve(rawUri).toString();
            return 'URI="${_buildProxyUrl(resolved)}"';
          });
          buffer.writeln(rewrittenTag);
        } else {
          buffer.writeln(rawLine);
        }
      } else {
        final resolved = baseUri.resolve(trimmed).toString();
        buffer.writeln(_buildProxyUrl(resolved));
      }
    }

    return buffer.toString();
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

      final lowerUrl = targetUrl.toLowerCase();
      final isHls = lowerUrl.contains('.m3u8');

      if (isHls) {
        await _handleHlsRequest(request, targetUrl, postDir);
        return;
      }

      // Check if we have a cached complete HLS segment (.ts)
      final tsSegmentFile = File('${postDir.path}/chunk_0.ts');
      if (tsSegmentFile.existsSync()) {
        await _serveFullCachedFile(
          request: request,
          file: tsSegmentFile,
          contentType: ContentType('video', 'mp2t'),
        );
        return;
      }

      // Check if we have a pre-cached head chunk (chunk_0.bin) for MP4/video
      final chunkFile = File('${postDir.path}/chunk_0.bin');
      if (chunkFile.existsSync()) {
        await _handleStandardVideoRequest(
          request: request,
          targetUrl: targetUrl,
          postDir: postDir,
          chunkFile: chunkFile,
        );
        return;
      }

      // If not in cache, proxy request directly to remote server
      await _proxyToRemote(request, targetUrl);
    } on Object catch (e) {
      AppLogger.error('VideoCacheProxyServer proxy error for $targetUrl: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } on Object catch (_) {}
    }
  }

  /// Serves a cached or remote HLS playlist with rewritten segment/rendition
  /// URLs so subsequent requests don't fail against localhost.
  Future<void> _handleHlsRequest(
    HttpRequest request,
    String targetUrl,
    Directory postDir,
  ) async {
    final masterFile = File('${postDir.path}/master.m3u8');
    if (masterFile.existsSync()) {
      final rawManifest = await masterFile.readAsString();
      final rewritten = _rewriteHlsPlaylist(rawManifest, targetUrl);
      final bytes = utf8.encode(rewritten);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType =
          ContentType('application', 'x-mpegURL', charset: 'utf-8');
      request.response.headers.contentLength = bytes.length;
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.add(bytes);
      await request.response.close();
      return;
    }

    // Fetch uncached playlist from remote and rewrite relative URLs
    final clientRequest = await _httpClient.getUrl(Uri.parse(targetUrl));
    _copyRequestHeaders(request, clientRequest, includeRange: false);
    final clientResponse = await clientRequest.close();

    if (clientResponse.statusCode == HttpStatus.ok) {
      final rawManifest = await utf8.decoder.bind(clientResponse).join();
      final rewritten = _rewriteHlsPlaylist(rawManifest, targetUrl);
      final bytes = utf8.encode(rewritten);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType =
          ContentType('application', 'x-mpegURL', charset: 'utf-8');
      request.response.headers.contentLength = bytes.length;
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.add(bytes);
      await request.response.close();
      return;
    }

    request.response.statusCode = clientResponse.statusCode;
    _copyResponseHeaders(clientResponse, request.response);
    await clientResponse.pipe(request.response);
  }

  /// Serves a complete cached file (e.g. a full HLS .ts segment) with Range
  /// support.
  Future<void> _serveFullCachedFile({
    required HttpRequest request,
    required File file,
    required ContentType contentType,
  }) async {
    final totalLen = file.lengthSync();
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    final range = _parseRange(rangeHeader);

    request.response.headers.contentType = contentType;
    request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    request.response.headers.set('Access-Control-Allow-Origin', '*');

    if (range != null && range.start < totalLen) {
      final end = (range.end != null && range.end! < totalLen)
          ? range.end!
          : (totalLen - 1);
      request.response.statusCode = HttpStatus.partialContent;
      request.response.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes ${range.start}-$end/$totalLen',
      );
      request.response.headers.contentLength = end - range.start + 1;
      await request.response.addStream(file.openRead(range.start, end + 1));
      await request.response.close();
      return;
    }

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentLength = totalLen;
    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  /// Serves a standard MP4/video where only the initial head (chunk_0.bin)
  /// is pre-cached on disk, seamlessly stitching the cached head with the
  /// remote tail and honoring HTTP Range requests so the entire video plays.
  Future<void> _handleStandardVideoRequest({
    required HttpRequest request,
    required String targetUrl,
    required Directory postDir,
    required File chunkFile,
  }) async {
    final chunkLen = chunkFile.lengthSync();
    if (chunkLen <= 0) {
      await _proxyToRemote(request, targetUrl);
      return;
    }

    // Read cached metadata (totalLength, contentType) if available
    int? totalLength;
    var contentTypeStr = 'video/mp4';
    final metaFile = File('${postDir.path}/meta.json');
    if (metaFile.existsSync()) {
      try {
        final meta =
            jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
        totalLength = meta['totalLength'] as int?;
        contentTypeStr = meta['contentType'] as String? ?? contentTypeStr;
      } on Object catch (_) {}
    }

    final contentType = _parseContentType(contentTypeStr);

    if (request.method.toUpperCase() == 'HEAD') {
      if (totalLength != null) {
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = contentType;
        request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
        request.response.headers.contentLength = totalLength;
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        await request.response.close();
        return;
      }
      await _proxyToRemote(request, targetUrl);
      return;
    }

    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    // Delegate suffix or multi-part ranges directly to remote server
    if (rangeHeader != null &&
        (rangeHeader.startsWith('bytes=-') || rangeHeader.contains(','))) {
      await _proxyToRemote(request, targetUrl);
      return;
    }

    final parsedRange = _parseRange(rangeHeader);
    final hasRange = parsedRange != null;
    final start = parsedRange?.start ?? 0;
    final requestedEnd = parsedRange?.end;

    // 1. Range starts at or after chunkLen -> proxy directly to remote server
    if (start >= chunkLen) {
      await _proxyToRemote(request, targetUrl);
      return;
    }

    // 2. Entire video file fits inside chunk_0.bin
    if (totalLength != null && chunkLen >= totalLength) {
      final effectiveEnd = (requestedEnd != null && requestedEnd < chunkLen)
          ? requestedEnd
          : (chunkLen - 1);
      request.response.statusCode =
          hasRange ? HttpStatus.partialContent : HttpStatus.ok;
      request.response.headers.contentType = contentType;
      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      if (hasRange) {
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$effectiveEnd/$chunkLen',
        );
      }
      request.response.headers.contentLength = effectiveEnd - start + 1;
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      await request.response.addStream(
        chunkFile.openRead(start, effectiveEnd + 1),
      );
      await request.response.close();
      return;
    }

    // 3. Requested byte range is completely within chunk_0.bin (e.g. 0-1 probe)
    if (requestedEnd != null &&
        requestedEnd < chunkLen &&
        totalLength != null) {
      request.response.statusCode = HttpStatus.partialContent;
      request.response.headers.contentType = contentType;
      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      request.response.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $start-$requestedEnd/$totalLength',
      );
      request.response.headers.contentLength = requestedEnd - start + 1;
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      await request.response.addStream(
        chunkFile.openRead(start, requestedEnd + 1),
      );
      await request.response.close();
      return;
    }

    // 4. Request spans across chunk_0.bin and remote tail (start < chunkLen,
    //    and end is open-ended or >= chunkLen).
    if (totalLength != null) {
      final effectiveEnd = (requestedEnd != null && requestedEnd < totalLength)
          ? requestedEnd
          : (totalLength - 1);

      // Start remote request for tail concurrently while flushing local head
      final tailFuture = _openRemoteRangeRequest(
        request: request,
        targetUrl: targetUrl,
        rangeValue: 'bytes=$chunkLen-$effectiveEnd',
      );
      unawaited(tailFuture.then((_) {}, onError: (_) {}));

      request.response.statusCode =
          hasRange ? HttpStatus.partialContent : HttpStatus.ok;
      request.response.headers.contentType = contentType;
      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      if (hasRange) {
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$effectiveEnd/$totalLength',
        );
      }
      request.response.headers.contentLength = effectiveEnd - start + 1;
      request.response.headers.set('Access-Control-Allow-Origin', '*');

      // Serve cached head (0ms latency)
      await request.response.addStream(chunkFile.openRead(start, chunkLen));
      await request.response.flush();

      // Append remaining bytes from remote server
      final tailResponse = await tailFuture;
      if (tailResponse.statusCode == HttpStatus.partialContent ||
          tailResponse.statusCode == HttpStatus.ok) {
        await request.response.addStream(tailResponse);
      } else {
        await tailResponse.drain<void>();
      }
      await request.response.close();
      return;
    }

    // 5. Fallback when totalLength was not known during pre-cache:
    //    If range is within chunk_0.bin, forward to remote or serve chunk.
    if (requestedEnd != null && requestedEnd < chunkLen) {
      await _proxyToRemote(request, targetUrl);
      return;
    }

    final tailResponse = await _openRemoteRangeRequest(
      request: request,
      targetUrl: targetUrl,
      rangeValue: 'bytes=$chunkLen-${requestedEnd ?? ''}',
    );

    if (tailResponse.statusCode == HttpStatus.partialContent) {
      final contentRange =
          tailResponse.headers.value(HttpHeaders.contentRangeHeader);
      final parsedTotal = _parseTotalFromContentRange(contentRange);
      final parsedEnd = _parseEndFromContentRange(contentRange);

      if (parsedTotal != null && parsedEnd != null) {
        // Persist discovered totalLength for future requests
        try {
          await metaFile.writeAsString(
            jsonEncode({
              'totalLength': parsedTotal,
              'chunkLength': chunkLen,
              'contentType': contentTypeStr,
            }),
          );
        } on Object catch (_) {}

        request.response.statusCode =
            hasRange ? HttpStatus.partialContent : HttpStatus.ok;
        request.response.headers.contentType = contentType;
        request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
        if (hasRange) {
          request.response.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes $start-$parsedEnd/$parsedTotal',
          );
        }
        request.response.headers.contentLength = parsedEnd - start + 1;
        request.response.headers.set('Access-Control-Allow-Origin', '*');

        await request.response.addStream(chunkFile.openRead(start, chunkLen));
        await request.response.addStream(tailResponse);
        await request.response.close();
        return;
      }
    } else if (tailResponse.statusCode ==
        HttpStatus.requestedRangeNotSatisfiable) {
      await tailResponse.drain<void>();
      // chunk_0.bin already contains the entire file
      final effectiveEnd = chunkLen - 1;
      request.response.statusCode =
          hasRange ? HttpStatus.partialContent : HttpStatus.ok;
      request.response.headers.contentType = contentType;
      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      if (hasRange) {
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$effectiveEnd/$chunkLen',
        );
      }
      request.response.headers.contentLength = effectiveEnd - start + 1;
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      await request.response.addStream(chunkFile.openRead(start, chunkLen));
      await request.response.close();
      return;
    }

    await tailResponse.drain<void>();
    await _proxyToRemote(request, targetUrl);
  }

  Future<HttpClientResponse> _openRemoteRangeRequest({
    required HttpRequest request,
    required String targetUrl,
    required String rangeValue,
  }) async {
    final clientRequest = await _httpClient.getUrl(Uri.parse(targetUrl));
    _copyRequestHeaders(request, clientRequest, includeRange: false);
    clientRequest.headers.set(HttpHeaders.rangeHeader, rangeValue);
    return clientRequest.close();
  }

  Future<void> _proxyToRemote(HttpRequest request, String targetUrl) async {
    final clientRequest = await _httpClient.openUrl(
      request.method,
      Uri.parse(targetUrl),
    );
    _copyRequestHeaders(request, clientRequest, includeRange: true);

    final clientResponse = await clientRequest.close();
    request.response.statusCode = clientResponse.statusCode;
    _copyResponseHeaders(clientResponse, request.response);
    await clientResponse.pipe(request.response);
  }

  void _copyRequestHeaders(
    HttpRequest source,
    HttpClientRequest target, {
    required bool includeRange,
  }) {
    source.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (lower == 'host') return;
      if (!includeRange && lower == 'range') return;
      for (final value in values) {
        target.headers.add(name, value);
      }
    });
  }

  void _copyResponseHeaders(
    HttpClientResponse source,
    HttpResponse target,
  ) {
    source.headers.forEach((name, values) {
      for (final value in values) {
        target.headers.add(name, value);
      }
    });
    target.headers.set('Access-Control-Allow-Origin', '*');
  }

  _ByteRange? _parseRange(String? rangeHeader) {
    if (rangeHeader == null || !rangeHeader.startsWith('bytes=')) {
      return null;
    }
    final spec = rangeHeader.substring('bytes='.length).trim();
    final parts = spec.split('-');
    if (parts.isEmpty) return null;
    final start = int.tryParse(parts[0]);
    if (start == null || start < 0) return null;
    final end = (parts.length > 1 && parts[1].isNotEmpty)
        ? int.tryParse(parts[1])
        : null;
    if (end != null && end < start) return null;
    return _ByteRange(start: start, end: end);
  }

  int? _parseTotalFromContentRange(String? contentRange) {
    if (contentRange == null) return null;
    final slashIdx = contentRange.indexOf('/');
    if (slashIdx == -1 || slashIdx + 1 >= contentRange.length) return null;
    final totalStr = contentRange.substring(slashIdx + 1).trim();
    if (totalStr == '*') return null;
    return int.tryParse(totalStr);
  }

  int? _parseEndFromContentRange(String? contentRange) {
    if (contentRange == null) return null;
    final match = RegExp(r'bytes\s+\d+-(\d+)/').firstMatch(contentRange);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  ContentType _parseContentType(String value) {
    try {
      return ContentType.parse(value);
    } on Object catch (_) {
      return ContentType('video', 'mp4');
    }
  }

  /// Stops the server.
  Future<void> stop() async {
    _startFuture = null;
    await _server?.close(force: true);
    _server = null;
    _httpClient.close(force: true);
  }
}

class _ByteRange {
  const _ByteRange({required this.start, this.end});

  final int start;
  final int? end;
}

class _PreCacheRequest {
  const _PreCacheRequest({
    required this.url,
    required this.isHls,
  });

  final String url;
  final bool isHls;
}

class _DiskCacheEntry {
  const _DiskCacheEntry({
    required this.directory,
    required this.hash,
    required this.sizeBytes,
    required this.lastModified,
  });

  final Directory directory;
  final String hash;
  final int sizeBytes;
  final DateTime lastModified;
}

/// Manages predictive pre-caching for upcoming videos (feeds, chills, full
/// screen viewer). Pre-caches HLS manifests + Chunk 0 or initial MP4 range,
/// serves them through an embedded loopback proxy, limits concurrent
/// downloads, supports cancelling stale requests, and enforces a bounded
/// LRU disk cache.
class VideoPreCacheManager {
  VideoPreCacheManager({
    Dio? dio,
    Future<Directory> Function()? cacheDirGetter,
    String Function()? serverHostGetter,
    this.maxConcurrentPreCaches = 2,
    this.maxDiskCacheBytes = 150 * 1024 * 1024,
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
    _proxyServer = VideoCacheProxyServer(
      cacheDirGetter: _cacheDirGetter,
      serverHostGetter: _serverHostGetter,
    );
    unawaited(_proxyServer.start());
  }

  final Dio _dio;
  final Future<Directory> Function() _cacheDirGetter;
  final String Function() _serverHostGetter;
  final int maxConcurrentPreCaches;
  final int maxDiskCacheBytes;
  late final VideoCacheProxyServer _proxyServer;

  final Set<String> _preCachedUrls = {};
  final Map<String, String> _hashToUrl = {};
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, Completer<void>> _completers = {};
  final List<_PreCacheRequest> _pendingQueue = [];
  int _activeDownloads = 0;
  bool _isEvicting = false;
  bool _isDisposed = false;

  String _hashUrl(String url) {
    return base64Url.encode(utf8.encode(url)).replaceAll('=', '');
  }

  String _normalize(String rawUrl) {
    final activeHost = _serverHostGetter();
    return normalizeMediaUrl(rawUrl, serverHost: activeHost);
  }

  bool _detectIsHls(String url) {
    final uri = Uri.tryParse(url);
    final path = (uri?.path ?? url).toLowerCase();
    return path.endsWith('.m3u8');
  }

  /// Ensures the local loopback proxy server has bound to a port.
  Future<void> ensureStarted() => _proxyServer.start();

  bool isPreCached(String videoUrl) {
    final normalized = _normalize(videoUrl);
    return _preCachedUrls.contains(normalized);
  }

  /// Returns playable URL (served through 0ms local loopback proxy, which
  /// caches chunks, rewrites HLS, and seamlessly bypasses native TLS/cert
  /// issues).
  String getPlayableUrl(String remoteUrl) {
    final normalized = _normalize(remoteUrl);
    if (_proxyServer.isRunning && _proxyServer.port != null) {
      final encoded = Uri.encodeComponent(normalized);
      return 'http://127.0.0.1:${_proxyServer.port}/video?url=$encoded';
    }
    return normalized;
  }

  /// Awaits proxy startup before returning the playable loopback URL so the
  /// very first video never misses the proxy while it is binding.
  Future<String> getPlayableUrlAsync(String remoteUrl) async {
    await ensureStarted();
    return getPlayableUrl(remoteUrl);
  }

  /// Predictively pre-caches upcoming feed video posts (N+1 and N+2) and
  /// cancels stale pre-caches outside the active window.
  void preCacheUpcoming({
    required List<PostItem> posts,
    required int currentIndex,
    int lookAhead = 2,
  }) {
    if (posts.isEmpty || currentIndex < 0 || currentIndex >= posts.length) {
      return;
    }

    final keepUrls = <String>{};
    final currentMedia = posts[currentIndex].primaryMedia;
    if (currentMedia != null && currentMedia.isVideo) {
      keepUrls.add(currentMedia.url);
    }

    final startIndex = currentIndex + 1;
    final endIndex = (currentIndex + lookAhead).clamp(0, posts.length - 1);

    final toPreCache = <PostMediaItem>[];
    for (var i = startIndex; i <= endIndex; i++) {
      final primaryMedia = posts[i].primaryMedia;
      if (primaryMedia != null && primaryMedia.isVideo) {
        keepUrls.add(primaryMedia.url);
        toPreCache.add(primaryMedia);
      }
    }

    cancelPreCachesExcept(keepUrls);

    for (final media in toPreCache) {
      unawaited(preCacheMedia(media));
    }
  }

  /// Pre-caches a specific post's media item (manifest + Chunk 0).
  Future<void> preCacheMedia(PostMediaItem media) {
    return preCacheUrl(media.url, isHls: media.isHls);
  }

  /// Pre-caches a video URL (HLS manifest + Chunk 0, or first 1 MB of MP4)
  /// with concurrency throttling, deduplication, and cancellation support.
  Future<void> preCacheUrl(
    String rawUrl, {
    bool? isHls,
    bool highPriority = false,
  }) {
    if (_isDisposed) return Future.value();
    final url = _normalize(rawUrl);
    if (url.isEmpty || !url.startsWith('http')) return Future.value();
    if (_preCachedUrls.contains(url)) return Future.value();

    final existingCompleter = _completers[url];
    if (existingCompleter != null) {
      if (highPriority) {
        final idx = _pendingQueue.indexWhere((r) => r.url == url);
        if (idx > 0) {
          final item = _pendingQueue.removeAt(idx);
          _pendingQueue.insert(0, item);
        }
      }
      return existingCompleter.future;
    }

    final completer = Completer<void>();
    _completers[url] = completer;

    final request = _PreCacheRequest(
      url: url,
      isHls: isHls ?? _detectIsHls(url),
    );
    if (highPriority) {
      _pendingQueue.insert(0, request);
    } else {
      _pendingQueue.add(request);
    }

    _drainQueue();
    return completer.future;
  }

  /// Cancels an in-flight or queued pre-cache request for [rawUrl].
  void cancelPreCache(String rawUrl) {
    final url = _normalize(rawUrl);
    _pendingQueue.removeWhere((req) => req.url == url);

    final token = _cancelTokens.remove(url);
    if (token != null && !token.isCancelled) {
      token.cancel('Cancelled stale video pre-cache');
    }

    final completer = _completers.remove(url);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  /// Cancels any queued or in-flight pre-cache requests not in [keepRawUrls].
  void cancelPreCachesExcept(Iterable<String> keepRawUrls) {
    final keepNormalized = keepRawUrls.map(_normalize).toSet();

    final removedQueued = <String>[];
    _pendingQueue.removeWhere((req) {
      final shouldRemove = !keepNormalized.contains(req.url);
      if (shouldRemove) removedQueued.add(req.url);
      return shouldRemove;
    });
    for (final url in removedQueued) {
      final completer = _completers.remove(url);
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    }

    final activeToCancel = _cancelTokens.keys
        .where((url) => !keepNormalized.contains(url))
        .toList();
    for (final url in activeToCancel) {
      final token = _cancelTokens.remove(url);
      if (token != null && !token.isCancelled) {
        token.cancel('Evicted from pre-cache window');
      }
    }
  }

  void _drainQueue() {
    while (!_isDisposed &&
        _activeDownloads < maxConcurrentPreCaches &&
        _pendingQueue.isNotEmpty) {
      final next = _pendingQueue.removeAt(0);
      _activeDownloads++;
      unawaited(_executePreCache(next));
    }
  }

  Future<void> _executePreCache(_PreCacheRequest request) async {
    final url = request.url;
    final cancelToken = CancelToken();
    _cancelTokens[url] = cancelToken;

    try {
      final cacheDir = await _cacheDirGetter();
      if (_isDisposed || cancelToken.isCancelled) return;

      final urlHash = _hashUrl(url);
      final postDir = Directory('${cacheDir.path}/$urlHash');

      // Hydrate from existing on-disk cache (e.g. across app restarts)
      if (_hasValidDiskCache(postDir, isHls: request.isHls)) {
        _preCachedUrls.add(url);
        _hashToUrl[urlHash] = url;
        _touchDiskCache(postDir, isHls: request.isHls);
        return;
      }

      if (!postDir.existsSync()) {
        postDir.createSync(recursive: true);
      }

      if (request.isHls) {
        await _preCacheHls(url, postDir, cacheDir, cancelToken: cancelToken);
      } else {
        await _preCacheStandardVideo(url, postDir, cancelToken: cancelToken);
      }

      if (_isDisposed || cancelToken.isCancelled) return;

      _preCachedUrls.add(url);
      _hashToUrl[urlHash] = url;
      AppLogger.info('Successfully pre-cached Chunk 0 for video: $url');
      await _evictDiskCacheIfNeeded();
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.cancel) {
        AppLogger.debug('VideoPreCacheManager cancelled pre-cache for $url');
      } else {
        AppLogger.error(
          'VideoPreCacheManager failed to pre-cache $url: $e',
          e,
          st,
        );
      }
    } on Object catch (e, st) {
      AppLogger.error(
        'VideoPreCacheManager failed to pre-cache $url: $e',
        e,
        st,
      );
    } finally {
      _cancelTokens.remove(url);
      _activeDownloads =
          (_activeDownloads - 1).clamp(0, maxConcurrentPreCaches);
      final completer = _completers.remove(url);
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
      _drainQueue();
    }
  }

  bool _hasValidDiskCache(Directory postDir, {required bool isHls}) {
    if (!postDir.existsSync()) return false;
    if (isHls) {
      final master = File('${postDir.path}/master.m3u8');
      final chunk = File('${postDir.path}/chunk_0.ts');
      return master.existsSync() &&
          master.lengthSync() > 0 &&
          chunk.existsSync() &&
          chunk.lengthSync() > 0;
    }
    final chunk = File('${postDir.path}/chunk_0.bin');
    return chunk.existsSync() && chunk.lengthSync() > 0;
  }

  void _touchDiskCache(Directory postDir, {required bool isHls}) {
    try {
      final target = File(
        '${postDir.path}/${isHls ? 'master.m3u8' : 'chunk_0.bin'}',
      );
      if (target.existsSync()) {
        target.setLastModifiedSync(DateTime.now());
      }
    } on Object catch (_) {}
  }

  /// Pre-caches HLS master playlist, primary rendition, and first 2s segment.
  Future<void> _preCacheHls(
    String masterUrl,
    Directory postDir,
    Directory cacheDir, {
    required CancelToken cancelToken,
  }) async {
    final activeHost = _serverHostGetter();
    // Fetch master playlist
    final masterRes = await _dio.get<String>(
      masterUrl,
      options: Options(responseType: ResponseType.plain),
      cancelToken: cancelToken,
    );
    if (cancelToken.isCancelled) return;

    final masterContent = masterRes.data ?? '';
    final masterFile = File('${postDir.path}/master.m3u8');
    await masterFile.writeAsString(masterContent);

    // Parse media playlist rendition (e.g. 360p or first stream)
    final rawMediaPlaylistUrl = _resolveFirstRenditionUrl(
      masterUrl,
      masterContent,
    );
    if (rawMediaPlaylistUrl == null) return;
    final mediaPlaylistUrl = normalizeMediaUrl(
      rawMediaPlaylistUrl,
      serverHost: activeHost,
    );

    // Fetch media playlist
    final mediaRes = await _dio.get<String>(
      mediaPlaylistUrl,
      options: Options(responseType: ResponseType.plain),
      cancelToken: cancelToken,
    );
    if (cancelToken.isCancelled) return;

    final mediaContent = mediaRes.data ?? '';
    final mediaFile = File('${postDir.path}/media.m3u8');
    await mediaFile.writeAsString(mediaContent);

    // Also index media playlist under its own URL hash so proxy requests hit
    // cache with 0ms latency
    if (mediaPlaylistUrl != masterUrl) {
      final mediaHash = _hashUrl(mediaPlaylistUrl);
      final mediaDir = Directory('${cacheDir.path}/$mediaHash');
      if (!mediaDir.existsSync()) {
        mediaDir.createSync(recursive: true);
      }
      await File('${mediaDir.path}/master.m3u8').writeAsString(mediaContent);
      _hashToUrl[mediaHash] = mediaPlaylistUrl;
    }

    // Parse Chunk 0 (first .ts or .mp4 segment)
    final rawChunk0Url = _resolveFirstSegmentUrl(
      mediaPlaylistUrl,
      mediaContent,
    );
    if (rawChunk0Url == null) return;
    final chunk0Url = normalizeMediaUrl(
      rawChunk0Url,
      serverHost: activeHost,
    );

    // Download Chunk 0 (2-second initial segment)
    final chunkRes = await _dio.get<List<int>>(
      chunk0Url,
      options: Options(responseType: ResponseType.bytes),
      cancelToken: cancelToken,
    );
    if (cancelToken.isCancelled) return;

    final chunkBytes = chunkRes.data;
    if (chunkBytes != null) {
      final chunkFile = File('${postDir.path}/chunk_0.ts');
      await chunkFile.writeAsBytes(chunkBytes);

      // Also index Chunk 0 under its own URL hash so segment proxy requests
      // hit disk cache directly
      final chunkHash = _hashUrl(chunk0Url);
      final chunkDir = Directory('${cacheDir.path}/$chunkHash');
      if (!chunkDir.existsSync()) {
        chunkDir.createSync(recursive: true);
      }
      await File('${chunkDir.path}/chunk_0.ts').writeAsBytes(chunkBytes);
      _hashToUrl[chunkHash] = chunk0Url;
    }
  }

  /// Pre-caches initial chunk (first 1MB / ~2s) of direct MP4/video file.
  Future<void> _preCacheStandardVideo(
    String videoUrl,
    Directory postDir, {
    required CancelToken cancelToken,
  }) async {
    final response = await _dio.get<List<int>>(
      videoUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Range': 'bytes=0-1048575'},
      ),
      cancelToken: cancelToken,
    );
    if (cancelToken.isCancelled) return;

    final bytes = response.data;
    if (bytes != null) {
      AppLogger.debug(
        'Pre-cached ${bytes.length} bytes for standard video: $videoUrl',
      );
      final chunkFile = File('${postDir.path}/chunk_0.bin');
      await chunkFile.writeAsBytes(bytes);

      final totalLength = _extractTotalLength(response);
      final contentType =
          response.headers.value(Headers.contentTypeHeader) ?? 'video/mp4';
      final metaFile = File('${postDir.path}/meta.json');
      await metaFile.writeAsString(
        jsonEncode({
          if (totalLength != null) 'totalLength': totalLength,
          'chunkLength': bytes.length,
          'contentType': contentType,
        }),
      );
    }
  }

  Future<void> _evictDiskCacheIfNeeded() async {
    if (_isEvicting || _isDisposed || maxDiskCacheBytes <= 0) return;
    _isEvicting = true;
    try {
      final cacheDir = await _cacheDirGetter();
      if (!cacheDir.existsSync()) return;

      final entries = <_DiskCacheEntry>[];
      var totalBytes = 0;

      for (final entity in cacheDir.listSync()) {
        if (entity is! Directory) continue;
        var dirBytes = 0;
        var latestModified = DateTime.fromMillisecondsSinceEpoch(0);

        for (final child in entity.listSync(recursive: true)) {
          if (child is File) {
            final stat = child.statSync();
            dirBytes += stat.size;
            if (stat.modified.isAfter(latestModified)) {
              latestModified = stat.modified;
            }
          }
        }

        totalBytes += dirBytes;
        final segments =
            entity.uri.pathSegments.where((s) => s.isNotEmpty).toList();
        final name = segments.isEmpty ? '' : segments.last;
        entries.add(
          _DiskCacheEntry(
            directory: entity,
            hash: name,
            sizeBytes: dirBytes,
            lastModified: latestModified,
          ),
        );
      }

      if (totalBytes <= maxDiskCacheBytes) return;

      final inFlightHashes = _cancelTokens.keys.map(_hashUrl).toSet();
      entries.sort((a, b) => a.lastModified.compareTo(b.lastModified));

      for (final entry in entries) {
        if (totalBytes <= maxDiskCacheBytes) break;
        if (inFlightHashes.contains(entry.hash)) continue;
        try {
          await entry.directory.delete(recursive: true);
          totalBytes -= entry.sizeBytes;
          final url = _hashToUrl.remove(entry.hash);
          if (url != null) {
            _preCachedUrls.remove(url);
          }
        } on Object catch (_) {}
      }
    } on Object catch (e) {
      AppLogger.error('VideoPreCacheManager disk eviction failed: $e');
    } finally {
      _isEvicting = false;
    }
  }

  int? _extractTotalLength(Response<List<int>> response) {
    final contentRange = response.headers.value('content-range');
    if (contentRange != null) {
      final slashIndex = contentRange.indexOf('/');
      if (slashIndex != -1 && slashIndex + 1 < contentRange.length) {
        final totalStr = contentRange.substring(slashIndex + 1).trim();
        if (totalStr != '*') {
          final parsed = int.tryParse(totalStr);
          if (parsed != null && parsed > 0) return parsed;
        }
      }
    }

    if (response.statusCode == HttpStatus.ok) {
      final contentLength = response.headers.value(Headers.contentLengthHeader);
      if (contentLength != null) {
        final parsed = int.tryParse(contentLength.trim());
        if (parsed != null && parsed > 0) return parsed;
      }
    }

    return null;
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
      cancelPreCachesExcept(const []);
      final cacheDir = await _cacheDirGetter();
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
      }
      _preCachedUrls.clear();
      _hashToUrl.clear();
    } on Object catch (e) {
      AppLogger.error('Failed to clear video pre-cache: $e');
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    cancelPreCachesExcept(const []);
    for (final completer in _completers.values) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _completers.clear();
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
