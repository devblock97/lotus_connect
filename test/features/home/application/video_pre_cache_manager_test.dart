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
      final playable = manager.getPlayableUrl('http://example.com/master.m3u8');
      expect(playable, contains('127.0.0.1'));
      expect(playable, contains('http%3A%2F%2Fexample.com%2Fmaster.m3u8'));
    });

    test('preCacheUpcoming pre-fetches posts N+1 and N+2', () async {
      when(
        () => mockDio.get<List<int>>(
          any(),
          options: any(named: 'options'),
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
  });
}
