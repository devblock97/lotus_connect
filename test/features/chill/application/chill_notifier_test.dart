import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chill/chill.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:mocktail/mocktail.dart';

class MockGetChillFeedUseCase extends Mock implements GetChillFeedUseCase {}

class MockToggleLikeChillUseCase extends Mock
    implements ToggleLikeChillUseCase {}

class MockToggleSaveChillUseCase extends Mock
    implements ToggleSaveChillUseCase {}

class MockShareChillUseCase extends Mock implements ShareChillUseCase {}

class MockRecordChillViewUseCase extends Mock
    implements RecordChillViewUseCase {}

void main() {
  late MockGetChillFeedUseCase mockGetChillFeedUseCase;
  late MockToggleLikeChillUseCase mockToggleLikeChillUseCase;
  late MockToggleSaveChillUseCase mockToggleSaveChillUseCase;
  late MockShareChillUseCase mockShareChillUseCase;
  late MockRecordChillViewUseCase mockRecordChillViewUseCase;
  late ChillNotifier notifier;

  final testChill = ChillItem(
    id: 'chill_1',
    author: const PostAuthor(id: 'author_1', username: 'johndoe'),
    videoUrl: 'http://localhost:8080/uploads/video1.mp4',
    createdAt: DateTime(2026, 11, 4),
    caption: 'Test Chill',
    likeCount: 10,
    commentCount: 2,
    shareCount: 1,
    viewCount: 100,
  );

  setUpAll(() {
    registerFallbackValue(const GetChillFeedParams());
    registerFallbackValue(
      const ToggleLikeChillParams(chillId: '', isLiked: true),
    );
    registerFallbackValue(
      const ToggleSaveChillParams(chillId: '', isSaved: true),
    );
    registerFallbackValue(const ShareChillParams(chillId: ''));
    registerFallbackValue(const RecordChillViewParams(chillId: ''));
  });

  setUp(() {
    mockGetChillFeedUseCase = MockGetChillFeedUseCase();
    mockToggleLikeChillUseCase = MockToggleLikeChillUseCase();
    mockToggleSaveChillUseCase = MockToggleSaveChillUseCase();
    mockShareChillUseCase = MockShareChillUseCase();
    mockRecordChillViewUseCase = MockRecordChillViewUseCase();

    notifier = ChillNotifier(
      getChillFeedUseCase: mockGetChillFeedUseCase,
      toggleLikeChillUseCase: mockToggleLikeChillUseCase,
      toggleSaveChillUseCase: mockToggleSaveChillUseCase,
      shareChillUseCase: mockShareChillUseCase,
      recordChillViewUseCase: mockRecordChillViewUseCase,
    );
  });

  group('ChillNotifier Tests', () {
    test('getChill loads feed and updates status to success', () async {
      when(() => mockGetChillFeedUseCase(any()))
          .thenAnswer((_) async => Right([testChill]));

      await notifier.getChill();

      expect(notifier.state.status, ChillStatus.success);
      expect(notifier.state.chills.length, 1);
      expect(notifier.state.chills.first.id, 'chill_1');
      expect(notifier.state.cursor, 'chill_1');
    });

    test('reactions performs optimistic like update and keeps chills list',
        () async {
      notifier.setInitialChills([testChill]);

      when(() => mockToggleLikeChillUseCase(any()))
          .thenAnswer((_) async => const Right(true));

      await notifier.reactions('chill_1', true);

      expect(notifier.state.status, ChillStatus.reactionSuccess);
      expect(notifier.state.chills.first.userHasLiked, isTrue);
      expect(notifier.state.chills.first.likeCount, 11);
    });

    test('reactions reverts optimistic update when API fails', () async {
      notifier.setInitialChills([testChill]);

      when(() => mockToggleLikeChillUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Reaction failed')),
      );

      await notifier.reactions('chill_1', true);

      expect(notifier.state.status, ChillStatus.reactionFailure);
      expect(notifier.state.chills.first.userHasLiked, isFalse);
      expect(notifier.state.chills.first.likeCount, 10);
    });

    test('shareChill updates shareCount from backend response', () async {
      notifier.setInitialChills([testChill]);
      final sharedChill = testChill.copyWith(shareCount: 2);

      when(() => mockShareChillUseCase(any()))
          .thenAnswer((_) async => Right(sharedChill));

      await notifier.shareChill('chill_1');

      expect(notifier.state.status, ChillStatus.shareSuccess);
      expect(notifier.state.chills.first.shareCount, 2);
    });

    test('recordView updates viewCount from ChillViewResult', () async {
      notifier.setInitialChills([testChill]);

      when(() => mockRecordChillViewUseCase(any())).thenAnswer(
        (_) async => const Right(
          ChillViewResult(
            postId: 'chill_1',
            viewCount: 101,
            watchTimeSeconds: 10,
            isCompleted: true,
          ),
        ),
      );

      await notifier.recordView(
        'chill_1',
        watchTimeSeconds: 10,
        isCompleted: true,
      );

      expect(notifier.state.chills.first.viewCount, 101);
    });
  });
}
