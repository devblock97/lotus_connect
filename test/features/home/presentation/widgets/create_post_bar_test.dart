import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/presentation/widgets/create_post_bar.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';

void main() {
  testWidgets('CreatePostBar renders user name and quick action buttons',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsNotifierProvider.overrideWith(
            (_) => FakeSettingsNotifier(
              const AppSettings(fullName: 'John Doe', username: 'johndoe'),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CreatePostBar(),
          ),
        ),
      ),
    );

    expect(find.text("What's on your mind, John?"), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Feeling'), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.emoji_emotions_rounded), findsOneWidget);
  });
}

class FakeSettingsNotifier extends StateNotifier<SettingsState>
    implements SettingsNotifier {
  FakeSettingsNotifier(AppSettings settings)
      : super(SettingsState(settings: settings));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
