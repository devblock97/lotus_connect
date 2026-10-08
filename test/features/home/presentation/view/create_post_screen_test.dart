import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/create_post_params.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_post_usecase.dart';
import 'package:lotus_connect/features/home/presentation/view/create_post_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:mocktail/mocktail.dart';

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

class MockUpdatePostUseCase extends Mock implements UpdatePostUseCase {}

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

void main() {
  late MockCreatePostUseCase mockCreatePostUseCase;
  late MockUpdatePostUseCase mockUpdatePostUseCase;
  late MockGetFeedUseCase mockGetFeedUseCase;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const CreatePostParams());
    registerFallbackValue(
      const UpdatePostParams(postId: 'fallback', content: 'fallback'),
    );
  });

  setUp(() {
    mockCreatePostUseCase = MockCreatePostUseCase();
    mockUpdatePostUseCase = MockUpdatePostUseCase();
    mockGetFeedUseCase = MockGetFeedUseCase();

    when(() => mockGetFeedUseCase(any()))
        .thenAnswer((_) async => const Right(<PostItem>[]));
  });

  testWidgets(
      'CreatePostScreen displays author, textfield, and enables Post button',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createPostUseCaseProvider.overrideWithValue(mockCreatePostUseCase),
          settingsNotifierProvider.overrideWith(
            (_) => FakeSettingsNotifier(
              const AppSettings(fullName: 'Alice Smith', username: 'alice'),
            ),
          ),
          feedNotifierProvider.overrideWith(
            (ref) => FeedNotifier(getFeedUseCase: mockGetFeedUseCase),
          ),
        ],
        child: const MaterialApp(
          home: CreatePostScreen(),
        ),
      ),
    );

    // Verify initial layout
    expect(find.text('Create post'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Alice Smith'),
      ),
      findsOneWidget,
    );
    expect(find.text('Public'), findsOneWidget);
    expect(find.text("What's on your mind, Alice?"), findsOneWidget);
    expect(find.text('Add to your post'), findsOneWidget);

    // Initial state: Post button is present and disabled
    final postButtonFinder = find.widgetWithText(FilledButton, 'Post');
    expect(postButtonFinder, findsOneWidget);
    var button = tester.widget<FilledButton>(postButtonFinder);
    expect(button.onPressed, isNull);

    // Enter text
    await tester.enterText(
      find.byType(TextField).first,
      'Hello Lotus Connect!',
    );
    await tester.pump();

    // Now button should be enabled
    button = tester.widget<FilledButton>(postButtonFinder);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('CreatePostScreen submits post and pops on success',
      (tester) async {
    const createdPost = PostItem(
      id: 'p_101',
      author: PostAuthor(id: 'a_1', username: 'alice'),
      content: 'Hello Lotus Connect!',
    );

    when(() => mockCreatePostUseCase(any()))
        .thenAnswer((_) async => const Right(createdPost));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createPostUseCaseProvider.overrideWithValue(mockCreatePostUseCase),
          settingsNotifierProvider.overrideWith(
            (_) => FakeSettingsNotifier(
              const AppSettings(fullName: 'Alice Smith', username: 'alice'),
            ),
          ),
          feedNotifierProvider.overrideWith(
            (ref) => FeedNotifier(getFeedUseCase: mockGetFeedUseCase),
          ),
        ],
        child: const MaterialApp(
          home: CreatePostScreen(),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField).first,
      'Hello Lotus Connect!',
    );
    await tester.pump();

    final postButtonFinder = find.widgetWithText(FilledButton, 'Post');
    await tester.tap(postButtonFinder);
    await tester.pump();

    verify(() => mockCreatePostUseCase(any())).called(1);
  });

  testWidgets('CreatePostScreen initializes in edit mode and submits update',
      (tester) async {
    const postToEdit = PostItem(
      id: 'p_200',
      author: PostAuthor(id: 'a_1', username: 'alice'),
      content: 'Original message',
    );
    const updatedPost = PostItem(
      id: 'p_200',
      author: PostAuthor(id: 'a_1', username: 'alice'),
      content: 'Updated message',
    );

    when(() => mockUpdatePostUseCase(any()))
        .thenAnswer((_) async => const Right(updatedPost));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createPostUseCaseProvider.overrideWithValue(mockCreatePostUseCase),
          updatePostUseCaseProvider.overrideWithValue(mockUpdatePostUseCase),
          settingsNotifierProvider.overrideWith(
            (_) => FakeSettingsNotifier(
              const AppSettings(fullName: 'Alice Smith', username: 'alice'),
            ),
          ),
          feedNotifierProvider.overrideWith(
            (ref) => FeedNotifier(getFeedUseCase: mockGetFeedUseCase),
          ),
        ],
        child: const MaterialApp(
          home: CreatePostScreen(
            postToEdit: postToEdit,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Edit post title and prefilled content
    expect(find.text('Edit post'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Original message'), findsOneWidget);

    // Edit text
    await tester.enterText(
      find.byType(TextField).first,
      'Updated message',
    );
    await tester.pump();

    // Tap Save
    final saveButtonFinder = find.widgetWithText(FilledButton, 'Save');
    await tester.tap(saveButtonFinder);
    await tester.pump();

    verify(() => mockUpdatePostUseCase(any())).called(1);
  });

  testWidgets(
      'CreatePostScreen bottom toolbar renders without overflow on 390px',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createPostUseCaseProvider.overrideWithValue(mockCreatePostUseCase),
          settingsNotifierProvider.overrideWith(
            (_) => FakeSettingsNotifier(
              const AppSettings(fullName: 'John Nguyen', username: 'john'),
            ),
          ),
          feedNotifierProvider.overrideWith(
            (ref) => FeedNotifier(getFeedUseCase: mockGetFeedUseCase),
          ),
        ],
        child: const MaterialApp(
          home: CreatePostScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add to your post'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class FakeSettingsNotifier extends StateNotifier<SettingsState>
    implements SettingsNotifier {
  FakeSettingsNotifier(AppSettings settings)
      : super(SettingsState(settings: settings));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
