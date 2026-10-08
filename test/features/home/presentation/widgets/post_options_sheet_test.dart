import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_options_sheet.dart';

void main() {
  const samplePost = PostItem(
    id: 'post_100',
    author: PostAuthor(id: 'author_1', username: 'alex'),
    content: 'A wonderful day!',
  );

  Widget buildTestWidget({
    required bool isAuthor,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              PostOptionsSheet.show(
                context,
                post: samplePost,
                isAuthor: isAuthor,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    );
  }

  group('PostOptionsSheet Widget Tests', () {
    testWidgets('shows Edit, Audience, and Delete options for author',
        (tester) async {
      var editCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          isAuthor: true,
          onEdit: () => editCalled = true,
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Post Options'), findsOneWidget);
      expect(find.text('Edit post'), findsOneWidget);
      expect(find.text('Delete post'), findsOneWidget);
      expect(find.text('Copy link to post'), findsOneWidget);

      // Tap Edit
      await tester.tap(find.text('Edit post'));
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets(
        'Delete option triggers confirmation dialog before calling onDelete',
        (tester) async {
      var deleteCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          isAuthor: true,
          onDelete: () => deleteCalled = true,
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap Delete post
      await tester.tap(find.text('Delete post'));
      await tester.pumpAndSettle();

      // Confirmation dialog should be visible
      expect(find.text('Delete post?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete this post? This cannot be undone.',
        ),
        findsOneWidget,
      );

      // Tap Delete in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('shows Save, Hide, and Report options for non-author',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(isAuthor: false));

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Edit post'), findsNothing);
      expect(find.text('Delete post'), findsNothing);
      expect(find.text('Save post'), findsOneWidget);
      expect(find.text('Hide post'), findsOneWidget);
      expect(find.text('Report post'), findsOneWidget);
      expect(find.text('Copy link to post'), findsOneWidget);
    });
  });
}
