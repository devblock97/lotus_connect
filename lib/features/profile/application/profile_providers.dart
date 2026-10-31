import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/config/app_config.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/contacts/application/contacts_provider.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/profile/application/profile_notifier.dart';
import 'package:lotus_connect/features/profile/application/profile_state.dart';
import 'package:lotus_connect/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lotus_connect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_friends_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_media_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_posts_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/set_close_friend_use_case.dart';
import 'package:lotus_connect/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/upload_cover_usecase.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ProfileRemoteDataSourceImpl(dioClient: dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final getProfilePostsUseCaseProvider = Provider<GetProfilePostsUseCase>((ref) {
  return GetProfilePostsUseCase(ref.watch(profileRepositoryProvider));
});

final getProfileMediaUseCaseProvider = Provider<GetProfileMediaUseCase>((ref) {
  return GetProfileMediaUseCase(ref.watch(profileRepositoryProvider));
});

final getProfileFriendsUseCaseProvider =
    Provider<GetProfileFriendsUseCase>((ref) {
  return GetProfileFriendsUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  return UploadAvatarUseCase(ref.watch(profileRepositoryProvider));
});

final uploadCoverUseCaseProvider = Provider<UploadCoverUseCase>((ref) {
  return UploadCoverUseCase(ref.watch(profileRepositoryProvider));
});

final setCloseFriendUseCaseProvider = Provider<SetCloseFriendUseCase>((ref) {
  return SetCloseFriendUseCase(
    repository: ref.watch(profileRepositoryProvider),
  );
});

/// Provider for the currently authenticated user's own profile (`me`).
final myProfileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final settings = ref.watch(
    settingsNotifierProvider.select(
      (s) => (
        userId: s.settings.userId,
        serverHost: s.settings.serverHost,
      ),
    ),
  );
  final effectiveHost = settings.serverHost.isNotEmpty
      ? settings.serverHost
      : AppConfig.defaultServerHost;

  final notifier = ProfileNotifier(
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    getProfilePostsUseCase: ref.watch(getProfilePostsUseCaseProvider),
    getProfileMediaUseCase: ref.watch(getProfileMediaUseCaseProvider),
    getProfileFriendsUseCase: ref.watch(getProfileFriendsUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
    uploadAvatarUseCase: ref.watch(uploadAvatarUseCaseProvider),
    uploadCoverUseCase: ref.watch(uploadCoverUseCaseProvider),
    deletePostUseCase: ref.watch(deletePostUseCaseProvider),
    setCloseFriendUseCase: ref.watch(setCloseFriendUseCaseProvider),
    targetUserId: 'me',
    serverHost: effectiveHost,
    currentUserId: settings.userId,
    onSelfProfileUpdated: (updatedProfile) {
      final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
      final currentSettings = ref.read(settingsNotifierProvider).settings;
      final nextFullName = updatedProfile.fullName ?? currentSettings.fullName;
      final nextAvatarUrl =
          updatedProfile.avatarUrl ?? currentSettings.avatarUrl;
      final nextUsername = updatedProfile.username.isNotEmpty
          ? updatedProfile.username
          : currentSettings.username;
      final nextEmail = updatedProfile.email.isNotEmpty
          ? updatedProfile.email
          : currentSettings.email;

      if (nextFullName != currentSettings.fullName ||
          nextAvatarUrl != currentSettings.avatarUrl ||
          nextUsername != currentSettings.username ||
          nextEmail != currentSettings.email) {
        unawaited(
          settingsNotifier.updateSettings(
            currentSettings.copyWith(
              fullName: nextFullName,
              avatarUrl: nextAvatarUrl,
              username: nextUsername,
              email: nextEmail,
            ),
          ),
        );
      }
    },
  );

  unawaited(notifier.loadAll());
  return notifier;
});

/// Family provider for viewing any user's profile by UUID or `@username`.
/// Pass `'me'` or empty string for own profile, `@username` for username
/// lookup, or a user UUID for ID lookup.
final userProfileNotifierProvider = StateNotifierProvider.autoDispose
    .family<ProfileNotifier, ProfileState, String>((ref, identifier) {
  final settings = ref.watch(
    settingsNotifierProvider.select(
      (s) => (
        userId: s.settings.userId,
        serverHost: s.settings.serverHost,
      ),
    ),
  );
  final effectiveHost = settings.serverHost.isNotEmpty
      ? settings.serverHost
      : AppConfig.defaultServerHost;

  final isUsername = identifier.startsWith('@');
  final targetUsername = isUsername ? identifier.substring(1) : null;
  final targetUserId =
      isUsername ? null : (identifier.isEmpty ? 'me' : identifier);

  final notifier = ProfileNotifier(
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    getProfilePostsUseCase: ref.watch(getProfilePostsUseCaseProvider),
    getProfileMediaUseCase: ref.watch(getProfileMediaUseCaseProvider),
    getProfileFriendsUseCase: ref.watch(getProfileFriendsUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
    uploadAvatarUseCase: ref.watch(uploadAvatarUseCaseProvider),
    uploadCoverUseCase: ref.watch(uploadCoverUseCaseProvider),
    deletePostUseCase: ref.watch(deletePostUseCaseProvider),
    sendFriendRequestUseCase: ref.watch(sendFriendRequestUseCaseProvider),
    acceptFriendRequestUseCase: ref.watch(acceptFriendRequestUseCaseProvider),
    rejectFriendRequestUseCase: ref.watch(rejectFriendRequestUseCaseProvider),
    deleteFriendUseCase: ref.watch(deleteFriendUseCaseProvider),
    setCloseFriendUseCase: ref.watch(setCloseFriendUseCaseProvider),
    targetUserId: targetUserId,
    targetUsername: targetUsername,
    serverHost: effectiveHost,
    currentUserId: settings.userId,
  );

  unawaited(notifier.loadAll());
  return notifier;
});
