import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/calls/data/models/call_request.dart';
import 'package:lotus_connect/features/calls/presentation/views/calls_screen.dart';
import 'package:lotus_connect/features/chat/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/application/presence_notifier.dart';
import 'package:lotus_connect/features/chat/presentation/views/chat_screen.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/presentation/view/create_post_screen.dart';
import 'package:lotus_connect/features/home/presentation/view/create_story_screen.dart';
import 'package:lotus_connect/features/home/presentation/widgets/create_post_bar.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card_skeleton.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_comments_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_options_sheet.dart';
import 'package:lotus_connect/features/profile/application/profile_notifier.dart';
import 'package:lotus_connect/features/profile/application/profile_providers.dart';
import 'package:lotus_connect/features/profile/application/profile_state.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/presentation/views/edit_profile_screen.dart';
import 'package:lotus_connect/features/profile/presentation/widgets/profile_friends_preview.dart';
import 'package:lotus_connect/features/profile/presentation/widgets/profile_header.dart';
import 'package:lotus_connect/features/profile/presentation/widgets/profile_intro_section.dart';
import 'package:lotus_connect/features/profile/presentation/widgets/profile_media_grid.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/presentation/views/settings_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({
    super.key,
    this.userId,
    this.initialUsername,
  });

  final String? userId;

  final String? initialUsername;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool get _isExplicitSelf =>
      widget.userId == null || widget.userId!.isEmpty || widget.userId == 'me';

  ProfileState _watchState() {
    final currentUserId = ref.watch(
      settingsNotifierProvider.select((s) => s.settings.userId),
    );
    if (_isExplicitSelf ||
        (currentUserId.isNotEmpty && widget.userId == currentUserId)) {
      return ref.watch(myProfileNotifierProvider);
    }
    return ref.watch(userProfileNotifierProvider(widget.userId!));
  }

  ProfileNotifier _readNotifier() {
    final currentUserId = ref.read(settingsNotifierProvider).settings.userId;
    if (_isExplicitSelf ||
        (currentUserId.isNotEmpty && widget.userId == currentUserId)) {
      return ref.read(myProfileNotifierProvider.notifier);
    }
    return ref.read(userProfileNotifierProvider(widget.userId!).notifier);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final currScroll = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (currScroll >= maxScroll * 0.8) {
      final notifier = _readNotifier();
      final activeTab = _ReadActiveTabHelper.read(
        ref,
        isExplicitSelf: _isExplicitSelf,
        userId: widget.userId,
      );
      switch (activeTab) {
        case ProfileTab.posts:
          notifier.loadMorePosts();
        case ProfileTab.photos:
          notifier.loadMorePhotos();
        case ProfileTab.videos:
          notifier.loadMoreVideos();
        case ProfileTab.about:
          break;
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 88,
    );
    if (picked == null || !mounted) return;

    final success = await _readNotifier().uploadAvatar(picked.path);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Profile picture updated' : 'Failed to upload avatar',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickAndUploadCover() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 88,
    );
    if (picked == null || !mounted) return;

    final success = await _readNotifier().uploadCover(picked.path);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Cover photo updated' : 'Failed to upload cover photo',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialProfile: profile),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _openCreateStory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const CreateStoryScreen(),
      ),
    );
  }

  Future<void> _openCreatePost() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const CreatePostScreen(),
      ),
    );
    if (mounted) {
      await _readNotifier().refresh();
    }
  }

  void _openUserProfile(String targetUserId, {String? username}) {
    if (targetUserId.isEmpty) return;
    final currentProfileId = _watchState().profile?.id;
    if (currentProfileId == targetUserId) return;

    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userId: targetUserId,
          initialUsername: username,
        ),
      ),
    );
  }

  void _showAllFriendsSheet(ProfileState state) {
    final profile = state.profile;
    if (profile == null) return;
    ProfileFriendsSheet.show(
      context,
      friends: state.friends,
      onFriendTap: (friend) => _openUserProfile(
        friend.id,
        username: friend.username,
      ),
    );
  }

  Future<void> _startPrivateChat(UserProfile profile) async {
    final conversation = await ref
        .read(privateConversationListProvider.notifier)
        .createNewPrivateChat(
          friendId: profile.id,
          title: profile.displayName,
        );
    if (conversation != null && mounted) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      );
    }
  }

  void _startCall(UserProfile profile, {required bool isVideo}) {
    final callRequest = CallRequest(
      recipientId: profile.id,
      isVideo: isVideo,
    );
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CallsScreen(callRequest: callRequest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final sectionDividerColor =
        isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5);
    final loc = AppLocalizations.of(context);

    final state = _watchState();
    final notifier = _readNotifier();
    final settings = ref.watch(settingsNotifierProvider).settings;
    final currentUserId = settings.userId;

    // Build fallback profile for immediate display when viewing own profile
    final profile = state.profile ??
        (_isExplicitSelf && settings.username.isNotEmpty
            ? UserProfile(
                id: settings.userId,
                username: settings.username,
                fullName:
                    settings.fullName.isNotEmpty ? settings.fullName : null,
                email: settings.email,
                avatarUrl:
                    settings.avatarUrl.isNotEmpty ? settings.avatarUrl : null,
                isSelf: true,
              )
            : null);

    final isOnline = profile != null &&
        (ref.watch(presenceProvider)[profile.id]?.isOnline ?? false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          profile?.displayName ??
              (widget.initialUsername != null
                  ? '@${widget.initialUsername}'
                  : (loc?.tabProfile ?? 'Profile')),
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (profile?.isSelf ?? _isExplicitSelf) ...[
            IconButton(
              icon: Icon(
                CupertinoIcons.plus_app,
                color: primaryTextColor,
                size: 23,
              ),
              tooltip: loc?.createPost ?? 'Create post',
              onPressed: _openCreatePost,
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: primaryTextColor,
                size: 22,
              ),
              tooltip: loc?.editProfile ?? 'Edit profile',
              onPressed:
                  profile != null ? () => _openEditProfile(profile) : null,
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: primaryTextColor,
                size: 22,
              ),
              tooltip: loc?.profileSettings ?? 'Settings',
              onPressed: _openSettings,
            ),
          ] else if (profile != null) ...[
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz_rounded, color: primaryTextColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'copy_username') {
                  Clipboard.setData(
                    ClipboardData(text: '@${profile.username}'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied @${profile.username}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (value == 'refresh') {
                  notifier.refresh();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'copy_username',
                  child: Row(
                    children: [
                      const Icon(Icons.alternate_email_rounded, size: 19),
                      const SizedBox(width: 10),
                      Text('Copy @${profile.username}'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 19),
                      SizedBox(width: 10),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: state.isLoadingProfile && profile == null
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? _buildErrorView(context, state.errorMessage, notifier, loc)
              : RefreshIndicator(
                  onRefresh: notifier.refresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Facebook Cover + Avatar + Bio + Action Buttons
                      SliverToBoxAdapter(
                        child: ProfileHeader(
                          profile: profile,
                          currentUserId: currentUserId,
                          isUploadingAvatar: state.isUploadingAvatar,
                          isUploadingCover: state.isUploadingCover,
                          isMutatingFriendship: state.isMutatingFriendship,
                          isOnline: isOnline,
                          onChangeAvatarTap: _pickAndUploadAvatar,
                          onChangeCoverTap: _pickAndUploadCover,
                          onEditProfileTap: () => _openEditProfile(profile),
                          onAddToStoryTap: _openCreateStory,
                          onSettingsTap: _openSettings,
                          onFriendsCountTap: () => _showAllFriendsSheet(state),
                          onPhotosCountTap: () =>
                              notifier.setActiveTab(ProfileTab.photos),
                          onAddFriendTap: () async {
                            final ok = await notifier.sendFriendRequest();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? (loc?.friendRequestSentTo(
                                            profile.username,
                                          ) ??
                                          'Friend request sent')
                                      : (loc?.failedToSendRequest ??
                                          'Failed to send request'),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onAcceptFriendTap: () async {
                            final ok = await notifier.acceptFriendRequest();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? (loc?.friendRequestAccepted ??
                                          'Friend request accepted')
                                      : (loc?.failedToAcceptRequest ??
                                          'Failed to accept request'),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onRejectFriendTap: () async {
                            final ok = await notifier.rejectFriendRequest();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? (loc?.friendRequestRejected ??
                                          'Friend request removed')
                                      : (loc?.failedToRejectRequest ??
                                          'Failed to remove request'),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onUnfriendTap: () async {
                            final ok = await notifier.unfriend();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? (loc?.friendRemoved ?? 'Removed friend')
                                      : (loc?.failedToRemoveFriend ??
                                          'Failed to remove friend'),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onToggleCloseFriendTap: () async {
                            await notifier.toggleCloseFriend();
                          },
                          onMessageTap: () => _startPrivateChat(profile),
                          onVoiceCallTap: () =>
                              _startCall(profile, isVideo: false),
                          onVideoCallTap: () =>
                              _startCall(profile, isVideo: true),
                        ),
                      ),

                      // Thick section divider
                      SliverToBoxAdapter(
                        child: Container(height: 8, color: sectionDividerColor),
                      ),

                      // Facebook Content Tab Selector
                      SliverToBoxAdapter(
                        child: _buildTabSelector(
                          theme: theme,
                          isDark: isDark,
                          activeTab: state.activeTab,
                          onTabSelected: notifier.setActiveTab,
                          loc: loc,
                        ),
                      ),

                      // Active Tab Content
                      ..._buildActiveTabSlivers(
                        context: context,
                        theme: theme,
                        isDark: isDark,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        sectionDividerColor: sectionDividerColor,
                        profile: profile,
                        state: state,
                        notifier: notifier,
                        currentUserId: currentUserId,
                        loc: loc,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTabSelector({
    required ThemeData theme,
    required bool isDark,
    required ProfileTab activeTab,
    required ValueChanged<ProfileTab> onTabSelected,
    required AppLocalizations? loc,
  }) {
    final tabs = <(ProfileTab, String)>[
      (ProfileTab.posts, 'Posts'),
      (ProfileTab.photos, loc?.photo ?? 'Photos'),
      (ProfileTab.videos, loc?.video ?? 'Videos'),
      (ProfileTab.about, 'About'),
    ];

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((item) {
            final (tab, label) = item;
            final isSelected = activeTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onTabSelected(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1877F2).withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1877F2)
                          : (isDark ? Colors.grey.shade300 : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildActiveTabSlivers({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color sectionDividerColor,
    required UserProfile profile,
    required ProfileState state,
    required ProfileNotifier notifier,
    required String currentUserId,
    required AppLocalizations? loc,
  }) {
    switch (state.activeTab) {
      case ProfileTab.posts:
        return _buildPostsTabSlivers(
          context: context,
          theme: theme,
          isDark: isDark,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
          sectionDividerColor: sectionDividerColor,
          profile: profile,
          state: state,
          notifier: notifier,
          currentUserId: currentUserId,
          loc: loc,
        );
      case ProfileTab.photos:
        return [
          SliverToBoxAdapter(
            child: Container(height: 1, color: sectionDividerColor),
          ),
          SliverToBoxAdapter(
            child: ProfileMediaGrid(
              items: state.photos,
              isLoading: state.isLoadingPhotos,
              emptyTitle: 'No photos shared yet',
            ),
          ),
        ];
      case ProfileTab.videos:
        return [
          SliverToBoxAdapter(
            child: Container(height: 1, color: sectionDividerColor),
          ),
          SliverToBoxAdapter(
            child: ProfileMediaGrid(
              items: state.videos,
              isLoading: state.isLoadingVideos,
              emptyTitle: 'No videos shared yet',
              emptyIcon: Icons.videocam_off_outlined,
            ),
          ),
        ];
      case ProfileTab.about:
        return [
          SliverToBoxAdapter(
            child: Container(height: 8, color: sectionDividerColor),
          ),
          SliverToBoxAdapter(
            child: _buildAboutOverviewCard(
              context: context,
              theme: theme,
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              profile: profile,
              loc: loc,
            ),
          ),
        ];
    }
  }

  List<Widget> _buildPostsTabSlivers({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color sectionDividerColor,
    required UserProfile profile,
    required ProfileState state,
    required ProfileNotifier notifier,
    required String currentUserId,
    required AppLocalizations? loc,
  }) {
    return [
      // Details / Intro section
      SliverToBoxAdapter(
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      SliverToBoxAdapter(
        child: ProfileIntroSection(
          profile: profile,
          onEditDetailsTap:
              profile.isSelf ? () => _openEditProfile(profile) : null,
        ),
      ),

      SliverToBoxAdapter(
        child: Container(height: 8, color: sectionDividerColor),
      ),

      // 6-Friend Preview Grid
      SliverToBoxAdapter(
        child: ProfileFriendsPreview(
          friends: state.friends,
          totalFriendCount: profile.friendCount > state.friends.length
              ? profile.friendCount
              : state.friends.length,
          isSelf: profile.isSelf,
          onFindFriendsTap: () => _showAllFriendsSheet(state),
          onSeeAllTap: () => _showAllFriendsSheet(state),
          onFriendTap: (friend) => _openUserProfile(
            friend.id,
            username: friend.username,
          ),
        ),
      ),

      SliverToBoxAdapter(
        child: Container(height: 8, color: sectionDividerColor),
      ),

      // Posts Header + Filter Chips + CreatePostBar (for self)
      SliverToBoxAdapter(
        child: ColoredBox(
          color: theme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    // Post filter pills (All / Media / Videos)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          isSelected: state.postFilter == ProfilePostFilter.all,
                          isDark: isDark,
                          onTap: () =>
                              notifier.setPostFilter(ProfilePostFilter.all),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: loc?.photo ?? 'Media',
                          isSelected:
                              state.postFilter == ProfilePostFilter.media,
                          isDark: isDark,
                          onTap: () =>
                              notifier.setPostFilter(ProfilePostFilter.media),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: loc?.video ?? 'Videos',
                          isSelected:
                              state.postFilter == ProfilePostFilter.video,
                          isDark: isDark,
                          onTap: () =>
                              notifier.setPostFilter(ProfilePostFilter.video),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (profile.isSelf) ...[
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: theme.dividerColor.withValues(alpha: 0.15),
                ),
                const CreatePostBar(),
              ],
            ],
          ),
        ),
      ),

      SliverToBoxAdapter(
        child: Container(height: 8, color: sectionDividerColor),
      ),

      // Timeline Posts List
      if (state.isLoadingPosts && state.posts.isEmpty)
        const SliverPostListSkeleton()
      else if (state.posts.isEmpty)
        SliverToBoxAdapter(
          child: Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              children: [
                Icon(
                  Icons.dynamic_feed_outlined,
                  size: 48,
                  color: secondaryTextColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  loc?.noPostsYet ?? 'No posts yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        )
      else
        SliverList.builder(
          itemCount: state.posts.length + (state.isLoadingMorePosts ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.posts.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final post = state.posts[index];
            final isAuthor = profile.isSelf ||
                (currentUserId.isNotEmpty && currentUserId == post.author.id);

            return ColoredBox(
              color: theme.cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PostCard(
                    post: post,
                    onProfileTap: () => _openUserProfile(
                      post.author.id,
                      username: post.author.username,
                    ),
                    onLikeChanged: (isLiked) {
                      notifier.toggleLike(post.id, isLiked: isLiked);
                    },
                    onSaveChanged: (isSaved) {
                      notifier.toggleSave(post.id, isSaved: isSaved);
                    },
                    onCommentTap: () {
                      PostCommentsSheet.show(context, post: post);
                    },
                    onViewCommentsTap: () {
                      PostCommentsSheet.show(context, post: post);
                    },
                    onMoreOptionsTap: () {
                      PostOptionsSheet.show(
                        context,
                        post: post,
                        isAuthor: isAuthor,
                        onEdit: () async {
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => CreatePostScreen(
                                postToEdit: post,
                              ),
                            ),
                          );
                          if (context.mounted) {
                            await notifier.refresh();
                          }
                        },
                        onDelete: () async {
                          final success = await ref
                              .read(feedNotifierProvider.notifier)
                              .deletePost(post.id);
                          if (success) {
                            notifier.removePost(post.id);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? (loc?.postDeletedSuccess ??
                                          'Post deleted successfully.')
                                      : (loc?.postDeleteFailed ??
                                          'Failed to delete post.'),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  Container(height: 8, color: sectionDividerColor),
                ],
              ),
            );
          },
        ),
    ];
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? const Color(0xFF1877F2).withValues(alpha: 0.14)
        : (isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB));
    final fgColor = isSelected
        ? const Color(0xFF1877F2)
        : (isDark ? Colors.white : Colors.black87);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: fgColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutOverviewCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required UserProfile profile,
    required AppLocalizations? loc,
  }) {
    final joinedText = profile.createdAt != null
        ? DateFormat.yMMMMd().format(profile.createdAt!)
        : 'Lotus Connect Member';

    return ColoredBox(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
              _buildAboutRow(
                icon: Icons.format_quote_rounded,
                title: 'Bio',
                value: profile.bio!.trim(),
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const Divider(height: 24),
            ],
            _buildAboutRow(
              icon: Icons.alternate_email_rounded,
              title: 'Username',
              value: '@${profile.username}',
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),
            if (profile.email.isNotEmpty) ...[
              const Divider(height: 24),
              _buildAboutRow(
                icon: Icons.mail_outline_rounded,
                title: 'Email',
                value: profile.email,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
            if (profile.location != null &&
                profile.location!.trim().isNotEmpty) ...[
              const Divider(height: 24),
              _buildAboutRow(
                icon: Icons.location_on_outlined,
                title: 'Location',
                value: profile.location!.trim(),
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
            if (profile.website != null &&
                profile.website!.trim().isNotEmpty) ...[
              const Divider(height: 24),
              _buildAboutRow(
                icon: Icons.link_rounded,
                title: 'Website',
                value: profile.website!.trim(),
                primaryTextColor: const Color(0xFF1877F2),
                secondaryTextColor: secondaryTextColor,
              ),
            ],
            const Divider(height: 24),
            _buildAboutRow(
              icon: Icons.calendar_today_outlined,
              title: 'Joined',
              value: joinedText,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),
            if (profile.isSelf) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openEditProfile(profile),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(loc?.editProfile ?? 'Edit profile details'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: secondaryTextColor),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String? message,
    ProfileNotifier notifier,
    AppLocalizations? loc,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 56,
              color: Colors.grey,
            ),
            const SizedBox(height: 14),
            Text(
              message ?? 'Could not load profile',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: notifier.loadAll,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadActiveTabHelper {
  static ProfileTab read(
    WidgetRef ref, {
    required bool isExplicitSelf,
    required String? userId,
  }) {
    final currentUserId = ref.read(settingsNotifierProvider).settings.userId;
    if (isExplicitSelf ||
        (currentUserId.isNotEmpty && userId == currentUserId)) {
      return ref.read(myProfileNotifierProvider).activeTab;
    }
    return ref.read(userProfileNotifierProvider(userId!)).activeTab;
  }
}
