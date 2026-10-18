import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/application/livestream_feed_notifier.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/presentation/views/go_live_screen.dart';
import 'package:lotus_connect/features/livestream/presentation/views/livestream_player_screen.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/live_badge.dart';

class LiveStreamExploreScreen extends ConsumerWidget {
  const LiveStreamExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final feedState = ref.watch(liveStreamFeedProvider);
    final feedNotifier = ref.read(liveStreamFeedProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Row(
          children: [
            LiveBadge(),
            SizedBox(width: 8),
            Text(
              'Live Streams',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF0844),
            ),
            icon: const Icon(Icons.sensors, size: 18),
            label: const Text(
              'Go Live',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GoLiveScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: feedNotifier.refresh,
        child: CustomScrollView(
          slivers: [
            // Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      label: 'All',
                      filterValue: 'all',
                      currentFilter: feedState.statusFilter,
                      onSelect: feedNotifier.changeStatusFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: '🔴 Live Now',
                      filterValue: 'live',
                      currentFilter: feedState.statusFilter,
                      onSelect: feedNotifier.changeStatusFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: 'Ended Replays',
                      filterValue: 'ended',
                      currentFilter: feedState.statusFilter,
                      onSelect: feedNotifier.changeStatusFilter,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            if (feedState.isLoading && feedState.streams.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (feedState.streams.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sensors_off_rounded,
                        size: 64,
                        color: theme.dividerColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No live streams right now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Be the first to start a live stream '
                        'and connect with friends!',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0844),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.sensors, size: 18),
                        label: const Text('Start Streaming Now'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const GoLiveScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stream = feedState.streams[index];
                      return _buildStreamCard(context, stream);
                    },
                    childCount: feedState.streams.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF0844),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.sensors),
        label: const Text(
          'Go Live',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const GoLiveScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String filterValue,
    required String currentFilter,
    required void Function(String) onSelect,
  }) {
    final isSelected = filterValue == currentFilter;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onSelect(filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF0844)
              : theme.dividerColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStreamCard(BuildContext context, LiveStream stream) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LiveStreamPlayerScreen(initialStream: stream),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2238),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail / Cover image
            if (stream.thumbnailUrl != null && stream.thumbnailUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: stream.thumbnailUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, dynamic ___) =>
                    _buildFallbackThumbnail(stream),
              )
            else
              _buildFallbackThumbnail(stream),

            // Gradient shade at top and bottom
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 90,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),

            // Top-left: LIVE Badge
            Positioned(
              top: 8,
              left: 8,
              child: stream.isLive
                  ? const LiveBadge(isCompact: true)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ENDED',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),

            // Top-right: Viewers count badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.remove_red_eye_rounded,
                      color: Colors.white70,
                      size: 11,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${stream.viewerCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom info (Title, Host Avatar, Username)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stream.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2)],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildSmallAvatar(stream.host),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (stream.host.fullName?.isNotEmpty ?? false)
                              ? stream.host.fullName!
                              : stream.host.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail(LiveStream stream) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF232526),
            Color(0xFF414345),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white12,
          ),
          clipBehavior: Clip.antiAlias,
          child:
              stream.host.avatarUrl != null && stream.host.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: stream.host.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, dynamic ___) =>
                          Center(child: Text(stream.host.initials)),
                    )
                  : Center(
                      child: Text(
                        stream.host.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildSmallAvatar(PostAuthor user) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24,
      ),
      clipBehavior: Clip.antiAlias,
      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: user.avatarUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, dynamic ___) => Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(fontSize: 8, color: Colors.white),
                ),
              ),
            )
          : Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
