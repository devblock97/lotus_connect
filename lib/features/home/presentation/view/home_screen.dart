import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/feed_provider.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card_skeleton.dart';
import 'package:lotus_connect/features/home/presentation/widgets/stories_tray.dart';

/// Home feed screen displaying Instagram-style stories and live posts.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
        onRefresh: () async {
          await Future.wait([
            notifier.refreshFeed(),
            ref.read(storiesNotifierProvider.notifier).refreshStories(),
          ]);
        },
        child: CustomScrollView(
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
            if (feedState.isLoading && feedState.posts.isEmpty)
              const SliverPostListSkeleton()
            else if (feedState.posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No posts yet',
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
