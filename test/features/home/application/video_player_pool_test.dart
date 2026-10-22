import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/video_player_pool.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';

class MockVideoPlayerController extends Mock implements VideoPlayerController {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com/video.mp4'));
  });

  group('VideoPlayerPool Tests', () {
    late MockVideoPlayerController mockController1;
    late MockVideoPlayerController mockController2;
    late MockVideoPlayerController mockController3;

    setUp(() {
      mockController1 = MockVideoPlayerController();
      mockController2 = MockVideoPlayerController();
      mockController3 = MockVideoPlayerController();

      for (final controller in [
        mockController1,
        mockController2,
        mockController3,
      ]) {
        when(controller.initialize).thenAnswer((_) async {});
        when(() => controller.setLooping(any())).thenAnswer((_) async {});
        when(() => controller.setVolume(any())).thenAnswer((_) async {});
        when(controller.play).thenAnswer((_) async {});
        when(controller.pause).thenAnswer((_) async {});
        when(controller.dispose).thenAnswer((_) async {});
        when(() => controller.value).thenReturn(
          const VideoPlayerValue(
            duration: Duration(seconds: 30),
            isPlaying: true,
          ),
        );
      }
    });

    test('acquires and initializes controller for post', () async {
      final pool = VideoPlayerPool(
        controllerFactory: (uri) => mockController1,
      );

      final controller = await pool.acquireController(
        postId: 'post_1',
        videoUrl: 'http://example.com/video1.m3u8',
        isMuted: true,
      );

      expect(controller, equals(mockController1));
      verify(mockController1.initialize).called(1);
      verify(() => mockController1.setLooping(true)).called(1);
      verify(() => mockController1.setVolume(0)).called(1);
      expect(pool.pooledCount, equals(1));
    });

    test('reuses existing pooled controller when requested again', () async {
      final pool = VideoPlayerPool(
        controllerFactory: (uri) => mockController1,
      );

      final controllerA = await pool.acquireController(
        postId: 'post_1',
        videoUrl: 'http://example.com/video1.m3u8',
        isMuted: true,
      );

      final controllerB = await pool.acquireController(
        postId: 'post_1',
        videoUrl: 'http://example.com/video1.m3u8',
        isMuted: false,
      );

      expect(controllerA, equals(controllerB));
      // initialize only called once
      verify(mockController1.initialize).called(1);
      // Volume updated to unmuted on second acquire
      verify(() => mockController1.setVolume(1)).called(1);
      expect(pool.pooledCount, equals(1));
    });

    test('enforces bounded pool (max 2) and evicts oldest controller',
        () async {
      final controllers = [mockController1, mockController2, mockController3];
      var index = 0;

      final pool = VideoPlayerPool(
        controllerFactory: (uri) => controllers[index++],
      );

      // Acquire 1st controller
      await pool.acquireController(
        postId: 'post_1',
        videoUrl: 'http://example.com/video1.m3u8',
        isMuted: true,
      );
      expect(pool.pooledCount, equals(1));

      // Acquire 2nd controller
      await pool.acquireController(
        postId: 'post_2',
        videoUrl: 'http://example.com/video2.m3u8',
        isMuted: true,
      );
      expect(pool.pooledCount, equals(2));

      // Acquire 3rd controller -> should evict post_1
      await pool.acquireController(
        postId: 'post_3',
        videoUrl: 'http://example.com/video3.m3u8',
        isMuted: true,
      );

      expect(pool.pooledCount, equals(2));
      // Controller 1 was evicted and disposed
      verify(mockController1.dispose).called(1);
      // Post 1 is no longer in pool
      expect(pool.getController('post_1'), isNull);
      // Post 2 and Post 3 are in pool
      expect(pool.getController('post_2'), isNotNull);
      expect(pool.getController('post_3'), isNotNull);
    });

    test('releases controller pauses playback', () async {
      final pool = VideoPlayerPool(
        controllerFactory: (uri) => mockController1,
      );

      await pool.acquireController(
        postId: 'post_1',
        videoUrl: 'http://example.com/video1.m3u8',
        isMuted: true,
      );

      pool.releaseController('post_1');
      verify(mockController1.pause).called(1);
    });

    test('updateGlobalMute updates all pooled controllers', () async {
      final controllers = [mockController1, mockController2];
      var index = 0;

      final pool = VideoPlayerPool(
        controllerFactory: (uri) => controllers[index++],
      );

      await pool.acquireController(
        postId: 'post_1',
        videoUrl: 'http://example.com/video1.m3u8',
        isMuted: true,
      );
      await pool.acquireController(
        postId: 'post_2',
        videoUrl: 'http://example.com/video2.m3u8',
        isMuted: true,
      );

      pool.updateGlobalMute(isMuted: false);

      verify(() => mockController1.setVolume(1)).called(1);
      verify(() => mockController2.setVolume(1)).called(1);
    });

    test('disposeAll pauses and disposes all controllers', () async {
      final pool = VideoPlayerPool(
        controllerFactory: (uri) => mockController1,
      );

      await pool.acquireController(
        postId: 'post_1',
        videoUrl: 'http://example.com/video1.m3u8',
        isMuted: true,
      );

      await pool.disposeAll();
      expect(pool.pooledCount, equals(0));
      verify(mockController1.dispose).called(1);
    });
  });
}
