import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/full_screen_media_viewer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final List<DataSource> createdDataSources = [];
  int _nextPlayerId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    createdDataSources.add(dataSource);
    return _nextPlayerId++;
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    createdDataSources.add(options.dataSource);
    return _nextPlayerId++;
  }

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return Stream.value(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 10),
        size: const Size(1920, 1080),
      ),
    );
  }

  @override
  Widget buildView(int playerId) => const SizedBox();

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => const SizedBox();
}

void main() {
  const testMedia1 = MediaEntity(
    url: 'https://example.com/image1.png',
    fileName: 'photo_1.png',
    mimeType: 'image/png',
  );

  const testMedia2 = MediaEntity(
    url: 'https://example.com/image2.png',
    fileName: 'photo_2.png',
    mimeType: 'image/png',
  );

  group('FullScreenMediaViewer', () {
    testWidgets('renders close button and counter for multiple medias',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(
            medias: [testMedia1, testMedia2],
          ),
        ),
      );
      await tester.pump();

      // Verify close button exists
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Verify counter indicator displays current page
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('photo_1.png'), findsOneWidget);
    });

    testWidgets('swipe changes current page index and updates counter',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(
            medias: [testMedia1, testMedia2],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1 / 2'), findsOneWidget);

      // Swipe left to go to second page
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('photo_2.png'), findsOneWidget);
    });

    testWidgets('tapping close button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    FullScreenMediaViewer.show(
                      context,
                      medias: [testMedia1],
                    );
                  },
                  child: const Text('Open Viewer'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap to open viewer
      await tester.tap(find.text('Open Viewer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FullScreenMediaViewer), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify viewer is popped
      expect(find.byType(FullScreenMediaViewer), findsNothing);
    });

    testWidgets('renders Image.file for local image path', (tester) async {
      const localImage = MediaEntity(
        url: '/tmp/local_photo.jpg',
        mimeType: 'image/jpeg',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(
            medias: [localImage],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsNothing);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<FileImage>());
      expect(
        (imageWidget.image as FileImage).file.path,
        '/tmp/local_photo.jpg',
      );
    });

    testWidgets('renders CachedNetworkImage for network image URL',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(
            medias: [testMedia1],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('uses file data source for local video including .mov',
        (tester) async {
      final fakePlatform = _FakeVideoPlayerPlatform();
      final previousPlatform = VideoPlayerPlatform.instance;
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() => VideoPlayerPlatform.instance = previousPlatform);

      const localVideo = MediaEntity(
        url: '/tmp/recorded_clip.MOV',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(
            medias: [localVideo],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePlatform.createdDataSources, hasLength(1));
      expect(
        fakePlatform.createdDataSources.single.sourceType,
        DataSourceType.file,
      );
      expect(
        fakePlatform.createdDataSources.single.uri,
        contains('recorded_clip.MOV'),
      );
      expect(find.byType(VideoPlayer), findsOneWidget);
    });

    testWidgets('uses network data source for HLS network video',
        (tester) async {
      final fakePlatform = _FakeVideoPlayerPlatform();
      final previousPlatform = VideoPlayerPlatform.instance;
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() => VideoPlayerPlatform.instance = previousPlatform);

      const hlsVideo = MediaEntity(
        url: 'https://example.com/videos/stream.m3u8?token=abc',
        mimeType: 'application/x-mpegurl',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(
            medias: [hlsVideo],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePlatform.createdDataSources, hasLength(1));
      expect(
        fakePlatform.createdDataSources.single.sourceType,
        DataSourceType.network,
      );
      expect(find.byType(VideoPlayer), findsOneWidget);
    });
  });
}
