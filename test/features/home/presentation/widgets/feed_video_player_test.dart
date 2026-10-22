import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/feed_playback_coordinator.dart';
import 'package:lotus_connect/features/home/application/video_player_pool.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/presentation/widgets/feed_video_player.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MockVideoPlayerController extends Mock implements VideoPlayerController {}

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Widget buildView(int playerId) => const SizedBox();

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => const SizedBox();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockVideoPlayerController mockController;
  late VideoPlayerPool testPool;

  setUp(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    mockController = MockVideoPlayerController();

    when(mockController.initialize).thenAnswer((_) async {});
    when(() => mockController.setLooping(any())).thenAnswer((_) async {});
    when(() => mockController.setVolume(any())).thenAnswer((_) async {});
    when(mockController.play).thenAnswer((_) async {});
    when(mockController.pause).thenAnswer((_) async {});
    when(mockController.dispose).thenAnswer((_) async {});
    when(() => mockController.addListener(any())).thenReturn(null);
    when(() => mockController.removeListener(any())).thenReturn(null);
    when(() => mockController.playerId).thenReturn(1);
    when(() => mockController.value).thenReturn(
      const VideoPlayerValue(
        duration: Duration(seconds: 30),
        isInitialized: true,
        size: Size(1080, 1920),
      ),
    );

    testPool = VideoPlayerPool(
      controllerFactory: (uri) => mockController,
    );
  });

  group('FeedVideoPlayer Widget Tests', () {
    const testMedia = PostMediaItem(
      url: 'http://example.com/uploads/transcoded/job123/master.m3u8',
      thumbnailUrl:
          'http://example.com/uploads/transcoded/job123/thumbnail.jpg',
      mimeType: 'application/x-mpegURL',
      duration: 45,
      width: 1080,
      height: 1920,
    );

    testWidgets('renders fallback/poster thumbnail and video icon by default',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerPoolProvider.overrideWithValue(testPool),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FeedVideoPlayer(
                postId: 'post_1',
                media: testMedia,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Top right video camera badge exists
      expect(find.byIcon(CupertinoIcons.videocam_fill), findsOneWidget);

      // Bottom right mute button exists and shows muted (volume_off) by default
      expect(find.byIcon(CupertinoIcons.volume_off), findsOneWidget);

      // Tap video to pause playback
      await tester.tap(find.byType(FeedVideoPlayer));
      await tester.pump(const Duration(milliseconds: 500));

      // Play icon overlay exists when paused
      expect(find.byIcon(CupertinoIcons.play_fill), findsOneWidget);
    });

    testWidgets('taps mute button toggles global mute in coordinator',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerPoolProvider.overrideWithValue(testPool),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  capturedRef = ref;
                  return const FeedVideoPlayer(
                    postId: 'post_1',
                    media: testMedia,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        capturedRef.read(feedPlaybackCoordinatorProvider).isGloballyMuted,
        isTrue,
      );

      // Tap the volume button
      await tester.tap(find.byIcon(CupertinoIcons.volume_off));
      await tester.pump();

      // Coordinator should now be unmuted
      expect(
        capturedRef.read(feedPlaybackCoordinatorProvider).isGloballyMuted,
        isFalse,
      );

      // UI should now show volume_up icon
      expect(find.byIcon(CupertinoIcons.volume_up), findsWidgets);

      // Flush remaining mute badge timer (1200ms)
      await tester.pump(const Duration(milliseconds: 1300));
    });
  });
}
