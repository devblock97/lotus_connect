import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testPost = PostItem(
    id: 'test_1',
    author: PostAuthor(
      id: 'author_1',
      username: 'marvel',
    ),
    content:
        "Start your countdown to the glorious arrival of Marvel Studios' #Loki",
    likeCount: 905235,
    likedByUsername: 'thekamraan',
    commentCount: 103,
  );

  group('PostCard Widget Tests', () {
    testWidgets('renders username, likes, and comments prompt', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostCard(post: testPost),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Verify username is rendered
      expect(find.text('marvel'), findsWidgets);

      // Verify comment count text is rendered
      expect(find.text('View all 103 comments'), findsOneWidget);

      // Verify action icons exist
      expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chat_bubble), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.paperplane), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.bookmark), findsOneWidget);
    });

    testWidgets('toggles like state when like button is tapped',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var likeState = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostCard(
                post: testPost,
                onLikeChanged: (val) {
                  likeState = val;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.heart_fill), findsNothing);

      // Tap like button
      await tester.tap(find.byIcon(CupertinoIcons.heart));
      await tester.pump(const Duration(milliseconds: 300));

      expect(likeState, isTrue);
      expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
    });

    testWidgets('toggles bookmark state when bookmark button is tapped',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var saveState = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostCard(
                post: testPost,
                onSaveChanged: (val) {
                  saveState = val;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(CupertinoIcons.bookmark), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.bookmark_fill), findsNothing);

      // Tap bookmark button
      await tester.tap(find.byIcon(CupertinoIcons.bookmark));
      await tester.pump(const Duration(milliseconds: 300));

      expect(saveState, isTrue);
      expect(find.byIcon(CupertinoIcons.bookmark_fill), findsOneWidget);
    });

    testWidgets('triggers like on double tap on media', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var likeState = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostCard(
                post: testPost,
                onLikeChanged: (val) {
                  likeState = val;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Double tap on media
      final mediaGestureFinder = find.byType(GestureDetector).at(3);
      await tester.tap(mediaGestureFinder);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(mediaGestureFinder);
      await tester.pump(const Duration(milliseconds: 300));

      // Should be liked
      expect(likeState, isTrue);
    });
  });
}
