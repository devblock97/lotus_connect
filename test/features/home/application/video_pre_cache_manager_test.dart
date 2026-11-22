import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
    registerFallbackValue(CancelToken());
  });

  group('VideoPreCacheManager Tests', () {
    late MockDio mockDio;
    late Directory tempDir;
    late VideoPreCacheManager manager;

    setUp(() {
      mockDio = MockDio();
      tempDir = Directory.systemTemp.createTempSync('video_precache_test_');

      manager = VideoPreCacheManager(
        dio: mockDio,
        cacheDirGetter: () async => tempDir,
      );
    });

    tearDown(() async {
      await manager.dispose();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('preCacheMedia fetches master playlist, rendition, and Chunk 0',
        () async {
      const masterContent = '''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
360p.m3u8
''';

      const mediaContent = '''
#EXTM3U
#EXT-X-VERSION:3
#EXTINF:2.0,
segment_000.ts
''';

      // 1. Master playlist response
      when(
        () => mockDio.get<String>(
          'http://example.com/master.m3u8',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: masterContent,
          statusCode: 200,
        ),
      );

      // 2. Media rendition response
      when(
        () => mockDio.get<String>(
          'http://example.com/360p.m3u8',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: mediaContent,
          statusCode: 200,
        ),
      );

      // 3. Chunk 0 segment response
      when(
        () => mockDio.get<List<int>>(
          'http://example.com/segment_000.ts',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: [1, 2, 3, 4],
          statusCode: 200,
        ),
      );

      const media = PostMediaItem(
        url: 'http://example.com/master.m3u8',
        thumbnailUrl: 'http://example.com/thumb.jpg',
      );

      await manager.preCacheMedia(media);

      expect(manager.isPreCached('http://example.com/master.m3u8'), isTrue);
      // Playable URL should be local proxy URL
      final playable =
          await manager.getPlayableUrlAsync('http://example.com/master.m3u8');
      expect(playable, contains('127.0.0.1'));
      expect(playable, contains('http%3A%2F%2Fexample.com%2Fmaster.m3u8'));
    });

    test('preCacheUpcoming pre-fetches posts N+1 and N+2', () async {
      when(
        () => mockDio.get<List<int>>(
          any(),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: [0, 1, 2],
          statusCode: 200,
        ),
      );

      final posts = [
        const PostItem(
          id: 'post_0',
          author: PostAuthor(id: '1', username: 'user1'),
          content: 'Post 0',
          mediaItems: [
            PostMediaItem(
              url: 'http://example.com/v0.mp4',
              mimeType: 'video/mp4',
            ),
          ],
        ),
        const PostItem(
          id: 'post_1',
          author: PostAuthor(id: '2', username: 'user2'),
          content: 'Post 1',
          mediaItems: [
            PostMediaItem(
              url: 'http://example.com/v1.mp4',
              mimeType: 'video/mp4',
            ),
          ],
        ),
        const PostItem(
          id: 'post_2',
          author: PostAuthor(id: '3', username: 'user3'),
          content: 'Post 2',
          mediaItems: [
            PostMediaItem(
              url: 'http://example.com/v2.mp4',
              mimeType: 'video/mp4',
            ),
          ],
        ),
        const PostItem(
          id: 'post_3',
          author: PostAuthor(id: '4', username: 'user4'),
          content: 'Post 3',
          mediaItems: [
            PostMediaItem(
              url: 'http://example.com/v3.mp4',
              mimeType: 'video/mp4',
            ),
          ],
        ),
      ];

      manager.preCacheUpcoming(posts: posts, currentIndex: 0);

      // Give async background pre-cache a brief moment
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Post 1 and Post 2 should be pre-cached
      expect(manager.isPreCached('http://example.com/v1.mp4'), isTrue);
      expect(manager.isPreCached('http://example.com/v2.mp4'), isTrue);
      // Post 3 should not be pre-cached yet
      expect(manager.isPreCached('http://example.com/v3.mp4'), isFalse);
    });

    test('clearCache removes files and resets pre-cache status', () async {
      when(
        () => mockDio.get<List<int>>(
          any(),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: [1, 2, 3],
          statusCode: 200,
        ),
      );

      const media = PostMediaItem(
        url: 'http://example.com/video.mp4',
        mimeType: 'video/mp4',
      );

      await manager.preCacheMedia(media);
      expect(manager.isPreCached('http://example.com/video.mp4'), isTrue);

      await manager.clearCache();
      expect(manager.isPreCached('http://example.com/video.mp4'), isFalse);
    });

    test('preCacheUrl auto-detects HLS URL with query parameters', () async {
      const playlist = '''
#EXTM3U
#EXTINF:2.0,
seg0.ts
''';
      when(
        () => mockDio.get<String>(
          'http://example.com/stream.m3u8?token=xyz',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: playlist,
          statusCode: 200,
        ),
      );
      when(
        () => mockDio.get<List<int>>(
          'http://example.com/seg0.ts',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: [9, 8, 7],
          statusCode: 200,
        ),
      );

      await manager.preCacheUrl('http://example.com/stream.m3u8?token=xyz');

      expect(
        manager.isPreCached('http://example.com/stream.m3u8?token=xyz'),
        isTrue,
      );
    });

    test('enforces concurrency limit and cancels stale downloads', () async {
      final firstCompleter = Completer<Response<List<int>>>();
      CancelToken? capturedToken;

      final throttled = VideoPreCacheManager(
        dio: mockDio,
        cacheDirGetter: () async => tempDir,
        maxConcurrentPreCaches: 1,
      );
      addTearDown(throttled.dispose);

      when(
        () => mockDio.get<List<int>>(
          'http://example.com/a.mp4',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) {
        capturedToken = invocation.namedArguments[#cancelToken] as CancelToken?;
        return firstCompleter.future;
      });
      when(
        () => mockDio.get<List<int>>(
          'http://example.com/b.mp4',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: [1, 2, 3],
          statusCode: 200,
        ),
      );

      final futureA = throttled.preCacheUrl('http://example.com/a.mp4');
      final futureB = throttled.preCacheUrl('http://example.com/b.mp4');

      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Only 'a.mp4' should have started due to maxConcurrentPreCaches = 1
      verify(
        () => mockDio.get<List<int>>(
          'http://example.com/a.mp4',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      verifyNever(
        () => mockDio.get<List<int>>(
          'http://example.com/b.mp4',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      );

      // Cancel everything except 'c.mp4' -> cancels 'a.mp4' & drops 'b.mp4'
      throttled.cancelPreCachesExcept(['http://example.com/c.mp4']);
      expect(capturedToken?.isCancelled, isTrue);

      firstCompleter.completeError(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.cancel,
        ),
      );
      await Future.wait([futureA, futureB]);

      expect(throttled.isPreCached('http://example.com/a.mp4'), isFalse);
      expect(throttled.isPreCached('http://example.com/b.mp4'), isFalse);
    });

    test('hydrates existing disk cache without hitting network again',
        () async {
      when(
        () => mockDio.get<List<int>>(
          'http://example.com/cached.mp4',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: [10, 20, 30, 40],
          statusCode: 200,
        ),
      );

      await manager.preCacheUrl('http://example.com/cached.mp4');
      expect(manager.isPreCached('http://example.com/cached.mp4'), isTrue);

      // New manager instance pointing at the same cache directory
      final secondManager = VideoPreCacheManager(
        dio: mockDio,
        cacheDirGetter: () async => tempDir,
      );
      addTearDown(secondManager.dispose);

      await secondManager.preCacheUrl('http://example.com/cached.mp4');
      expect(
        secondManager.isPreCached('http://example.com/cached.mp4'),
        isTrue,
      );

      // Network was only called once across both manager instances
      verify(
        () => mockDio.get<List<int>>(
          'http://example.com/cached.mp4',
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });

    test('evicts oldest disk cache entries when maxDiskCacheBytes is exceeded',
        () async {
      final smallCacheManager = VideoPreCacheManager(
        dio: mockDio,
        cacheDirGetter: () async => tempDir,
        maxDiskCacheBytes: 120,
      );
      addTearDown(smallCacheManager.dispose);

      when(
        () => mockDio.get<List<int>>(
          any(),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          data: List<int>.filled(40, 1),
          statusCode: 200,
        ),
      );

      await smallCacheManager.preCacheUrl('http://example.com/old.mp4');
      // Ensure distinct file timestamps on filesystems with coarse mtime
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await smallCacheManager.preCacheUrl('http://example.com/new.mp4');

      // Each entry is 40 bytes chunk + ~50 bytes meta.json (> 90 bytes each),
      // so 2 entries exceed 120 bytes and 'old.mp4' must be evicted.
      expect(
        smallCacheManager.isPreCached('http://example.com/old.mp4'),
        isFalse,
      );
      expect(
        smallCacheManager.isPreCached('http://example.com/new.mp4'),
        isTrue,
      );
    });
  });
}
