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
import 'package:lotus_connect/features/profile/presentation/views/edit_profile_screen.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/features/profile/presentation/widgets/profile_friends_preview.dart';
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
    bio: 'Lead Architect',
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
    isCloseFriend: true,
    friendshipStatus: 'pending',
    friendshipSenderId: 'user-peer',
    postCount: 1,
    friendCount: 4,
  );

  final samplePost = PostItem(
    id: 'post-101',
    author: const PostAuthor(
      id: 'user-self',
      username: 'thong_nguyen',
      fullName: 'Thong Nguyen',
    ),
    content: 'Testing profile localization',
    createdAt: DateTime.utc(2026, 11),
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
    ).thenAnswer((_) async => const Right(<User>[]));
    when(
      () => mockRepo.getUserMedia(
        userId: any<String?>(named: 'userId'),
        mediaType: any<String?>(named: 'mediaType'),
        cursor: any<String?>(named: 'cursor'),
        limit: any<int?>(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Right(<ProfileMediaItem>[]));

    return ProfileNotifier(
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
  }

  Widget createLocalizedApp({
    required Widget home,
    required Locale locale,
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('vi'),
          Locale('ja'),
          Locale('zh'),
        ],
        home: home,
      ),
    );
  }

  testWidgets('renders ProfileScreen in Vietnamese', (tester) async {
    final notifier = buildTestNotifier(profile: selfProfile);
    await notifier.loadAll();

    await tester.pumpWidget(
      createLocalizedApp(
        home: const ProfileScreen(),
        locale: const Locale('vi'),
        overrides: [
          myProfileNotifierProvider.overrideWith((ref) => notifier),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Vietnamese tabs and labels
    expect(find.text('Bài viết'), findsWidgets);
    expect(find.text('Ảnh'), findsWidgets);
    expect(find.text('Video'), findsWidgets);
    expect(find.text('Giới thiệu'), findsOneWidget);
    expect(find.text('Thêm vào tin'), findsOneWidget);
    expect(find.text('Chi tiết'), findsOneWidget);
    expect(find.text('Chỉnh sửa chi tiết công khai'), findsOneWidget);
  });

  testWidgets('renders ProfileScreen in Japanese', (tester) async {
    final notifier = buildTestNotifier(profile: selfProfile);
    await notifier.loadAll();

    await tester.pumpWidget(
      createLocalizedApp(
        home: const ProfileScreen(),
        locale: const Locale('ja'),
        overrides: [
          myProfileNotifierProvider.overrideWith((ref) => notifier),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Japanese tabs and labels
    expect(find.text('投稿'), findsWidgets);
    expect(find.text('写真'), findsWidgets);
    expect(find.text('動画'), findsWidgets);
    expect(find.text('基本データ'), findsOneWidget);
    expect(find.text('ストーリーズに追加'), findsOneWidget);
    expect(find.text('詳細'), findsOneWidget);
  });

  testWidgets('renders visitor ProfileScreen with respond button in Chinese',
      (tester) async {
    final notifier = buildTestNotifier(
      profile: peerProfile,
      targetUserId: 'user-peer',
    );
    await notifier.loadAll();

    await tester.pumpWidget(
      createLocalizedApp(
        home: const ProfileScreen(userId: 'user-peer'),
        locale: const Locale('zh'),
        overrides: [
          userProfileNotifierProvider('user-peer')
              .overrideWith((ref) => notifier),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Close friend and respond button in Chinese
    expect(find.text('密友'), findsOneWidget);
    expect(find.text('回应'), findsOneWidget);
  });

  testWidgets('renders EditProfileScreen in Vietnamese', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final notifier = buildTestNotifier(profile: selfProfile);
    await notifier.loadAll();

    await tester.pumpWidget(
      createLocalizedApp(
        home: const EditProfileScreen(initialProfile: selfProfile),
        locale: const Locale('vi'),
        overrides: [
          myProfileNotifierProvider.overrideWith((ref) => notifier),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ảnh đại diện'), findsOneWidget);
    expect(find.text('Ảnh bìa'), findsOneWidget);
    expect(find.text('Tiểu sử'), findsOneWidget);
    expect(find.text('Chi tiết'), findsOneWidget);
    expect(find.text('Lưu thay đổi'), findsOneWidget);
  });

  testWidgets(
      'renders ProfileFriendsPreview with see all friends button in Japanese',
      (tester) async {
    await tester.pumpWidget(
      createLocalizedApp(
        home: Scaffold(
          body: ProfileFriendsPreview(
            friends: const [
              User(
                id: 'u-1',
                username: 'taro',
                email: 'taro@lotus.io',
                fullName: 'Taro Yamada',
              ),
            ],
            totalFriendCount: 1,
            isSelf: true,
            onFindFriendsTap: () {},
          ),
        ),
        locale: const Locale('ja'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('すべての友達を見る'), findsOneWidget);
    expect(find.text('友達を検索'), findsOneWidget);
  });
}
