import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card.dart';

/// Home feed screen displaying Instagram-style stories and live posts.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<_StoryItem> _stories = const [
    _StoryItem(
      username: 'Your story',
      isMe: true,
    ),
    _StoryItem(
      username: 'nnthong',
      hasStory: true,
    ),
    _StoryItem(
      username: 'marvel',
      isMarvel: true,
      hasStory: true,
    ),
    _StoryItem(
      username: 'thekamraan',
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      hasStory: true,
    ),
    _StoryItem(
      username: 'tva_official',
      avatarUrl:
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
      hasStory: true,
    ),
    _StoryItem(
      username: 'disneyplus',
      avatarUrl:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150',
      hasStory: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final feedState = ref.watch(feedNotifierProvider);
    final notifier = ref.read(feedNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Lotus Connect',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: primaryTextColor,
            fontFamily: 'serif',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.heart,
              color: primaryTextColor,
              size: 24,
            ),
            splashRadius: 20,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.paperplane,
              color: primaryTextColor,
              size: 24,
            ),
            splashRadius: 20,
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refreshFeed,
        child: feedState.isLoading && feedState.posts.isEmpty
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: feedState.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStoriesTray(theme, primaryTextColor),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ],
                    );
                  }

                  final postIndex = index - 1;
                  final post = feedState.posts[postIndex];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PostCard(
                        post: post,
                        onLikeChanged: (isLiked) {
                          notifier.toggleLike(
                            post.id,
                            isLiked: isLiked,
                          );
                        },
                        onSaveChanged: (isSaved) {
                          notifier.toggleSave(
                            post.id,
                            isSaved: isSaved,
                          );
                        },
                      ),
                      if (postIndex < feedState.posts.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStoriesTray(ThemeData theme, Color textColor) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStoryAvatar(story, theme),
                const SizedBox(height: 5),
                SizedBox(
                  width: 68,
                  child: Text(
                    story.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryAvatar(_StoryItem story, ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: story.hasStory
                ? (story.isMarvel
                    ? const LinearGradient(
                        colors: [Color(0xFFE23636), Color(0xFFC41212)],
                      )
                    : const SweepGradient(
                        colors: [
                          Color(0xFFFBAA47),
                          Color(0xFFD91A46),
                          Color(0xFFA60F93),
                          Color(0xFFFBAA47),
                        ],
                      ))
                : null,
            border: !story.hasStory
                ? Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  )
                : null,
          ),
          padding: EdgeInsets.all(story.hasStory ? 2.5 : 0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
            padding: EdgeInsets.all(story.hasStory ? 2.0 : 0),
            child: ClipOval(
              child: story.isMarvel
                  ? Container(
                      color: const Color(0xFFE23636),
                      alignment: Alignment.center,
                      child: const Text(
                        'MARVEL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    )
                  : (story.avatarUrl != null
                      ? Image.network(
                          story.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, dynamic ___) =>
                              const Icon(Icons.person, size: 28),
                        )
                      : const Icon(Icons.person, size: 30)),
            ),
          ),
        ),
        if (story.isMe)
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
}

class _StoryItem {
  const _StoryItem({
    required this.username,
    this.avatarUrl,
    this.hasStory = false,
    this.isMe = false,
    this.isMarvel = false,
  });

  final String username;
  final String? avatarUrl;
  final bool hasStory;
  final bool isMe;
  final bool isMarvel;
}
