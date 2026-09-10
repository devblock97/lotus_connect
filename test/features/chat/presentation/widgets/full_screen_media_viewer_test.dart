import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/full_screen_media_viewer.dart';

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
  });
}
