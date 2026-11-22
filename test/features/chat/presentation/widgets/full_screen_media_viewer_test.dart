import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/full_screen_media_viewer.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _MockDio extends Mock implements Dio {}

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  _FakeVideoPlayerPlatform({this.initGate});

  final Completer<void>? initGate;
  final List<DataSource> createdDataSources = [];
  final Map<int, DataSource> dataSourceByPlayerId = {};
  final List<int> playedPlayerIds = [];
  final List<int> pausedPlayerIds = [];
  final List<int> disposedPlayerIds = [];
  int _nextPlayerId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    final id = _nextPlayerId++;
    createdDataSources.add(dataSource);
    dataSourceByPlayerId[id] = dataSource;
    return id;
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _nextPlayerId++;
    createdDataSources.add(options.dataSource);
    dataSourceByPlayerId[id] = options.dataSource;
    return id;
  }

  @override
  Future<void> dispose(int playerId) async {
    disposedPlayerIds.add(playerId);
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> play(int playerId) async {
    playedPlayerIds.add(playerId);
  }

  @override
  Future<void> pause(int playerId) async {
    pausedPlayerIds.add(playerId);
  }

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
    final initializedEvent = VideoEvent(
      eventType: VideoEventType.initialized,
      duration: const Duration(seconds: 10),
      size: const Size(1920, 1080),
    );
    final controller = StreamController<VideoEvent>();
    if (initGate == null) {
      controller.add(initializedEvent);
    } else {
      initGate!.future.then((_) {
        if (!controller.isClosed) {
          controller.add(initializedEvent);
        }
      });
    }
    return controller.stream;
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

    testWidgets(
        'pre-warms next video paused, plays instantly on swipe, and evicts '
        'controllers outside sliding window', (tester) async {
      final fakePlatform = _FakeVideoPlayerPlatform();
      final previousPlatform = VideoPlayerPlatform.instance;
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() => VideoPlayerPlatform.instance = previousPlatform);

      const videos = [
        MediaEntity(url: '/tmp/clip_0.mp4', mimeType: 'video/mp4'),
        MediaEntity(url: '/tmp/clip_1.mp4', mimeType: 'video/mp4'),
        MediaEntity(url: '/tmp/clip_2.mp4', mimeType: 'video/mp4'),
        MediaEntity(url: '/tmp/clip_3.mp4', mimeType: 'video/mp4'),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(medias: videos),
        ),
      );
      await tester.pumpAndSettle();

      // Active video (clip_0) initialized + played; neighbor (clip_1)
      // pre-warmed paused; clip_2 and clip_3 not yet allocated.
      expect(fakePlatform.createdDataSources, hasLength(2));
      expect(fakePlatform.createdDataSources[0].uri, contains('clip_0.mp4'));
      expect(fakePlatform.createdDataSources[1].uri, contains('clip_1.mp4'));
      expect(fakePlatform.playedPlayerIds, [1]);

      // Swipe to clip_1 -> reuses already pre-warmed player 2 (no duplicate
      // creation for clip_1), pauses clip_0, plays clip_1, pre-warms clip_2.
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(fakePlatform.createdDataSources, hasLength(3));
      expect(fakePlatform.createdDataSources[2].uri, contains('clip_2.mp4'));
      expect(fakePlatform.pausedPlayerIds, contains(1));
      expect(fakePlatform.playedPlayerIds, contains(2));
      expect(fakePlatform.disposedPlayerIds, isEmpty);

      // Swipe to clip_2 -> evicts & disposes clip_0 (outside [1, 2, 3]),
      // plays pre-warmed clip_2, and pre-warms clip_3.
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));

      expect(fakePlatform.createdDataSources, hasLength(4));
      expect(fakePlatform.createdDataSources[3].uri, contains('clip_3.mp4'));
      expect(fakePlatform.playedPlayerIds, contains(3));
      expect(fakePlatform.disposedPlayerIds, contains(1));
    });

    testWidgets('routes network videos through VideoPreCacheManager proxy',
        (tester) async {
      registerFallbackValue(RequestOptions());
      registerFallbackValue(Options());
      registerFallbackValue(CancelToken());

      final fakePlatform = _FakeVideoPlayerPlatform();
      final previousPlatform = VideoPlayerPlatform.instance;
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() => VideoPlayerPlatform.instance = previousPlatform);

      final mockDio = _MockDio();
      when(
        () => mockDio.get<List<int>>(
          any(),
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

      final tempDir =
          Directory.systemTemp.createTempSync('viewer_precache_test_');
      final preCache = await tester.runAsync(() async {
        final manager = VideoPreCacheManager(
          dio: mockDio,
          cacheDirGetter: () async => tempDir,
        );
        await manager.ensureStarted();
        return manager;
      });
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      });

      const videos = [
        MediaEntity(
          url: 'https://example.com/v0.mp4',
          mimeType: 'video/mp4',
        ),
        MediaEntity(
          url: 'https://example.com/v1.mp4',
          mimeType: 'video/mp4',
        ),
        MediaEntity(
          url: 'https://example.com/v2.mp4',
          mimeType: 'video/mp4',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenMediaViewer(
            medias: videos,
            preCacheManager: preCache,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0;
          i < 6 &&
              (!preCache!.isPreCached('https://example.com/v1.mp4') ||
                  !preCache.isPreCached('https://example.com/v2.mp4'));
          i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }

      // Active video (v0) & pre-warmed neighbor (v1) use loopback proxy
      expect(fakePlatform.createdDataSources.length, greaterThanOrEqualTo(2));
      expect(fakePlatform.createdDataSources.first.uri, contains('127.0.0.1'));
      expect(fakePlatform.createdDataSources[1].uri, contains('127.0.0.1'));
      expect(preCache!.isPreCached('https://example.com/v1.mp4'), isTrue);
      expect(preCache.isPreCached('https://example.com/v2.mp4'), isTrue);

      await tester.runAsync(preCache.dispose);
    });

    testWidgets('shows poster thumbnail while video is initializing',
        (tester) async {
      final initGate = Completer<void>();
      final fakePlatform = _FakeVideoPlayerPlatform(initGate: initGate);
      final previousPlatform = VideoPlayerPlatform.instance;
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() => VideoPlayerPlatform.instance = previousPlatform);

      const videoWithThumb = MediaEntity(
        url: '/tmp/loading_clip.mp4',
        thumbnailUrl: 'https://example.com/poster.jpg',
        mimeType: 'video/mp4',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenMediaViewer(medias: [videoWithThumb]),
        ),
      );
      await tester.pump();

      // Before initialization finishes, both poster thumbnail and loader show
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      initGate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(VideoPlayer), findsOneWidget);
    });
  });
}
