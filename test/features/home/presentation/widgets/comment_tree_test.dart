import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_tree.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testReply1 = CommentUiModel(
    id: 'reply_1',
    postId: 'post_1',
    parentCommentId: 'root_1',
    author: const PostAuthor(
      id: 'author_2',
      username: 'tony_stark',
      fullName: 'Tony Stark',
    ),
    content: 'I am Iron Man',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    likeCount: 5,
  );

  final testReply2 = CommentUiModel(
    id: 'reply_2',
    postId: 'post_1',
    parentCommentId: 'root_1',
    author: const PostAuthor(
      id: 'author_3',
      username: 'steve_rogers',
      fullName: 'Steve Rogers',
    ),
    content: 'I can do this all day',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
  );

  final testRootComment = CommentUiModel(
    id: 'root_1',
    postId: 'post_1',
    author: const PostAuthor(
      id: 'author_1',
      username: 'thor_odinson',
      fullName: 'Thor Odinson',
    ),
    content: 'Bring me Thanos!',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    likeCount: 42,
    replyCount: 2,
    replies: [testReply1, testReply2],
    isRepliesExpanded: true,
  );

  group('CommentTree Widget Tests', () {
    testWidgets('renders root comment author, content, and Facebook-style meta',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      CommentUiModel? repliedTo;
      CommentUiModel? likedComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CommentTree(
                root: testRootComment,
                currentUserId: 'author_1',
                postAuthorId: 'author_1',
                onReply: (c) => repliedTo = c,
                onToggleLike: (c) => likedComment = c,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify root comment content
      expect(find.text('Thor Odinson'), findsOneWidget);
      expect(find.text('Bring me Thanos!'), findsOneWidget);

      // Verify 'Author' badge is rendered because author_1 matches postAuthorId
      expect(find.text('Author'), findsOneWidget);

      // Verify like and reply action buttons
      expect(find.text('Like'), findsWidgets);
      expect(find.text('Reply'), findsWidgets);

      // Verify reaction count pill
      expect(find.text('42'), findsOneWidget);

      // Verify nested replies are rendered
      expect(find.text('Tony Stark'), findsOneWidget);
      expect(find.text('I am Iron Man'), findsOneWidget);
      expect(find.text('Steve Rogers'), findsOneWidget);
      expect(find.text('I can do this all day'), findsOneWidget);

      // Tap Like on root comment
      await tester.tap(find.text('Like').first);
      expect(likedComment?.id, equals('root_1'));

      // Tap Reply on root comment
      await tester.tap(find.text('Reply').first);
      expect(repliedTo?.id, equals('root_1'));
    });

    testWidgets('collapses and expands replies tree on tap', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final collapsedRoot = testRootComment.copyWith(
        isRepliesExpanded: false,
        replies: [],
      );

      var toggleCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CommentTree(
                root: collapsedRoot,
                currentUserId: 'viewer',
                onToggleReplies: (_) => toggleCallCount++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // View replies button should be visible
      expect(find.text('View 2 replies'), findsOneWidget);
      expect(find.text('Tony Stark'), findsNothing);

      // Tap "View 2 replies"
      await tester.tap(find.text('View 2 replies'));
      await tester.pumpAndSettle();

      expect(toggleCallCount, equals(1));
    });
  });
}
