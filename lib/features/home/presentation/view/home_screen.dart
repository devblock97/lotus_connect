import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/feed_notifier.dart';
import 'package:lotus_connect/features/home/application/feed_playback_coordinator.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/application/video_pre_cache_manager.dart';
import 'package:lotus_connect/features/home/presentation/view/create_post_screen.dart';
import 'package:lotus_connect/features/home/presentation/widgets/create_post_bar.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card_skeleton.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_comments_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_options_sheet.dart';
import 'package:lotus_connect/features/home/presentation/widgets/stories_tray.dart';
import 'package:lotus_connect/features/livestream/application/livestream_feed_notifier.dart';
import 'package:lotus_connect/features/livestream/presentation/views/livestream_explore_screen.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      ref.read<FeedNotifier>(feedNotifierProvider.notifier).loadMoreFeed();
    }
  }

  bool get _isBottom {
    if (!_controller.hasClients) return false;
    final currScroll = _controller.position.pixels;
    final maxScroll = _controller.position.maxScrollExtent;

    return currScroll >= (maxScroll * 0.8);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(feedPlaybackCoordinatorProvider.notifier).pauseAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Predictive pre-caching for upcoming posts (N+1, N+2) when post N plays
    ref.listen(
      feedPlaybackCoordinatorProvider.select((s) => s.activePostId),
      (previous, activePostId) {
        if (activePostId != null) {
          final posts = ref.read(feedNotifierProvider).posts;
          final activeIndex = posts.indexWhere(
            (p) => p.id == activePostId || activePostId.startsWith('${p.id}_'),
          );
          if (activeIndex != -1) {
            ref.read(videoPreCacheManagerProvider).preCacheUpcoming(
                  posts: posts,
                  currentIndex: activeIndex,
                );
          }
        }
      },
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final feedState = ref.watch(feedNotifierProvider);
    final notifier = ref.read(feedNotifierProvider.notifier);
    final settings = ref.watch(settingsNotifierProvider).settings;
    final loc = AppLocalizations.of(context);

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
            icon: const Icon(
              Icons.sensors,
              color: Color(0xFFFF0844),
              size: 24,
            ),
            splashRadius: 20,
            tooltip: loc?.liveStreams ?? 'Live streams',
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => const LiveStreamExploreScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.plus_app,
              color: primaryTextColor,
              size: 24,
            ),
            splashRadius: 20,
            tooltip: loc?.createPost ?? 'Create post',
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => const CreatePostScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.paperplane,
              color: primaryTextColor,
              size: 24,
            ),
            splashRadius: 20,
            tooltip: loc?.chat ?? 'Chat',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(feedPlaybackCoordinatorProvider.notifier).pauseAll();
          await Future.wait([
            notifier.refreshFeed(),
            ref.read(storiesNotifierProvider.notifier).refreshStories(),
            ref.read(liveStreamFeedProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            const SliverToBoxAdapter(
              child: StoriesTray(),
            ),
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: theme.dividerColor.withValues(alpha: 0.15),
              ),
            ),
            const SliverToBoxAdapter(
              child: CreatePostBar(),
            ),
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: theme.dividerColor.withValues(alpha: 0.15),
              ),
            ),
            if (feedState.isLoading && feedState.posts.isEmpty)
              const SliverPostListSkeleton()
            else if (feedState.posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    loc?.noPostsYet ?? 'No posts yet',
                    style: TextStyle(
                      color: primaryTextColor.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: feedState.posts.length,
                itemBuilder: (context, index) {
                  final post = feedState.posts[index];
                  final isAuthor = (settings.userId.isNotEmpty &&
                          settings.userId == post.author.id) ||
                      (settings.username.isNotEmpty &&
                          settings.username.toLowerCase() ==
                              post.author.username.toLowerCase());

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PostCard(
                        post: post,
                        onProfileTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                userId: post.author.id,
                                initialUsername: post.author.username,
                              ),
                            ),
                          );
                        },
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
                        onCommentTap: () {
                          PostCommentsSheet.show(
                            context,
                            post: post,
                          );
                        },
                        onViewCommentsTap: () {
                          PostCommentsSheet.show(
                            context,
                            post: post,
                          );
                        },
                        onMoreOptionsTap: () {
                          PostOptionsSheet.show(
                            context,
                            post: post,
                            isAuthor: isAuthor,
                            onEdit: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => CreatePostScreen(
                                    postToEdit: post,
                                  ),
                                ),
                              );
                            },
                            onDelete: () async {
                              final success = await notifier.deletePost(
                                post.id,
                              );
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
                      if (index < feedState.posts.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
