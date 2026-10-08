import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/home/application/create_post_notifier.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/domain/entities/create_post_params.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_post_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_feed_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_post_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

class MockUpdatePostUseCase extends Mock implements UpdatePostUseCase {}

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CreatePostParams());
    registerFallbackValue(
      const UpdatePostParams(postId: 'fallback', content: 'fallback'),
    );
    registerFallbackValue(const NoParams());
  });

  late MockCreatePostUseCase mockCreatePostUseCase;
  late MockUpdatePostUseCase mockUpdatePostUseCase;
  late MockGetFeedUseCase mockGetFeedUseCase;
  late FeedNotifier feedNotifier;
  late CreatePostNotifier createPostNotifier;

  const testPost = PostItem(
    id: 'test_post_1',
    author: PostAuthor(id: 'author_1', username: 'janedoe'),
    content: 'Loving the sunny day! ☀️',
  );

  setUp(() {
    mockCreatePostUseCase = MockCreatePostUseCase();
    mockUpdatePostUseCase = MockUpdatePostUseCase();
    mockGetFeedUseCase = MockGetFeedUseCase();

    when(() => mockGetFeedUseCase(any()))
        .thenAnswer((_) async => const Right(<PostItem>[]));

    feedNotifier = FeedNotifier(getFeedUseCase: mockGetFeedUseCase);
    createPostNotifier = CreatePostNotifier(
      createPostUseCase: mockCreatePostUseCase,
      updatePostUseCase: mockUpdatePostUseCase,
      feedNotifier: feedNotifier,
    );
  });

  group('CreatePostNotifier', () {
    test('initial state has default values and canSubmit is false', () {
      expect(createPostNotifier.state.content, '');
      expect(createPostNotifier.state.mediaPaths, isEmpty);
      expect(createPostNotifier.state.visibility, 'public');
      expect(createPostNotifier.state.isSubmitting, isFalse);
      expect(createPostNotifier.state.canSubmit, isFalse);
    });

    test('updateContent updates content and toggles canSubmit', () {
      createPostNotifier.updateContent('Hello world!');
      expect(createPostNotifier.state.content, 'Hello world!');
      expect(createPostNotifier.state.canSubmit, isTrue);

      createPostNotifier.updateContent('   ');
      expect(createPostNotifier.state.canSubmit, isFalse);
    });

    test('addMediaPaths updates mediaPaths and enables canSubmit', () {
      createPostNotifier.addMediaPaths(['/path/to/image1.jpg']);
      expect(createPostNotifier.state.mediaPaths, ['/path/to/image1.jpg']);
      expect(createPostNotifier.state.canSubmit, isTrue);

      createPostNotifier.removeMediaPathAt(0);
      expect(createPostNotifier.state.mediaPaths, isEmpty);
      expect(createPostNotifier.state.canSubmit, isFalse);
    });

    test('updateVisibility sets audience', () {
      createPostNotifier.updateVisibility('friends');
      expect(createPostNotifier.state.visibility, 'friends');

      createPostNotifier.updateVisibility('private');
      expect(createPostNotifier.state.visibility, 'private');
    });

    test('setFeeling and setLocation update feelings and location', () {
      createPostNotifier.setFeeling('excited', '🚀');
      expect(createPostNotifier.state.feeling, 'excited');
      expect(createPostNotifier.state.feelingEmoji, '🚀');

      createPostNotifier.setLocation('Da Nang, Vietnam');
      expect(createPostNotifier.state.location, 'Da Nang, Vietnam');
    });

    test('submitPost successfully publishes post and prepends to feed',
        () async {
      when(() => mockCreatePostUseCase(any()))
          .thenAnswer((_) async => const Right(testPost));

      createPostNotifier.updateContent('Loving the sunny day! ☀️');
      final result = await createPostNotifier.submitPost();

      expect(result, equals(testPost));
      expect(createPostNotifier.state.createdPost, equals(testPost));
      expect(createPostNotifier.state.isSubmitting, isFalse);

      // Verify post was prepended to feed
      expect(feedNotifier.state.posts.first.id, testPost.id);
    });

    test('submitPost handles failure correctly', () async {
      when(() => mockCreatePostUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Network timeout')),
      );

      createPostNotifier.updateContent('Test failing post');
      final result = await createPostNotifier.submitPost();

      expect(result, isNull);
      expect(createPostNotifier.state.isSubmitting, isFalse);
      expect(createPostNotifier.state.errorMessage, 'Network timeout');
    });

    test('initializeForEdit populates post fields and sets edit mode', () {
      const editPost = PostItem(
        id: 'post_edit_1',
        author: PostAuthor(id: 'author_1', username: 'janedoe'),
        content: 'Original content',
        visibility: 'friends',
      );

      createPostNotifier.initializeForEdit(editPost);

      expect(createPostNotifier.state.isEditMode, isTrue);
      expect(createPostNotifier.state.postIdToEdit, 'post_edit_1');
      expect(createPostNotifier.state.content, 'Original content');
      expect(createPostNotifier.state.visibility, 'friends');
    });

    test('submitPost in edit mode calls updatePostUseCase and updates feed',
        () async {
      const originalPost = PostItem(
        id: 'post_edit_1',
        author: PostAuthor(id: 'author_1', username: 'janedoe'),
        content: 'Original text',
      );
      const updatedPost = PostItem(
        id: 'post_edit_1',
        author: PostAuthor(id: 'author_1', username: 'janedoe'),
        content: 'Edited text',
      );

      // Pre-populate feed
      feedNotifier.addPost(originalPost);
      expect(feedNotifier.state.posts.first.content, 'Original text');

      createPostNotifier
        ..initializeForEdit(originalPost)
        ..updateContent('Edited text');

      when(() => mockUpdatePostUseCase(any()))
          .thenAnswer((_) async => const Right(updatedPost));

      final result = await createPostNotifier.submitPost();

      expect(result, equals(updatedPost));
      expect(feedNotifier.state.posts.first.content, 'Edited text');
    });

    test('reset clears state back to defaults', () {
      createPostNotifier
        ..updateContent('Some draft')
        ..updateVisibility('friends')
        ..setFeeling('happy', '😊')
        ..reset();

      expect(createPostNotifier.state.content, '');
      expect(createPostNotifier.state.visibility, 'public');
      expect(createPostNotifier.state.feeling, isNull);
    });
  });
}
