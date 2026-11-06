import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_audio.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

@immutable
class ChillItem {
  const ChillItem({
    required this.id,
    required this.author,
    required this.videoUrl,
    required this.createdAt,
    this.postType = 'chill',
    this.caption = '',
    this.mediaItems = const [],
    this.thumbnailUrl,
    this.duration = 0.0,
    this.width,
    this.height,
    this.aspectRatio = 9 / 16,
    this.audioTitle,
    this.audioArtist,
    this.audioUrl,
    this.audio,
    this.remixParentId,
    this.isRemix = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.userHasLiked = false,
    this.userReaction,
    this.userHasSaved = false,
    this.isFollowingAuthor = false,
    this.tags = const [],
    this.metadata,
    this.visibility = 'public',
    this.updatedAt,
  });

  /// Creates a [ChillItem] from a unified [PostItem] (e.g. when opening a video post in full-screen Chills).
  factory ChillItem.fromPostItem(PostItem post) {
    final videoMedia = post.mediaItems.firstWhere(
      (m) => m.isVideo,
      orElse: () => post.mediaItems.isNotEmpty
          ? post.mediaItems.first
          : const PostMediaItem(url: '', mimeType: 'video/mp4'),
    );

    return ChillItem(
      id: post.id,
      author: post.author,
      postType: post.postType,
      caption: post.content,
      mediaItems: post.mediaItems,
      videoUrl: videoMedia.url,
      thumbnailUrl: videoMedia.thumbnailUrl,
      duration: videoMedia.duration?.toDouble() ?? 0.0,
      width: videoMedia.width,
      height: videoMedia.height,
      aspectRatio: videoMedia.aspectRatio > 0 ? videoMedia.aspectRatio : 9 / 16,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      shareCount: post.shareCount,
      viewCount: post.viewCount,
      userHasLiked: post.userHasLiked,
      userReaction: post.userReaction,
      userHasSaved: post.isSaved,
      visibility: post.visibility,
      createdAt: post.createdAt ?? DateTime.now(),
      updatedAt: post.updatedAt,
    );
  }

  factory ChillItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseOptionalDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final rawAuthor = json['author'];
    final author = rawAuthor is Map<String, dynamic>
        ? PostAuthor.fromJson(rawAuthor)
        : PostAuthor(
            id: json['authorId'] as String? ??
                json['author_id'] as String? ??
                '',
            username: json['username'] as String? ?? 'user',
          );

    final rawMedia = json['mediaItems'] ?? json['media_items'];
    final mediaList = <PostMediaItem>[];
    if (rawMedia is List) {
      for (final m in rawMedia) {
        if (m is Map<String, dynamic>) {
          mediaList.add(PostMediaItem.fromJson(m));
        }
      }
    }

    // Resolve primary video URL: top-level field or first media item
    var videoUrl = (json['videoUrl'] ??
        json['video_url'] ??
        json['mediaUrl'] ??
        json['media_url'] ??
        '') as String;
    if (videoUrl.isEmpty && mediaList.isNotEmpty) {
      videoUrl = mediaList.first.url;
    }

    // Resolve thumbnail
    var thumbnailUrl = (json['thumbnailUrl'] ??
        json['thumbnail_url'] ??
        json['thumbUrl'] ??
        json['thumb_url']) as String?;
    if (thumbnailUrl == null && mediaList.isNotEmpty) {
      thumbnailUrl = mediaList.first.thumbnailUrl;
    }

    // Resolve dimensions & duration
    final width = (json['width'] as num?)?.toInt() ??
        (mediaList.isNotEmpty ? mediaList.first.width : null);
    final height = (json['height'] as num?)?.toInt() ??
        (mediaList.isNotEmpty ? mediaList.first.height : null);

    final duration = (json['duration'] as num?)?.toDouble() ??
        (mediaList.isNotEmpty
            ? (mediaList.first.duration?.toDouble() ?? 0.0)
            : 0.0);

