import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_audience_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_sticker_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_text_editor_modal.dart';
import 'package:lotus_connect/features/home/presentation/widgets/story_trash_bin.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithLocalization(
    Widget child, {
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('StoryTrashBin Localization', () {
    testWidgets('renders localized strings in Vietnamese', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          const Stack(
            children: [
              StoryTrashBin(isVisible: true, isOverTrash: false),
            ],
          ),
          locale: const Locale('vi'),
        ),
      );
      expect(find.text('Kéo vào đây để xóa'), findsOneWidget);

      await tester.pumpWidget(
        wrapWithLocalization(
          const Stack(
            children: [
              StoryTrashBin(isVisible: true, isOverTrash: true),
            ],
          ),
          locale: const Locale('vi'),
        ),
      );
      expect(find.text('Thả để xóa'), findsOneWidget);
    });

    testWidgets('renders localized strings in Japanese', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          const Stack(
            children: [
              StoryTrashBin(isVisible: true, isOverTrash: false),
            ],
          ),
          locale: const Locale('ja'),
        ),
      );
      expect(find.text('ここにドラッグして削除'), findsOneWidget);

      await tester.pumpWidget(
        wrapWithLocalization(
          const Stack(
            children: [
              StoryTrashBin(isVisible: true, isOverTrash: true),
            ],
          ),
          locale: const Locale('ja'),
        ),
      );
      expect(find.text('離して削除'), findsOneWidget);
    });
  });

  group('StoryAudienceSheet Localization', () {
    testWidgets('renders audience options in Vietnamese', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        wrapWithLocalization(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => StoryAudienceSheet.show(ctx, 'public'),
              child: const Text('Open'),
            ),
          ),
          locale: const Locale('vi'),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Đối tượng xem tin'), findsOneWidget);
      expect(find.text('Tin của bạn'), findsOneWidget);
      expect(
        find.text('Mọi người trên Lotus Connect đều có thể xem'),
        findsOneWidget,
      );
      expect(find.text('Bạn thân'), findsOneWidget);
      expect(
        find.text('Chỉ những người trong danh sách Bạn thân'),
        findsOneWidget,
      );
      expect(find.text('Bạn bè'), findsOneWidget);
      expect(
        find.text('Chỉ bạn bè đã chấp nhận mới xem được'),
        findsOneWidget,
      );
    });

    testWidgets('renders audience options in Japanese', (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        wrapWithLocalization(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => StoryAudienceSheet.show(ctx, 'public'),
              child: const Text('Open'),
            ),
          ),
          locale: const Locale('ja'),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('ストーリーズの公開範囲'), findsOneWidget);
      expect(find.text('あなたのストーリーズ'), findsOneWidget);
      expect(
        find.text('Lotus Connect上の誰でも閲覧可能'),
        findsOneWidget,
      );
      expect(find.text('親しい友達'), findsOneWidget);
      expect(
        find.text('親しい友達リストの人のみ'),
        findsOneWidget,
      );
      expect(find.text('友達'), findsOneWidget);
      expect(
        find.text('承認された友達のみ閲覧可能'),
        findsOneWidget,
      );
    });
  });

  group('StoryTextEditorModal Localization', () {
    testWidgets('renders localized Done button and hint in Vietnamese',
        (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        wrapWithLocalization(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => StoryTextEditorModal.show(ctx),
              child: const Text('Edit Text'),
            ),
          ),
          locale: const Locale('vi'),
        ),
      );

      await tester.tap(find.text('Edit Text'));
      await tester.pumpAndSettle();

      expect(find.text('Xong'), findsOneWidget);
      expect(find.text('Nhập nội dung...'), findsOneWidget);
    });
  });

  group('StoryStickerSheet Localization', () {
    testWidgets('renders localized section headers in Vietnamese',
        (tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(
        wrapWithLocalization(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => StoryStickerSheet.show(ctx),
              child: const Text('Open Stickers'),
            ),
          ),
          locale: const Locale('vi'),
        ),
      );

      await tester.tap(find.text('Open Stickers'));
      await tester.pumpAndSettle();

      expect(find.text('Nhãn dán'), findsOneWidget);
      expect(find.text('Vị trí'), findsOneWidget);
      expect(find.text('Tùy chỉnh...'), findsOneWidget);
      expect(find.text('Trạng thái & Cảm xúc'), findsOneWidget);
      expect(find.text('Biểu tượng cảm xúc'), findsOneWidget);

      // Tap mention badge to open dialog
      await tester.tap(find.text('@MENTION'));
      await tester.pumpAndSettle();

      expect(find.text('Nhắc đến ai đó'), findsOneWidget);
      expect(find.text('@tên_người_dùng'), findsOneWidget);
    });
  });
}
