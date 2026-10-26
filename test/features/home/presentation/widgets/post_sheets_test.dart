import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_feeling_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_location_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_privacy_sheet.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

void main() {
  Widget buildHarness({
    required Widget child,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('PostPrivacySheet Widget Tests', () {
    testWidgets('renders in English and triggers onSelect callback',
        (tester) async {
      String? selected;

      await tester.pumpWidget(
        buildHarness(
          child: PostPrivacySheet(
            currentVisibility: 'public',
            onSelect: (val) => selected = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Post Audience'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Only me'), findsOneWidget);

      await tester.tap(find.text('Friends'));
      await tester.pump();

      expect(selected, equals('friends'));
    });

    testWidgets('renders in Japanese correctly', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          locale: const Locale('ja'),
          child: PostPrivacySheet(
            currentVisibility: 'public',
            onSelect: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('投稿の公開範囲'), findsOneWidget);
      expect(find.text('公開'), findsOneWidget);
      expect(find.text('友達'), findsOneWidget);
      expect(find.text('自分のみ'), findsOneWidget);
    });
  });

  group('PostFeelingSheet Widget Tests', () {
    testWidgets('renders in Vietnamese and filters by search query',
        (tester) async {
      String? pickedFeeling;

      await tester.pumpWidget(
        buildHarness(
          locale: const Locale('vi'),
          child: PostFeelingSheet(
            onSelect: (feeling, emoji) => pickedFeeling = feeling,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bạn đang cảm thấy thế nào?'), findsOneWidget);
      expect(find.text('Tìm kiếm cảm xúc...'), findsOneWidget);

      // Search for specific feeling 'happy'
      await tester.enterText(find.byType(TextField), 'happy');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'happy'), findsOneWidget);

      // Tap feeling
      await tester.tap(find.widgetWithText(InkWell, 'happy'));
      await tester.pump();

      expect(pickedFeeling, equals('happy'));
    });
  });

  group('PostLocationSheet Widget Tests', () {
    testWidgets('renders in Japanese and shows custom query item',
        (tester) async {
      String? pickedLocation;

      await tester.pumpWidget(
        buildHarness(
          locale: const Locale('ja'),
          child: PostLocationSheet(
            onSelect: (loc) => pickedLocation = loc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('場所を追加'), findsOneWidget);
      expect(find.text('今どこにいますか？'), findsOneWidget);

      // Enter custom query
      await tester.enterText(find.byType(TextField), 'Kyoto');
      await tester.pumpAndSettle();

      expect(find.text('「Kyoto」を使用'), findsOneWidget);

      // Tap custom location
      await tester.tap(find.text('「Kyoto」を使用'));
      await tester.pump();

      expect(pickedLocation, equals('Kyoto'));
    });
  });
}