    // Calculate aspect ratio (default vertical 9:16 = 0.5625)
    var calculatedAspectRatio = 9 / 16;
    if (width != null && height != null && height > 0) {
      calculatedAspectRatio = width / height;
    } else if (json['aspectRatio'] != null || json['aspect_ratio'] != null) {
      calculatedAspectRatio =
          ((json['aspectRatio'] ?? json['aspect_ratio']) as num).toDouble();
    } else if (mediaList.isNotEmpty && mediaList.first.aspectRatio > 0) {
      calculatedAspectRatio = mediaList.first.aspectRatio;
    }

    // Resolve Audio information
    final audioTitle = (json['audioTitle'] ?? json['audio_title']) as String?;
    final audioArtist =
        (json['audioArtist'] ?? json['audio_artist']) as String?;
    final audioUrl = (json['audioUrl'] ?? json['audio_url']) as String?;

    final rawAudio = json['audio'] ?? json['music'] ?? json['sound'];
    ChillAudio? audio;
    if (rawAudio is Map<String, dynamic>) {
      audio = ChillAudio.fromJson(rawAudio);
    } else if (audioTitle != null || audioArtist != null || audioUrl != null) {
      audio = ChillAudio(
        title: audioTitle ?? 'Original Audio',
        artist: audioArtist ?? author.fullName ?? author.username,
        audioUrl: audioUrl,
        isOriginal: audioUrl == null,
      );
    }

