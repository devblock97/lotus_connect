import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/accept_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/delete_friend_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/reject_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/send_friend_request_usecase.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/profile/application/profile_notifier.dart';
import 'package:lotus_connect/features/profile/application/profile_state.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/update_profile_params.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_friends_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_media_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_posts_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/set_close_friend_use_case.dart';
import 'package:lotus_connect/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/upload_cover_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockSendFriendRequestUseCase extends Mock
    implements SendFriendRequestUseCase {}

class _MockAcceptFriendRequestUseCase extends Mock
    implements AcceptFriendRequestUseCase {}

class _MockRejectFriendRequestUseCase extends Mock
    implements RejectFriendRequestUseCase {}

class _MockDeleteFriendUseCase extends Mock implements DeleteFriendUseCase {}

void main() {
  late _MockProfileRepository mockRepo;
  late _MockSendFriendRequestUseCase mockSendFriendRequest;
  late _MockAcceptFriendRequestUseCase mockAcceptFriendRequest;
  late _MockRejectFriendRequestUseCase mockRejectFriendRequest;
  late _MockDeleteFriendUseCase mockDeleteFriend;
  late ProfileNotifier notifier;

  const testProfile = UserProfile(
    id: 'user-1',
    username: 'lotus_dev',
    email: 'lotus@example.com',
    fullName: 'Lotus Developer',
    bio: 'Building Lotus Connect',
    location: 'Ho Chi Minh City',
    website: 'https://lotus.dev',
    avatarUrl: 'http://localhost:9000/avatars/u1.jpg',
    coverUrl: 'http://localhost:9000/covers/u1.jpg',
    isSelf: true,
    postCount: 2,
    mediaCount: 1,
    friendCount: 1,
  );

  final testPost = PostItem(
    id: 'post-1',
    author: const PostAuthor(
      id: 'user-1',
      username: 'lotus_dev',
      fullName: 'Lotus Developer',
    ),
    content: 'Hello from profile timeline!',
    createdAt: DateTime.utc(2026, 10, 30),
    likeCount: 5,
    commentCount: 2,
  );

  final testMedia = ProfileMediaItem(
    postId: 'post-1',
    author: const PostAuthor(
      id: 'user-1',
      username: 'lotus_dev',
    ),
    url: 'http://localhost:9000/media/img1.jpg',
    createdAt: DateTime.utc(2026, 10, 30),
  );

  const testFriend = User(
    id: 'friend-1',
    username: 'alice',
    email: 'alice@example.com',
    fullName: 'Alice Nguyen',
  );

  setUpAll(() {
    registerFallbackValue(const UpdateProfileParams());
    registerFallbackValue(const SendFriendRequestParam(username: ''));
    registerFallbackValue(const AcceptFriendRequestParam(targetId: ''));
    registerFallbackValue(const RejectFriendRequestParam(targetId: ''));
    registerFallbackValue(const DeleteFriendParam(friendId: ''));
  });

  setUp(() {
    mockRepo = _MockProfileRepository();
    mockSendFriendRequest = _MockSendFriendRequestUseCase();
    mockAcceptFriendRequest = _MockAcceptFriendRequestUseCase();
    mockRejectFriendRequest = _MockRejectFriendRequestUseCase();
    mockDeleteFriend = _MockDeleteFriendUseCase();

    notifier = ProfileNotifier(
      getProfileUseCase: GetProfileUseCase(mockRepo),
      getProfilePostsUseCase: GetProfilePostsUseCase(mockRepo),
      getProfileMediaUseCase: GetProfileMediaUseCase(mockRepo),
      getProfileFriendsUseCase: GetProfileFriendsUseCase(mockRepo),
      updateProfileUseCase: UpdateProfileUseCase(mockRepo),
      uploadAvatarUseCase: UploadAvatarUseCase(mockRepo),
      uploadCoverUseCase: UploadCoverUseCase(mockRepo),
      setCloseFriendUseCase: SetCloseFriendUseCase(repository: mockRepo),
      sendFriendRequestUseCase: mockSendFriendRequest,
      acceptFriendRequestUseCase: mockAcceptFriendRequest,
      rejectFriendRequestUseCase: mockRejectFriendRequest,
      deleteFriendUseCase: mockDeleteFriend,
      currentUserId: 'user-1',
    );
  });

  group('UserProfile & ProfileMediaItem Serialization', () {
    test('parses UserProfileResponse camelCase JSON accurately', () {
      final json = <String, dynamic>{
        'id': 'u-123',
        'username': 'john_doe',
        'fullName': 'John Doe',
        'email': 'john@lotus.io',
        'avatarUrl': 'https://cdn.lotus.io/a.png',
        'coverUrl': 'https://cdn.lotus.io/c.png',
        'bio': 'Rust & Flutter Engineer',
        'website': 'https://johndoe.dev',
        'location': 'Hanoi, Vietnam',
        'isSelf': false,
        'friendshipStatus': 'pending',
        'friendshipSenderId': 'me-id',
        'isCloseFriend': true,
        'postCount': 12,
        'mediaCount': 8,
        'friendCount': 45,
        'stats': {
          'postCount': 12,
          'mediaCount': 8,
          'friendCount': 45,
        },
        'createdAt': '2026-10-01T10:00:00Z',
      };

      final parsed = UserProfile.fromJson(json);
      expect(parsed.id, 'u-123');
      expect(parsed.displayName, 'John Doe');
      expect(parsed.bio, 'Rust & Flutter Engineer');
      expect(parsed.location, 'Hanoi, Vietnam');
      expect(parsed.website, 'https://johndoe.dev');
      expect(parsed.isPendingRequest, isTrue);
      expect(parsed.didSendFriendRequest('me-id'), isTrue);
      expect(parsed.isCloseFriend, isTrue);
      expect(parsed.postCount, 12);
      expect(parsed.mediaCount, 8);
      expect(parsed.friendCount, 45);
    });

    test('parses ProfileMediaItemResponse JSON and converts to PostItem', () {
      final json = <String, dynamic>{
        'postId': 'p-1',
        'author': {
          'id': 'u-1',
          'username': 'alice',
          'fullName': 'Alice',
        },
        'mediaIndex': 0,
        'url': 'https://cdn.lotus.io/video.mp4',
        'thumbnailUrl': 'https://cdn.lotus.io/thumb.jpg',
        'mediaType': 'video',
        'duration': 65,
        'likeCount': 10,
        'commentCount': 3,
        'userHasLiked': true,
        'createdAt': '2026-10-30T08:00:00Z',
      };

      final item = ProfileMediaItem.fromJson(json);
      expect(item.isVideo, isTrue);
      expect(item.formattedDuration, '1:05');
      final post = item.toPostItem();
      expect(post.id, 'p-1');
      expect(post.likesCount, 10);
      expect(post.isLiked, isTrue);
    });
  });

  group('ProfileNotifier', () {
    test('loadAll loads profile, posts, friends, photos, and videos', () async {
      when(() => mockRepo.getMyProfile())
          .thenAnswer((_) async => const Right(testProfile));
      when(
        () => mockRepo.getUserPosts(
          userId: any<String?>(named: 'userId'),
          filter: any<String?>(named: 'filter'),
          cursor: any<String?>(named: 'cursor'),
          limit: any<int?>(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right([testPost]));
      when(
        () => mockRepo.getUserFriends(
          userId: any<String?>(named: 'userId'),
        ),
      ).thenAnswer((_) async => const Right([testFriend]));
      when(
        () => mockRepo.getUserMedia(
          userId: any<String?>(named: 'userId'),
          mediaType: 'image',
          cursor: any<String?>(named: 'cursor'),
          limit: any<int?>(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right([testMedia]));
      when(
        () => mockRepo.getUserMedia(
          userId: any<String?>(named: 'userId'),
          mediaType: 'video',
          cursor: any<String?>(named: 'cursor'),
          limit: any<int?>(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right(<ProfileMediaItem>[]));

      await notifier.loadAll();

      expect(notifier.state.profile, testProfile);
      expect(notifier.state.posts, [testPost]);
      expect(notifier.state.friends, [testFriend]);
      expect(notifier.state.photos, [testMedia]);
      expect(notifier.state.videos, isEmpty);
    });

    test('updateProfile updates state and invokes onSelfProfileUpdated',
        () async {
      final updated = testProfile.copyWith(
        fullName: 'Updated Lotus',
        bio: 'New bio',
      );
      when(() => mockRepo.updateMyProfile(any()))
          .thenAnswer((_) async => Right(updated));

      const params = UpdateProfileParams(
        fullName: 'Updated Lotus',
        bio: 'New bio',
      );
      final ok = await notifier.updateProfile(params);

      expect(ok, isTrue);
      expect(notifier.state.profile?.fullName, 'Updated Lotus');
      expect(notifier.state.profile?.bio, 'New bio');
    });

    test('setPostFilter reloads posts with selected filter', () async {
      when(
        () => mockRepo.getUserPosts(
          userId: any<String?>(named: 'userId'),
          filter: 'video',
          cursor: any<String?>(named: 'cursor'),
          limit: any<int?>(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right([testPost]));

      await notifier.setPostFilter(ProfilePostFilter.video);

      expect(notifier.state.postFilter, ProfilePostFilter.video);
      verify(
        () => mockRepo.getUserPosts(
          userId: any<String?>(named: 'userId'),
          filter: 'video',
          cursor: any<String?>(named: 'cursor'),
          limit: any<int?>(named: 'limit'),
        ),
      ).called(1);
    });

    test('loadProfile failure sets errorMessage', () async {
      when(() => mockRepo.getMyProfile()).thenAnswer(
        (_) async => const Left(NetworkFailure('Network error')),
      );

      await notifier.loadProfile();

      expect(notifier.state.errorMessage, 'Network error');
      expect(notifier.state.isLoadingProfile, isFalse);
    });
  });
}
