import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/core/theme/app_size.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/full_screen_media_viewer.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.profile,
    required this.currentUserId,
    super.key,
    this.isUploadingAvatar = false,
    this.isUploadingCover = false,
    this.isMutatingFriendship = false,
    this.isOnline = false,
    this.onEditProfileTap,
    this.onAddToStoryTap,
    this.onSettingsTap,
    this.onChangeAvatarTap,
    this.onChangeCoverTap,
    this.onAddFriendTap,
    this.onAcceptFriendTap,
    this.onRejectFriendTap,
    this.onUnfriendTap,
    this.onToggleCloseFriendTap,
    this.onMessageTap,
    this.onVoiceCallTap,
    this.onVideoCallTap,
    this.onFriendsCountTap,
    this.onPhotosCountTap,
  });

  final UserProfile profile;
  final String currentUserId;
  final bool isUploadingAvatar;
  final bool isUploadingCover;
  final bool isMutatingFriendship;
  final bool isOnline;

  final VoidCallback? onEditProfileTap;
  final VoidCallback? onAddToStoryTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onChangeAvatarTap;
  final VoidCallback? onChangeCoverTap;
  final VoidCallback? onAddFriendTap;
  final VoidCallback? onAcceptFriendTap;
  final VoidCallback? onRejectFriendTap;
  final VoidCallback? onUnfriendTap;
  final VoidCallback? onToggleCloseFriendTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onVoiceCallTap;
  final VoidCallback? onVideoCallTap;
  final VoidCallback? onFriendsCountTap;
  final VoidCallback? onPhotosCountTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final loc = AppLocalizations.of(context);

    final hasCover = profile.coverUrl != null && profile.coverUrl!.isNotEmpty;
    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty;

    return ColoredBox(
      color: theme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cover Photo + Overlapping Avatar Stack
          SizedBox(
            height: 256,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Photo Banner
                GestureDetector(
                  onTap: () {
                    if (hasCover) {
                      FullScreenMediaViewer.show(
                        context,
                        medias: [MediaEntity(url: profile.coverUrl!)],
                      );
                    } else if (profile.isSelf) {
                      onChangeCoverTap?.call();
                    }
                  },
                  child: SizedBox(
                    height: 196,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasCover)
                          CachedNetworkImage(
                            imageUrl: profile.coverUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildDefaultCover(isDark),
                            errorWidget: (_, __, dynamic ___) =>
                                _buildDefaultCover(isDark),
                          )
                        else
                          _buildDefaultCover(isDark),

                        // Subtle bottom gradient for contrast
                        Positioned(
                          left: AppSize.none,
                          right: AppSize.none,
                          bottom: AppSize.none,
                          height: AppSize.giant,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                              ),
                            ),
                          ),
                        ),

                        if (isUploadingCover)
                          const ColoredBox(
                            color: Colors.black45,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: AppSize.loaderStrokeWidth,
                              ),
                            ),
                          ),

                        // Edit Cover Camera Button (for own profile)
                        if (profile.isSelf)
                          Positioned(
                            right: AppSize.lg,
                            bottom: AppSize.md,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: AppRadius.xl,
                              child: InkWell(
                                borderRadius: AppRadius.xl,
                                onTap:
                                    isUploadingCover ? null : onChangeCoverTap,
                                child: Padding(
                                  padding: AppPadding.chip,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: AppSize.iconXs,
                                      ),
                                      AppGap.hXs,
                                      Text(
                                        loc?.edit ?? 'Edit',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Overlapping Profile Avatar (Bottom-Left like Facebook)
                Positioned(
                  left: AppSize.lg,
                  bottom: AppSize.none,
                  child: GestureDetector(
                    onTap: () {
                      if (hasAvatar) {
                        FullScreenMediaViewer.show(
                          context,
                          medias: [MediaEntity(url: profile.avatarUrl!)],
                        );
                      } else if (profile.isSelf) {
                        onChangeAvatarTap?.call();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 116,
                          height: 116,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.cardColor,
                            border: AppBorder.all(
                              theme.cardColor,
                              width: AppSize.xs,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: AppSize.md,
                                offset: const Offset(0, AppSize.xs),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (hasAvatar)
                                  CachedNetworkImage(
                                    imageUrl: profile.avatarUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        _buildInitialsAvatar(theme),
                                    errorWidget: (_, __, dynamic ___) =>
                                        _buildInitialsAvatar(theme),
                                  )
                                else
                                  _buildInitialsAvatar(theme),
                                if (isUploadingAvatar)
                                  const ColoredBox(
                                    color: Colors.black45,
                                    child: Center(
                                      child: SizedBox(
                                        width: AppSize.loaderSizeMd,
                                        height: AppSize.loaderSizeMd,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth:
                                              AppSize.loaderStrokeWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Camera icon badge for self OR online indicator
                        if (profile.isSelf)
                          Positioned(
                            right: AppSize.xxs,
                            bottom: AppSize.xxs,
                            child: GestureDetector(
                              onTap:
                                  isUploadingAvatar ? null : onChangeAvatarTap,
                              child: Container(
                                width: AppSize.iconButtonSm,
                                height: AppSize.iconButtonSm,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF3A3B3C)
                                      : const Color(0xFFE4E6EB),
                                  shape: BoxShape.circle,
                                  border: AppBorder.all(
                                    theme.cardColor,
                                    width: AppSize.borderThick,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: AppSize.iconSm,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                          )
                        else if (isOnline)
                          Positioned(
                            right: AppSize.xs,
                            bottom: AppSize.xs,
                            child: Container(
                              width: AppSize.xl,
                              height: AppSize.xl,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: AppBorder.all(
                                  theme.cardColor,
                                  width: AppSize.borderHeavy,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Name, @username, Close Friend badge, Bio, Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSize.lg,
              AppSize.md,
              AppSize.lg,
              AppSize.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Name + Verified / Close Friend badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.displayName,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    if (profile.isCloseFriend) ...[
                      AppGap.hSm,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.sm,
                          vertical: AppSize.xxs,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: AppRadius.md,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: AppSize.iconXxs,
                              color: Color(0xFF10B981),
                            ),
                            AppGap.hXs,
                            Text(
                              loc?.closeFriend ??
                                  loc?.closeFriends ??
                                  'Close Friend',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                AppGap.vXxs,

                // @username handle
                Text(
                  '@${profile.username}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),

                // Bio
                if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
                  AppGap.vMd,
                  Text(
                    profile.bio!.trim(),
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: primaryTextColor,
                    ),
                  ),
                ],

                AppGap.vMd,

                // Inline Stats Row (Friends · Posts · Media)
                Row(
                  children: [
                    _buildStatItem(
                      count: profile.friendCount,
                      label: loc?.friends ?? 'Friends',
                      primaryColor: primaryTextColor,
                      secondaryColor: secondaryTextColor,
                      onTap: onFriendsCountTap,
                    ),
                    _buildDotSeparator(secondaryTextColor),
                    _buildStatItem(
                      count: profile.postCount,
                      label: loc?.postsStat ?? 'Posts',
                      primaryColor: primaryTextColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    _buildDotSeparator(secondaryTextColor),
                    _buildStatItem(
                      count: profile.mediaCount,
                      label: loc?.photosStat ?? loc?.photosTab ?? 'Photos',
                      primaryColor: primaryTextColor,
                      secondaryColor: secondaryTextColor,
                      onTap: onPhotosCountTap,
                    ),
                  ],
                ),

                AppGap.vLg,

                // 3. Facebook Action Buttons Row
                if (profile.isSelf)
                  _buildSelfActions(context, theme, isDark, loc)
                else
                  _buildVisitorActions(context, theme, isDark, loc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCover(bool isDark) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF1E3A8A),
                  Color(0xFF312E81),
                  Color(0xFF4C1D95),
                ]
              : const [
                  Color(0xFF2563EB),
                  Color(0xFF4F46E5),
                  Color(0xFF7C3AED),
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.spa_outlined,
          size: AppSize.iconHero,
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        profile.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color primaryColor,
    required Color secondaryColor,
    VoidCallback? onTap,
  }) {
    final child = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$count ',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xs,
      child: Padding(
        padding: AppPadding.xxs,
        child: child,
      ),
    );
  }

  Widget _buildDotSeparator(Color color) {
    return Padding(
      padding: AppPadding.hSm,
      child: Text(
        '•',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSelfActions(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? loc,
  ) {
    final secondaryBg =
        isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB);
    final secondaryFg = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        // Primary: + Add to story
        Expanded(
          flex: 5,
          child: FilledButton.icon(
            onPressed: onAddToStoryTap,
            icon: const Icon(Icons.add_circle_rounded, size: AppSize.iconSm),
            label: Text(
              loc?.addToStory ?? 'Add to story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              padding: AppPadding.vMd,
              shape: AppBorder.rounded(radius: AppSize.radiusButton),
            ),
          ),
        ),
        AppGap.hSm,

        // Secondary: Edit profile
        Expanded(
          flex: 5,
          child: FilledButton.icon(
            onPressed: onEditProfileTap,
            icon: Icon(
              Icons.edit_rounded,
              size: AppSize.iconSm,
              color: secondaryFg,
            ),
            label: Text(
              loc?.editProfile ?? 'Edit profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: secondaryFg,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: secondaryBg,
              foregroundColor: secondaryFg,
              padding: AppPadding.vMd,
              shape: AppBorder.rounded(radius: AppSize.radiusButton),
            ),
          ),
        ),
        AppGap.hSm,

        // More / Settings icon button
        SizedBox(
          height: AppSize.buttonHeightMd,
          width: AppSize.minTouchTarget,
          child: FilledButton(
            onPressed: onSettingsTap,
            style: FilledButton.styleFrom(
              backgroundColor: secondaryBg,
              foregroundColor: secondaryFg,
              padding: AppPadding.zero,
              shape: AppBorder.rounded(radius: AppSize.radiusButton),
            ),
            child: Icon(Icons.more_horiz_rounded, color: secondaryFg),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorActions(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? loc,
  ) {
    final secondaryBg =
        isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB);
    final secondaryFg = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        // Friendship Action Button
        Expanded(
          flex: 5,
          child: _buildFriendshipButton(
            context,
            isDark: isDark,
            secondaryBg: secondaryBg,
            secondaryFg: secondaryFg,
            loc: loc,
          ),
        ),
        AppGap.hSm,

        // Message Button
        Expanded(
          flex: 4,
          child: FilledButton.icon(
            onPressed: onMessageTap,
            icon: Icon(
              CupertinoIcons.chat_bubble_text_fill,
              size: AppSize.iconSm,
              color: profile.isFriend ? Colors.white : secondaryFg,
            ),
            label: Text(
              loc?.message ?? 'Message',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: profile.isFriend ? Colors.white : secondaryFg,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor:
                  profile.isFriend ? const Color(0xFF1877F2) : secondaryBg,
              padding: AppPadding.vMd,
              shape: AppBorder.rounded(radius: AppSize.radiusButton),
            ),
          ),
        ),
        AppGap.hSm,

        // Call / More Button
        SizedBox(
          height: AppSize.buttonHeightMd,
          width: AppSize.minTouchTarget,
          child: PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'voice') {
                onVoiceCallTap?.call();
              } else if (val == 'video') {
                onVideoCallTap?.call();
              }
            },
            shape: AppBorder.rounded(radius: AppSize.radiusMd),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'voice',
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: AppSize.iconSm),
                    AppGap.hMd,
                    Text(loc?.voiceCall ?? 'Voice call'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'video',
                child: Row(
                  children: [
                    const Icon(Icons.videocam_outlined, size: AppSize.iconSm),
                    AppGap.hMd,
                    Text(loc?.videoCall ?? 'Video call'),
                  ],
                ),
              ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: secondaryBg,
                borderRadius: AppRadius.button,
              ),
              child: Icon(
                Icons.phone_in_talk_rounded,
                size: AppSize.iconSm,
                color: secondaryFg,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendshipButton(
    BuildContext context, {
    required bool isDark,
    required Color secondaryBg,
    required Color secondaryFg,
    required AppLocalizations? loc,
  }) {
    if (profile.isFriend) {
      return FilledButton.icon(
        onPressed: isMutatingFriendship
            ? null
            : () => _showFriendOptionsSheet(context, loc),
        icon: Icon(
          Icons.how_to_reg_rounded,
          size: AppSize.iconSm,
          color: secondaryFg,
        ),
        label: Text(
          loc?.friends ?? 'Friends',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: secondaryFg,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: secondaryBg,
          padding: AppPadding.vMd,
          shape: AppBorder.rounded(radius: AppSize.radiusButton),
        ),
      );
    }

    if (profile.didReceiveFriendRequest(currentUserId)) {
      return FilledButton.icon(
        onPressed: isMutatingFriendship
            ? null
            : () => _showRespondRequestSheet(context, loc),
        icon: const Icon(
          Icons.person_add_alt_1_rounded,
          size: AppSize.iconSm,
        ),
        label: Text(
          loc?.respondFriendRequest ?? 'Respond',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          padding: AppPadding.vMd,
          shape: AppBorder.rounded(radius: AppSize.radiusButton),
        ),
      );
    }

    if (profile.isPendingRequest) {
      return FilledButton.icon(
        onPressed: null,
        icon: Icon(
          Icons.schedule_rounded,
          size: AppSize.iconSm,
          color: secondaryFg,
        ),
        label: Text(
          loc?.requested ?? 'Requested',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: secondaryFg,
          ),
        ),
        style: FilledButton.styleFrom(
          disabledBackgroundColor: secondaryBg,
          padding: AppPadding.vMd,
          shape: AppBorder.rounded(radius: AppSize.radiusButton),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: isMutatingFriendship ? null : onAddFriendTap,
      icon: const Icon(Icons.person_add_alt_1_rounded, size: AppSize.iconSm),
      label: Text(
        loc?.addFriend ?? 'Add Friend',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
        padding: AppPadding.vMd,
        shape: AppBorder.rounded(radius: AppSize.radiusButton),
      ),
    );
  }

  void _showFriendOptionsSheet(BuildContext context, AppLocalizations? loc) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetTop,
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppGap.vMd,
            Container(
              width: AppSize.sheetHandleWidth,
              height: AppSize.sheetHandleHeight,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: AppRadius.full,
              ),
            ),
            AppGap.vMd,
            ListTile(
              leading: Icon(
                profile.isCloseFriend
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFF10B981),
              ),
              title: Text(loc?.closeFriends ?? 'Close Friends'),
              trailing: Switch.adaptive(
                value: profile.isCloseFriend,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (_) {
                  Navigator.pop(ctx);
                  onToggleCloseFriendTap?.call();
                },
              ),
              onTap: () {
                Navigator.pop(ctx);
                onToggleCloseFriendTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person_remove_outlined,
                color: Colors.redAccent,
              ),
              title: Text(
                loc?.unfriend ?? 'Unfriend',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onUnfriendTap?.call();
              },
            ),
            AppGap.vSm,
          ],
        ),
      ),
    );
  }

  void _showRespondRequestSheet(BuildContext context, AppLocalizations? loc) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetTop,
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppGap.vMd,
            Container(
              width: AppSize.sheetHandleWidth,
              height: AppSize.sheetHandleHeight,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: AppRadius.full,
              ),
            ),
            AppGap.vMd,
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF16A34A),
              ),
              title: Text(
                loc?.confirmFriendRequest ?? 'Confirm friend request',
              ),
              onTap: () {
                Navigator.pop(ctx);
                onAcceptFriendTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cancel_outlined,
                color: Colors.redAccent,
              ),
              title: Text(
                loc?.deleteFriendRequest ?? 'Delete request',
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onRejectFriendTap?.call();
              },
            ),
            AppGap.vSm,
          ],
        ),
      ),
    );
  }
}
