import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

void main() {
  group('PostMediaItem Tests', () {
    test('detects HLS .m3u8 playlist as isVideo and isHls', () {
      const item = PostMediaItem(
        url: 'http://example.com/uploads/transcoded/123/master.m3u8',
        thumbnailUrl: 'http://example.com/uploads/transcoded/123/thumbnail.jpg',
      );

      expect(item.isVideo, isTrue);
      expect(item.isHls, isTrue);
    });

    test('detects application/x-mpegURL and application/vnd.apple.mpegurl', () {
      const item1 = PostMediaItem(
        url: 'http://example.com/stream/index',
        mimeType: 'application/x-mpegURL',
      );
      const item2 = PostMediaItem(
        url: 'http://example.com/stream/index',
        mimeType: 'application/vnd.apple.mpegurl',
      );

      expect(item1.isVideo, isTrue);
      expect(item1.isHls, isTrue);
      expect(item2.isVideo, isTrue);
      expect(item2.isHls, isTrue);
    });

    test('detects standard MP4 video', () {
      const item = PostMediaItem(
        url: 'http://example.com/video.mp4',
        mimeType: 'video/mp4',
      );

      expect(item.isVideo, isTrue);
      expect(item.isHls, isFalse);
    });

    test('detects image as not video', () {
      const item = PostMediaItem(
        url: 'http://example.com/photo.jpg',
        mimeType: 'image/jpeg',
      );

      expect(item.isVideo, isFalse);
      expect(item.isHls, isFalse);
    });

    test('aspectRatio clamps between 0.8 and 1.91', () {
      const portrait = PostMediaItem(
        url: 'http://example.com/test.mp4',
        width: 1080,
        height: 1920,
      );
      expect(portrait.aspectRatio, closeTo(0.8, 0.01));

      const wide = PostMediaItem(
        url: 'http://example.com/test.mp4',
        width: 1920,
        height: 800,
      );
      expect(wide.aspectRatio, closeTo(1.91, 0.01));

      const square = PostMediaItem(
        url: 'http://example.com/test.mp4',
        width: 1000,
        height: 1000,
      );
      expect(square.aspectRatio, equals(1.0));
    });

    test('normalizedForHost rebases uploads URL to target server host', () {
      const item = PostMediaItem(
        url: 'https://73ea-ngrok-free.app/uploads/video.mp4',
        thumbnailUrl: 'https://73ea-ngrok-free.app/uploads/thumb.jpg',
      );

      final normalized = item.normalizedForHost('http://10.0.2.2:8080');
      expect(
        normalized.url,
        equals('http://10.0.2.2:8080/uploads/video.mp4'),
      );
      expect(
        normalized.thumbnailUrl,
        equals('http://10.0.2.2:8080/uploads/thumb.jpg'),
      );
    });

    test('copyWith updates fields correctly', () {
      const item = PostMediaItem(url: 'http://example.com/v1.mp4');
      final updated = item.copyWith(
        url: 'http://example.com/v2.mp4',
        mimeType: 'video/mp4',
      );
      expect(updated.url, equals('http://example.com/v2.mp4'));
      expect(updated.mimeType, equals('video/mp4'));
    });
  });
}
