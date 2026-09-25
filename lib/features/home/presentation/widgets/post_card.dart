import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/presentation/widgets/feed_video_player.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.post,
    super.key,
    this.onLikeChanged,
    this.onSaveChanged,
    this.onProfileTap,
    this.onCommentTap,
    this.onShareTap,
    this.onViewCommentsTap,
    this.onMoreOptionsTap,
    this.onMediaTap,
  });

  final PostItem post;

  final ValueChanged<bool>? onLikeChanged;

  final ValueChanged<bool>? onSaveChanged;

  final VoidCallback? onProfileTap;

  final VoidCallback? onCommentTap;

  final VoidCallback? onShareTap;

  final VoidCallback? onViewCommentsTap;

  final VoidCallback? onMoreOptionsTap;

  final VoidCallback? onMediaTap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late bool _isLiked;
  late bool _isSaved;
  late int _likesCount;
  int _currentCarouselIndex = 0;
  bool _isCaptionExpanded = false;

  // Double-tap heart animation controllers
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;

  // Action button bounce animations
  late AnimationController _likeBtnAnimController;
  late Animation<double> _likeBtnScaleAnimation;

  late AnimationController _saveBtnAnimController;
  late Animation<double> _saveBtnScaleAnimation;

  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _isSaved = widget.post.isSaved;
    _likesCount = widget.post.likesCount;

    _setupAnimations();
  }

  void _setupAnimations() {
    // Large center heart animation on double tap
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.95),
        weight: 40,
      ),
    ]).animate(_heartAnimController);

    _heartOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_heartAnimController);

    // Like button bounce
    _likeBtnAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _likeBtnScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.8),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1),
        weight: 20,
      ),
    ]).animate(_likeBtnAnimController);

    // Save button bounce
    _saveBtnAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _saveBtnScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.8),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1),
        weight: 20,
      ),
    ]).animate(_saveBtnAnimController);
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      _isLiked = widget.post.isLiked;
      _isSaved = widget.post.isSaved;
      _likesCount = widget.post.likesCount;
    }
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    _likeBtnAnimController.dispose();
    _saveBtnAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    HapticFeedback.lightImpact();
    _heartAnimController.forward(from: 0);

    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likesCount += 1;
      });
      _likeBtnAnimController.forward(from: 0);
      widget.onLikeChanged?.call(true);
    }
  }

  void _toggleLike() {
    HapticFeedback.selectionClick();
    _likeBtnAnimController.forward(from: 0);
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    widget.onLikeChanged?.call(_isLiked);
  }

  void _toggleSave() {
    HapticFeedback.selectionClick();
    _saveBtnAnimController.forward(from: 0);
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSaveChanged?.call(_isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Post Header (Avatar, Author name/username, Options)
          _buildHeader(theme, primaryTextColor, secondaryTextColor),

          // Post Media (Single, Carousel, or Text-only Card)
          _buildMediaSection(theme),

          // Action Icon Bar (Like, Comment, Share, Indicators, Bookmark)
          _buildActionBar(primaryTextColor),

          // Likes Count Summary
          _buildLikesSection(primaryTextColor, secondaryTextColor),

          // Post Caption with hashtag highlighting & "...more" toggle
          _buildCaptionSection(primaryTextColor, secondaryTextColor, theme),

          // View All Comments Link / Add a comment prompt
          _buildCommentsPrompt(secondaryTextColor),

          // Time Ago Timestamp
          _buildTimestamp(secondaryTextColor),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final author = widget.post.author;
    final displayName = author.fullName != null && author.fullName!.isNotEmpty
        ? author.fullName!
        : author.username;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Story-ring Avatar
          GestureDetector(
            onTap: widget.onProfileTap,
            child: _buildAvatar(theme),
          ),
          const SizedBox(width: 10),

          // Username and optional subtitle
          Expanded(
            child: GestureDetector(
              onTap: widget.onProfileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    author.username,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      letterSpacing: -0.1,
                    ),
                  ),
                  if (displayName != author.username) ...[
                    const SizedBox(height: 1),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // More Options Button (Three dots)
          IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 20,
              color: primaryColor,
            ),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: widget.onMoreOptionsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final hasStory = widget.post.hasStory;
    final isMarvel = widget.post.username.toLowerCase() == 'marvel';
    final avatarUrl = widget.post.userAvatarUrl;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasStory
            ? isMarvel
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
                  )
            : null,
        border: !hasStory
            ? Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
              )
            : null,
      ),
      padding: EdgeInsets.all(hasStory ? 2.0 : 0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.scaffoldBackgroundColor,
        ),
        padding: EdgeInsets.all(hasStory ? 1.5 : 0),
        child: ClipOval(
          child: isMarvel
              ? _buildMarvelAvatarBadge()
              : (avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildInitialsAvatar(
                        widget.post.author,
                        theme,
                      ),
                      errorWidget: (_, __, dynamic ___) => _buildInitialsAvatar(
                        widget.post.author,
                        theme,
                      ),
                    )
                  : _buildInitialsAvatar(widget.post.author, theme)),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(PostAuthor author, ThemeData theme) {
    final colors = [
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF009688),
      const Color(0xFFE91E63),
      const Color(0xFFFF5722),
    ];
    final color = colors[author.username.hashCode.abs() % colors.length];

    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        author.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMarvelAvatarBadge() {
    return Container(
      color: const Color(0xFFE23636),
      alignment: Alignment.center,
      child: const Text(
        'MARVEL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildMediaSection(ThemeData theme) {
    final mediaItems = widget.post.mediaItems;

    // Text-only post
    if (mediaItems.isEmpty) {
      return _buildTextOnlyMedia(theme);
    }

    // Carousel or single media
    final firstItem = mediaItems.first;
    final aspectRatio = firstItem.aspectRatio;

    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onTap: widget.onMediaTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Media PageView or single display
          AspectRatio(
            aspectRatio: aspectRatio,
            child: mediaItems.length == 1
                ? _buildSingleMediaItem(firstItem, theme)
                : PageView.builder(
                    itemCount: mediaItems.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildSingleMediaItem(mediaItems[index], theme);
                    },
                  ),
          ),

          // Carousel page count pill badge (e.g. "1/3")
          if (mediaItems.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentCarouselIndex + 1}/${mediaItems.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Bursting Heart Animation on Double-Tap
          AnimatedBuilder(
            animation: _heartAnimController,
            builder: (context, child) {
              if (_heartAnimController.isDismissed) {
                return const SizedBox.shrink();
              }
              return Opacity(
                opacity: _heartOpacityAnimation.value,
                child: Transform.scale(
                  scale: _heartScaleAnimation.value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 90,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSingleMediaItem(PostMediaItem item, ThemeData theme) {
    if (item.isVideo) {
      return FeedVideoPlayer(
        media: item,
        onDoubleTap: _handleDoubleTap,
        onTap: widget.onMediaTap,
      );
    }

    final imageUrl = item.url;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl.startsWith('http'))
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildImagePlaceholder(theme),
            errorWidget: (_, __, dynamic ___) => _buildFallbackMedia(item),
          )
        else if (imageUrl.startsWith('assets/'))
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, dynamic ___) => _buildFallbackMedia(item),
          )
        else
          _buildFallbackMedia(item),
      ],
    );
  }

  /// Clean, elegant card for posts without attached media
  Widget _buildTextOnlyMedia(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onTap: widget.onMediaTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2C2C34), const Color(0xFF1B1B20)]
                : [const Color(0xFFF4F6F8), const Color(0xFFE5E9EE)],
          ),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.quote_bubble_fill,
              size: 28,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Text(
              widget.post.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return ColoredBox(
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF1E1E22)
          : const Color(0xFFF0F0F0),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFallbackMedia(PostMediaItem item) {
    if (widget.post.username.toLowerCase() == 'marvel') {
      return _buildLokiPosterFallback();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.isVideo ? CupertinoIcons.videocam_fill : Icons.image,
              size: 54,
              color: Colors.white70,
            ),
            const SizedBox(height: 8),
            Text(
              item.isVideo ? 'Video' : 'Photo',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Authentic cinematic Loki poster fallback that replicates reference image.
  Widget _buildLokiPosterFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.1),
          radius: 0.9,
          colors: [
            Color(0xFFE89A24),
            Color(0xFF8C5311),
            Color(0xFF2E1705),
            Color(0xFF0D0A07),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _ClockGearPainter(),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: Color(0xFFF3E5AB),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFF5722)),
                  ),
                  child: const Text(
                    'TVA COLLAR',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5722),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                Container(
                  color: const Color(0xFFE23636),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: const Text(
                    'MARVEL STUDIOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'LOKI',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Color(0xFFC0CA33),
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(Color primaryColor) {
    final mediaCount = widget.post.mediaItems.length;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 8),
      child: Row(
        children: [
          // Like Button
          ScaleTransition(
            scale: _likeBtnScaleAnimation,
            child: GestureDetector(
              onTap: _toggleLike,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  size: 26,
                  color: _isLiked ? const Color(0xFFED4956) : primaryColor,
                ),
              ),
            ),
          ),

          // Comment Button
          GestureDetector(
            onTap: widget.onCommentTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                CupertinoIcons.chat_bubble,
                size: 25,
                color: primaryColor,
              ),
            ),
          ),

          // Share / Direct Message Button
          GestureDetector(
            onTap: widget.onShareTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                CupertinoIcons.paperplane,
                size: 24,
                color: primaryColor,
              ),
            ),
          ),

          const Spacer(),

          // Centered dots indicator for carousel posts
          if (mediaCount > 1) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(mediaCount, (index) {
                final isCurrent = index == _currentCarouselIndex;
                return Container(
                  width: isCurrent ? 6 : 4.5,
                  height: isCurrent ? 6 : 4.5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? const Color(0xFF0095F6)
                        : Colors.grey.withValues(alpha: 0.45),
                  ),
                );
              }),
            ),
            const Spacer(),
          ],

          // Bookmark / Save Button
          ScaleTransition(
            scale: _saveBtnScaleAnimation,
            child: GestureDetector(
              onTap: _toggleSave,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                _isSaved
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                size: 24,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesSection(Color primaryColor, Color secondaryColor) {
    final hasLikedBy = widget.post.likedByUsername != null &&
        widget.post.likedByUsername!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: _likesCount == 0
          ? Text(
              'Be the first to like this',
              style: TextStyle(
                fontSize: 13,
                color: secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            )
          : RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.5,
                  color: primaryColor,
                  fontFamily: 'Inter',
                ),
                children: [
                  if (hasLikedBy) ...[
                    const TextSpan(text: 'Liked by '),
                    TextSpan(
                      text: widget.post.likedByUsername,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onProfileTap,
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: '${_numberFormat.format(_likesCount)} others',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    TextSpan(
                      text: '${_numberFormat.format(_likesCount)} likes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCaptionSection(
    Color primaryColor,
    Color secondaryColor,
    ThemeData theme,
  ) {
    // If text-only, content is already presented inside the card above
    if (widget.post.mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final caption = widget.post.caption;
    final isLong = caption.length > 70;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final displayText = (!_isCaptionExpanded && isLong)
              ? '${caption.substring(0, 70).trim()}...'
              : caption;

          return RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.5,
                color: primaryColor,
                height: 1.3,
                fontFamily: 'Inter',
              ),
              children: [
                // Username
                TextSpan(
                  text: '${widget.post.username} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onProfileTap,
                ),

                // Caption text with highlighted hashtags
                ..._parseCaptionTokens(
                  displayText,
                  primaryColor,
                  theme.colorScheme.primary,
                ),

                // "...more" button if collapsed
                if (!_isCaptionExpanded && isLong)
                  TextSpan(
                    text: '...more',
                    style: TextStyle(
                      color: secondaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() {
                          _isCaptionExpanded = true;
                        });
                      },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<TextSpan> _parseCaptionTokens(
    String text,
    Color defaultColor,
    Color accentColor,
  ) {
    final spans = <TextSpan>[];
    final words = text.split(' ');

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final suffix = i < words.length - 1 ? ' ' : '';

      if (word.startsWith('#') || word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: '$word$suffix',
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word$suffix',
            style: TextStyle(color: defaultColor),
          ),
        );
      }
    }

    return spans;
  }

  Widget _buildCommentsPrompt(Color secondaryColor) {
    final count = widget.post.commentsCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: GestureDetector(
        onTap: widget.onViewCommentsTap,
        child: Text(
          count > 0 ? 'View all $count comments' : 'Add a comment...',
          style: TextStyle(
            fontSize: 13.5,
            color: secondaryColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(Color secondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Text(
        widget.post.timeAgo,
        style: TextStyle(
          fontSize: 11,
          color: secondaryColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Custom painter for the clock gear background seen in the Loki poster
class _ClockGearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final paint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Radiating clock hands / spikes
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      final p1 = Offset(
        center.dx + 40 * (angle == 0 ? 0 : (angle / 1.5)),
        center.dy + 40 * (angle == 0 ? 0 : (angle / 1.5)),
      );
      final p2 = Offset(
        center.dx + 160 * (angle > 1.5 ? -1 : 1),
        center.dy + 160 * (angle < 3 ? -1 : 1),
      );
      canvas.drawLine(p1, p2, paint);
    }

    // Concentric clock rings
    canvas
      ..drawCircle(center, 50, paint)
      ..drawCircle(center, 90, paint)
      ..drawCircle(center, 140, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
