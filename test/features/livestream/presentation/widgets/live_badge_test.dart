import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/live_badge.dart';

void main() {
  testWidgets('LiveBadge renders LIVE text correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LiveBadge(pulse: false),
        ),
      ),
    );

    expect(find.text('LIVE'), findsOneWidget);
  });
}