    // Resolve tags
    final rawTags = json['tags'] ?? json['hashtags'];
    final tagsList = <String>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t != null) tagsList.add(t.toString());
      }
    }

    final rawMetadata = json['metadata'];
    final metadataMap = rawMetadata is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawMetadata)
        : null;

    final remixParentId = (json['remixParentId'] ??
        json['remix_parent_id'] ??
        json['remixParentChillId'] ??
        json['remix_parent_chill_id']) as String?;

    return ChillItem(
      id: json['id'] as String? ?? '',
      author: author,
      postType: json['postType'] as String? ??
          json['post_type'] as String? ??
          'chill',
      caption: (json['content'] ?? json['caption'] ?? json['description'])
              as String? ??
          '',
      mediaItems: mediaList,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      width: width,
      height: height,
      aspectRatio: calculatedAspectRatio,
      audioTitle: audioTitle ?? audio?.title,
      audioArtist: audioArtist ?? audio?.artist,
      audioUrl: audioUrl ?? audio?.audioUrl,
      audio: audio,
      remixParentId: remixParentId,
      isRemix: (json['isRemix'] ?? json['is_remix']) as bool? ??
          (remixParentId != null),
      likeCount: (json['likeCount'] ?? json['like_count']) as int? ?? 0,
      commentCount:
          (json['commentCount'] ?? json['comment_count']) as int? ?? 0,
      shareCount: (json['shareCount'] ?? json['share_count']) as int? ?? 0,
      viewCount: (json['viewCount'] ?? json['view_count']) as int? ?? 0,
      userHasLiked: (json['userHasLiked'] ??
              json['user_has_liked'] ??
              json['isLiked'] ??
              json['is_liked']) as bool? ??
          false,
      userReaction: (json['userReaction'] ?? json['user_reaction']) as String?,
      userHasSaved: (json['userHasSaved'] ??
              json['user_has_saved'] ??
              json['isSaved'] ??
              json['is_saved']) as bool? ??
          false,
      isFollowingAuthor: (json['isFollowingAuthor'] ??
              json['is_following_author'] ??
              json['isFollowing'] ??
              json['is_following']) as bool? ??
          false,
      tags: tagsList,
      metadata: metadataMap,
      visibility: json['visibility'] as String? ?? 'public',
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseOptionalDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  final String id;
  final PostAuthor author;
  final String postType;
  final String caption;
  final List<PostMediaItem> mediaItems;
  final String videoUrl;
  final String? thumbnailUrl;
  final double duration;
  final int? width;
  final int? height;
  final double aspectRatio;
  final String? audioTitle;
  final String? audioArtist;
  final String? audioUrl;
  final ChillAudio? audio;
  final String? remixParentId;
  final bool isRemix;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final bool userHasLiked;
  final String? userReaction;
  final bool userHasSaved;
  final bool isFollowingAuthor;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final String visibility;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Converts this [ChillItem] to a unified [PostItem] for shared components (e.g. comments & options sheets).
  PostItem toPostItem() {
    final items = mediaItems.isNotEmpty
        ? mediaItems
        : <PostMediaItem>[
            PostMediaItem(
              url: videoUrl,
              thumbnailUrl: thumbnailUrl,
              mimeType: 'video/mp4',
              duration: duration.round(),
              width: width,
              height: height,
            ),
          ];

    return PostItem(
      id: id,
      author: author,
      postType: postType,
      content: caption,
      mediaItems: items,
      visibility: visibility,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      viewCount: viewCount,
      userHasLiked: userHasLiked,
      userReaction: userReaction,
      isSaved: userHasSaved,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'postType': postType,
        'content': caption,
        'caption': caption,
        if (mediaItems.isNotEmpty)
          'mediaItems': mediaItems.map((m) => m.toJson()).toList(),
        'videoUrl': videoUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'duration': duration,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'aspectRatio': aspectRatio,
        if (audioTitle != null) 'audioTitle': audioTitle,
        if (audioArtist != null) 'audioArtist': audioArtist,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (audio != null) 'audio': audio!.toJson(),
        if (remixParentId != null) 'remixParentId': remixParentId,
        'isRemix': isRemix,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'shareCount': shareCount,
        'viewCount': viewCount,
        'userHasLiked': userHasLiked,
        if (userReaction != null) 'userReaction': userReaction,
        'userHasSaved': userHasSaved,
        'isFollowingAuthor': isFollowingAuthor,
        'tags': tags,
        if (metadata != null) 'metadata': metadata,
        'visibility': visibility,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  ChillItem copyWith({
    String? id,
    PostAuthor? author,
    String? postType,
    String? caption,
    List<PostMediaItem>? mediaItems,
    String? videoUrl,
    String? thumbnailUrl,
    double? duration,
    int? width,
    int? height,
    double? aspectRatio,
    String? audioTitle,
    String? audioArtist,
    String? audioUrl,
    ChillAudio? audio,
    String? remixParentId,
    bool? isRemix,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? viewCount,
    bool? userHasLiked,
    String? userReaction,
    bool? userHasSaved,
    bool? isFollowingAuthor,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChillItem(
      id: id ?? this.id,
      author: author ?? this.author,
      postType: postType ?? this.postType,
      caption: caption ?? this.caption,
      mediaItems: mediaItems ?? this.mediaItems,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      audioTitle: audioTitle ?? this.audioTitle,
      audioArtist: audioArtist ?? this.audioArtist,
      audioUrl: audioUrl ?? this.audioUrl,
      audio: audio ?? this.audio,
      remixParentId: remixParentId ?? this.remixParentId,
      isRemix: isRemix ?? this.isRemix,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      viewCount: viewCount ?? this.viewCount,
      userHasLiked: userHasLiked ?? this.userHasLiked,
      userReaction: userReaction ?? this.userReaction,
      userHasSaved: userHasSaved ?? this.userHasSaved,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChillItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          author == other.author &&
          videoUrl == other.videoUrl &&
          userHasLiked == other.userHasLiked &&
          likeCount == other.likeCount &&
          commentCount == other.commentCount &&
          shareCount == other.shareCount &&
          viewCount == other.viewCount &&
          userHasSaved == other.userHasSaved;

  @override
  int get hashCode => Object.hash(
        id,
        author,
        videoUrl,
        userHasLiked,
        likeCount,
        commentCount,
        shareCount,
        viewCount,
        userHasSaved,
      );
}
