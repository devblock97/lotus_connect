import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/home/application/feed_playback_coordinator.dart';

void main() {
  group('FeedPlaybackCoordinator Tests', () {
    test('initial state has no active post and is globally muted', () {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: Duration.zero,
      );

      expect(coordinator.state.activePostId, isNull);
      expect(coordinator.state.isGloballyMuted, isTrue);
      expect(coordinator.state.userPausedPostIds, isEmpty);
    });

    test('auto-plays post when visibility is >= 50%', () {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: Duration.zero,
      )..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.55,
          distanceToCenter: 20,
        );

      expect(coordinator.state.activePostId, equals('post_1'));
    });

    test('does not auto-play post when visibility is < 50%', () {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: Duration.zero,
      )..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.45,
          distanceToCenter: 10,
        );

      expect(coordinator.state.activePostId, isNull);
    });

    test('post closest to vertical screen center wins', () {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: Duration.zero,
      )
        ..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.60,
          distanceToCenter: 120,
        )
        ..reportVisibility(
          postId: 'post_2',
          visibleFraction: 0.70,
          distanceToCenter: 15,
        );

      expect(coordinator.state.activePostId, equals('post_2'));
    });

    test('immediately auto-pauses when active post visibility drops below 40%',
        () {
      final coordinator = FeedPlaybackCoordinator()
        ..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.80,
          distanceToCenter: 5,
        )
        ..resume();

      expect(coordinator.state.activePostId, equals('post_1'));

      // Scrolled out: drops below 40% (0.35)
      // Should immediately pause WITHOUT waiting for debounce
      coordinator.reportVisibility(
        postId: 'post_1',
        visibleFraction: 0.35,
        distanceToCenter: 300,
      );

      expect(coordinator.state.activePostId, isNull);
    });

    test('debounces rapid scroll flings', () async {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: const Duration(milliseconds: 100),
      )
        ..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.6,
          distanceToCenter: 50,
        )
        ..reportVisibility(
          postId: 'post_2',
          visibleFraction: 0.7,
          distanceToCenter: 40,
        )
        ..reportVisibility(
          postId: 'post_3',
          visibleFraction: 0.9,
          distanceToCenter: 10,
        );

      // Before debounce duration expires, active post should still be null
      expect(coordinator.state.activePostId, isNull);

      // Wait for debounce duration
      await Future<void>.delayed(const Duration(milliseconds: 120));

      // Settles on best candidate (post_3)
      expect(coordinator.state.activePostId, equals('post_3'));
    });

    test('toggles global mute state across all feed videos', () {
      final coordinator = FeedPlaybackCoordinator();

      expect(coordinator.state.isGloballyMuted, isTrue);

      coordinator.toggleMute();
      expect(coordinator.state.isGloballyMuted, isFalse);

      coordinator.toggleMute();
      expect(coordinator.state.isGloballyMuted, isTrue);

      coordinator.setGloballyMuted(isMuted: false);
      expect(coordinator.state.isGloballyMuted, isFalse);
    });

    test('user tap pause adds to userPausedPostIds and stops auto-play', () {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: Duration.zero,
      )..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.8,
          distanceToCenter: 10,
        );
      expect(coordinator.state.activePostId, equals('post_1'));

      // User taps pause
      coordinator.togglePlayPause('post_1');
      expect(coordinator.state.activePostId, isNull);
      expect(coordinator.state.userPausedPostIds, contains('post_1'));

      // Subsequent visibility reports shouldn't auto-resume while user-paused
      coordinator.reportVisibility(
        postId: 'post_1',
        visibleFraction: 0.9,
        distanceToCenter: 5,
      );
      expect(coordinator.state.activePostId, isNull);

      // User taps play again -> resumes
      coordinator.togglePlayPause('post_1');
      expect(coordinator.state.activePostId, equals('post_1'));
      expect(coordinator.state.userPausedPostIds, isNot(contains('post_1')));
    });

    test('reportDisposed clears active post if unmounted', () {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: Duration.zero,
      )..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.8,
          distanceToCenter: 10,
        );
      expect(coordinator.state.activePostId, equals('post_1'));

      coordinator.reportDisposed('post_1');
      expect(coordinator.state.activePostId, isNull);
    });

    test('pauseAll clears active post', () {
      final coordinator = FeedPlaybackCoordinator(
        debounceDuration: Duration.zero,
      )..reportVisibility(
          postId: 'post_1',
          visibleFraction: 0.8,
          distanceToCenter: 10,
        );
      expect(coordinator.state.activePostId, equals('post_1'));

      coordinator.pauseAll();
      expect(coordinator.state.activePostId, isNull);
    });
  });
}
