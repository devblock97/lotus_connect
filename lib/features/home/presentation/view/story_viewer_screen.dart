import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/story_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:video_player/video_player.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({
    required this.storyGroups,
    this.initialGroupIndex = 0,
    super.key,
  });

  final List<UserStory> storyGroups;
  final int initialGroupIndex;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentGroupIndex;
  int _currentStoryIndex = 0;

  late AnimationController _progressController;
  VideoPlayerController? _videoController;

  bool _isPaused = false;
  bool _isHolding = false;
  bool _showHeartAnimation = false;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  List<UserStory> get _validGroups =>
      widget.storyGroups.where((g) => g.hasStories).toList();

  UserStory get _currentGroup {
    if (_validGroups.isEmpty) {
      return widget.storyGroups[_currentGroupIndex];
    }
    return _validGroups[_currentGroupIndex.clamp(0, _validGroups.length - 1)];
  }

  Story get _currentStory {
    final stories = _currentGroup.stories;
    return stories[_currentStoryIndex.clamp(0, stories.length - 1)];
  }

  @override
  void initState() {
    super.initState();
    // System overlay
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _currentGroupIndex = widget.initialGroupIndex.clamp(
      0,
      _validGroups.isNotEmpty ? _validGroups.length - 1 : 0,
    );

    // If starting on a user who has some viewed stories,
    // start on first unviewed
    final currentStories = _currentGroup.stories;
    final firstUnviewed = currentStories.indexWhere((s) => !s.hasViewed);
    _currentStoryIndex = firstUnviewed != -1 ? firstUnviewed : 0;

    _pageController = PageController(initialPage: _currentGroupIndex);

    _progressController = AnimationController(vsync: this);
    _progressController.addStatusListener(_onProgressStatusChanged);

    _replyFocusNode.addListener(() {
      if (_replyFocusNode.hasFocus) {
        _pauseStory();
      } else {
        _resumeStory();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndPlayCurrentStory();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _progressController.removeStatusListener(_onProgressStatusChanged);
    _progressController.dispose();
    _videoController?.dispose();
    _pageController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _nextStory();
    }
  }

  Future<void> _loadAndPlayCurrentStory() async {
    _progressController
      ..stop()
      ..reset();

    await _videoController?.dispose();
    _videoController = null;

    final story = _currentStory;

    // Mark as viewed in background
    unawaited(
      ref
          .read(storiesNotifierProvider.notifier)
          .markStoryViewed(story.id, _currentGroup.id),
    );

    final durationSec = story.duration > 0 ? story.duration : 5.0;

    if (story.isVideo) {
      try {
        final videoUri = Uri.parse(story.mediaUrl);
        final controller = VideoPlayerController.networkUrl(videoUri);
        await controller.initialize();
        if (!mounted) return;

        setState(() {
          _videoController = controller;
        });

        final videoDuration = controller.value.duration.inMilliseconds > 0
            ? controller.value.duration
            : Duration(milliseconds: (durationSec * 1000).toInt());

        _progressController.duration = videoDuration;
        await controller.play();
        if (!_isPaused && mounted) {
          _progressController.forward();
        }
      } on Object catch (_) {
        // Fallback to timer on video load failure
        _progressController.duration =
            Duration(milliseconds: (durationSec * 1000).toInt());
        if (!_isPaused && mounted) {
          _progressController.forward();
        }
      }
    } else {
      _progressController.duration =
          Duration(milliseconds: (durationSec * 1000).toInt());
      if (!_isPaused && mounted) {
        _progressController.forward();
      }
    }

    if (mounted) setState(() {});
  }

  void _pauseStory() {
    if (_isPaused) return;
    _isPaused = true;
    _progressController.stop();
    _videoController?.pause();
    setState(() {});
  }

  void _resumeStory() {
    if (!_isPaused) return;
    _isPaused = false;
    _progressController.forward();
    _videoController?.play();
    setState(() {});
  }

  void _nextStory() {
    if (_currentStoryIndex < _currentGroup.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _loadAndPlayCurrentStory();
    } else {
      // Advance to next user story group
      if (_currentGroupIndex < _validGroups.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        // Reached end of all stories
        Navigator.of(context).pop();
      }
    }
  }

  void _prevStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _loadAndPlayCurrentStory();
    } else {
      // Go back to previous user story group
      if (_currentGroupIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        // Restart current story
        _loadAndPlayCurrentStory();
      }
    }
  }

  void _onGroupPageChanged(int newIndex) {
    setState(() {
      _currentGroupIndex = newIndex;
      _currentStoryIndex = 0;
    });
    _loadAndPlayCurrentStory();
  }

  Future<void> _sendHeartReaction() async {
    final story = _currentStory;
    setState(() {
      _showHeartAnimation = true;
    });

    unawaited(
      ref.read(storiesNotifierProvider.notifier).reactToStory(story.id, '❤️'),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _showHeartAnimation = false;
      });
    }
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final story = _currentStory;
    _replyController.clear();
    _replyFocusNode.unfocus();

    await ref
        .read(storiesNotifierProvider.notifier)
        .replyToStory(story.id, text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: _onGroupPageChanged,
        itemCount: _validGroups.length,
        itemBuilder: (context, groupIndex) {
          final group = _validGroups[groupIndex];
          final isCurrentPage = groupIndex == _currentGroupIndex;
          final story = isCurrentPage ? _currentStory : group.stories.first;

          return GestureDetector(
            onLongPressStart: (_) {
              setState(() => _isHolding = true);
              _pauseStory();
            },
            onLongPressEnd: (_) {
              setState(() => _isHolding = false);
              _resumeStory();
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300) {
                Navigator.of(context).pop();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background layer
                _buildStoryBackground(story),

                // Media content (Image or Video)
                _buildStoryMedia(story, isCurrentPage),

                // Touch hitboxes for Left/Right tap navigation
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _prevStory,
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _nextStory,
                        ),
                      ),
                    ],
                  ),
                ),

                // Overlays (Header, Progress bars, Caption, Reply bar)
                AnimatedOpacity(
                  opacity: _isHolding ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Column(
                    children: [
                      // Top Safe Area with Progress Bars and Header
                      SafeArea(
                        bottom: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            _buildProgressIndicators(group),
                            const SizedBox(height: 10),
                            _buildStoryHeader(group, story),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Caption & Bottom Bar
                      SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (story.caption != null &&
                                story.caption!.trim().isNotEmpty)
                              _buildStoryCaption(story.caption!),
                            _buildBottomReplyBar(story),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Bursting Heart Animation
                if (_showHeartAnimation)
                  const Center(
                    child: _BurstingHeart(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryBackground(Story story) {
    final bgColor = story.parsedBackgroundColor;
    if (bgColor != null) {
      return Container(color: bgColor);
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1E24),
            Color(0xFF0F0F12),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryMedia(Story story, bool isCurrentPage) {
    if (story.isVideo && isCurrentPage && _videoController != null) {
      if (_videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      }
    }

    return Center(
      child: CachedNetworkImage(
        imageUrl: story.mediaUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (_, __, dynamic ___) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 64,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicators(UserStory group) {
    final count = group.stories.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: List.generate(count, (index) {
          return Expanded(
            child: Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withValues(alpha: 0.35),
              ),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  double factor;
                  if (index < _currentStoryIndex) {
                    factor = 1.0;
                  } else if (index == _currentStoryIndex) {
                    factor = _progressController.value;
                  } else {
                    factor = 0.0;
                  }

                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: factor,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStoryHeader(UserStory group, Story story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 1.2),
            ),
            child: ClipOval(
              child: group.avatarUrl != null && group.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: group.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _buildInitials(group.user.initials),
                      errorWidget: (_, __, dynamic ___) =>
                          _buildInitials(group.user.initials),
                    )
                  : _buildInitials(group.user.initials),
            ),
          ),
          const SizedBox(width: 10),

          // Username & TimeAgo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        group.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      story.timeAgo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (story.isCloseFriendsStory)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Close Friends',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 26),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Container(
      color: const Color(0xFF4A4A58),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStoryCaption(String caption) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Text(
        caption,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black87,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomReplyBar(Story story) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: Colors.black.withValues(alpha: 0.4),
      child: Row(
        children: [
          // Input field
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _replyController,
                focusNode: _replyFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Send message...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _replyController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _sendReply,
                        )
                      : null,
                ),
                onSubmitted: (_) => _sendReply(),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Heart Reaction button
          GestureDetector(
            onTap: _sendHeartReaction,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                CupertinoIcons.heart_fill,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BurstingHeart extends StatefulWidget {
  const _BurstingHeart();

  @override
  State<_BurstingHeart> createState() => _BurstingHeartState();
}

class _BurstingHeartState extends State<_BurstingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_animController);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 30,
      ),
    ]).animate(_animController);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent,
                    blurRadius: 28,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.heart_fill,
                color: Color(0xFFFF2D55),
                size: 96,
              ),
            ),
          ),
        );
      },
    );
  }
}
