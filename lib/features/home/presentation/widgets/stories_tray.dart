import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:lotus_connect/features/home/presentation/view/story_viewer_screen.dart';

class StoriesTray extends ConsumerWidget {
  const StoriesTray({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    final storiesState = ref.watch(storiesNotifierProvider);
    final groups = storiesState.storyGroups;

    if (storiesState.isLoading && groups.isEmpty) {
      return _buildSkeletonTray(theme);
    }

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final userStory = groups[index];
          final isMe = userStory.isSelf;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => _onStoryTap(context, ref, groups, index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStoryAvatar(userStory, theme, isMe),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 68,
                    child: Text(
                      isMe ? 'Your story' : userStory.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: userStory.hasUnseen
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onStoryTap(
    BuildContext context,
    WidgetRef ref,
    List<UserStory> groups,
    int index,
  ) {
    final tapped = groups[index];

    if (tapped.hasStories) {
      // Find the index among groups that have stories
      final validGroups = groups.where((g) => g.hasStories).toList();
      final validIndex = validGroups.indexOf(tapped);

      Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: false,
          pageBuilder: (_, __, ___) => StoryViewerScreen(
            storyGroups: validGroups,
            initialGroupIndex: validIndex != -1 ? validIndex : 0,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else if (tapped.isSelf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap to create a new story'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildStoryAvatar(UserStory userStory, ThemeData theme, bool isMe) {
    final hasStories = userStory.hasStories;
    final hasUnseen = userStory.hasUnseen;
    final hasCloseFriends = userStory.hasCloseFriendsStory;

    // Gradient selection
    Gradient? ringGradient;
    if (hasStories) {
      if (hasCloseFriends) {
        ringGradient = const LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        );
      } else if (hasUnseen) {
        ringGradient = const SweepGradient(
          colors: [
            Color(0xFFFBAA47),
            Color(0xFFD91A46),
            Color(0xFFA60F93),
            Color(0xFFFBAA47),
          ],
        );
      }
    }

    final hasRing = ringGradient != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ringGradient,
            border: !hasRing
                ? Border.all(
                    color: hasStories
                        ? theme.dividerColor.withValues(alpha: 0.35)
                        : Colors.transparent,
                    width: 1.5,
                  )
                : null,
          ),
          padding: EdgeInsets.all(hasRing ? 2.5 : (hasStories ? 1.5 : 0)),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
            padding: EdgeInsets.all(hasStories ? 2.0 : 0),
            child: ClipOval(
              child:
                  userStory.avatarUrl != null && userStory.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: userStory.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              _buildInitials(userStory.user, theme),
                          errorWidget: (_, __, dynamic ___) =>
                              _buildInitials(userStory.user, theme),
                        )
                      : _buildInitials(userStory.user, theme),
            ),
          ),
        ),

        // Plus icon overlay for logged-in user without stories
        // or to add stories
        if (isMe && !hasStories)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF0095F6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(PostAuthor user, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF2A2A36) : const Color(0xFFE2E4E9),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSkeletonTray(ThemeData theme) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 52,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
