import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/profile/application/profile_notifier.dart';
import 'package:lotus_connect/features/profile/application/profile_providers.dart';
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
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository mockRepo;

  const selfProfile = UserProfile(
    id: 'user-self',
    username: 'thong_nguyen',
    email: 'thong@lotus.io',
    fullName: 'Thong Nguyen',
    bio: 'Lead Architect at Lotus Connect',
    location: 'Ho Chi Minh City',
    website: 'https://lotusconnect.io',
    isSelf: true,
    postCount: 5,
    mediaCount: 3,
    friendCount: 2,
  );

  const peerProfile = UserProfile(
    id: 'user-peer',
    username: 'minh_tran',
    email: 'minh@lotus.io',
    fullName: 'Minh Tran',
    bio: 'Product Designer',
    location: 'Da Nang',
    friendshipStatus: 'accepted',
    isCloseFriend: true,
    postCount: 4,
    mediaCount: 2,
    friendCount: 10,
  );

  const sampleFriends = [
    User(
      id: 'f-1',
      username: 'alice',
      email: 'alice@lotus.io',
      fullName: 'Alice Wonderland',
    ),
    User(
      id: 'f-2',
      username: 'bob',
      email: 'bob@lotus.io',
      fullName: 'Bob Builder',
    ),
  ];

  final samplePost = PostItem(
    id: 'post-101',
    author: const PostAuthor(
      id: 'user-self',
      username: 'thong_nguyen',
      fullName: 'Thong Nguyen',
    ),
    content: 'Launching the new Facebook-style profile!',
    createdAt: DateTime.utc(2026, 10, 30),
    likeCount: 14,
    commentCount: 3,
  );

  setUpAll(() {
    registerFallbackValue(const UpdateProfileParams());
  });

  setUp(() {
    mockRepo = _MockProfileRepository();
  });

  ProfileNotifier buildTestNotifier({
    required UserProfile profile,
    String? targetUserId,
  }) {
    when(() => mockRepo.getMyProfile()).thenAnswer((_) async => Right(profile));
    when(() => mockRepo.getUserProfile(any()))
        .thenAnswer((_) async => Right(profile));
    when(
      () => mockRepo.getUserPosts(
        userId: any<String?>(named: 'userId'),
        filter: any<String?>(named: 'filter'),
        cursor: any<String?>(named: 'cursor'),
        limit: any<int?>(named: 'limit'),
      ),
    ).thenAnswer((_) async => Right([samplePost]));
    when(
      () => mockRepo.getUserFriends(
        userId: any<String?>(named: 'userId'),
      ),
    ).thenAnswer((_) async => const Right(sampleFriends));
    when(
      () => mockRepo.getUserMedia(
        userId: any<String?>(named: 'userId'),
        mediaType: any<String?>(named: 'mediaType'),
        cursor: any<String?>(named: 'cursor'),
        limit: any<int?>(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Right(<ProfileMediaItem>[]));

    final notifier = ProfileNotifier(
      getProfileUseCase: GetProfileUseCase(mockRepo),
      getProfilePostsUseCase: GetProfilePostsUseCase(mockRepo),
      getProfileMediaUseCase: GetProfileMediaUseCase(mockRepo),
      getProfileFriendsUseCase: GetProfileFriendsUseCase(mockRepo),
      updateProfileUseCase: UpdateProfileUseCase(mockRepo),
      uploadAvatarUseCase: UploadAvatarUseCase(mockRepo),
      uploadCoverUseCase: UploadCoverUseCase(mockRepo),
      setCloseFriendUseCase: SetCloseFriendUseCase(repository: mockRepo),
      targetUserId: targetUserId,
    );
    return notifier;
  }

  testWidgets(
      'renders self ProfileScreen with header, intro, friends, and tabs',
      (tester) async {
    final notifier = buildTestNotifier(profile: selfProfile);
    await notifier.loadAll();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thong Nguyen'), findsWidgets);
    expect(find.text('@thong_nguyen'), findsOneWidget);
    expect(find.text('Lead Architect at Lotus Connect'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('https://lotusconnect.io'), findsOneWidget);

    // Scroll down to bring Friends preview into viewport
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Alice Wonderland'), findsOneWidget);

    // Scroll back up and switch to About tab
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('thong@lotus.io'), findsOneWidget);
    expect(find.text('Ho Chi Minh City'), findsOneWidget);
  });

  testWidgets('renders visitor ProfileScreen with friend & close-friend state',
      (tester) async {
    final notifier = buildTestNotifier(
      profile: peerProfile,
      targetUserId: 'user-peer',
    );
    await notifier.loadAll();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileNotifierProvider('user-peer')
              .overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: ProfileScreen(userId: 'user-peer'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Minh Tran'), findsWidgets);
    expect(find.text('@minh_tran'), findsOneWidget);
    expect(find.text('Product Designer'), findsOneWidget);
  });
}
