import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

@immutable
class ProfileMediaItem extends Equatable {
  const ProfileMediaItem({
    required this.postId,
    required this.author,
    required this.url,
    this.mediaIndex = 0,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.mediaType = 'image',
    this.duration,
    this.width,
    this.height,
    this.caption = '',
    this.visibility = 'public',
    this.likeCount = 0,
    this.commentCount = 0,
    this.userHasLiked = false,
    this.userReaction,
    this.createdAt,
  });

  factory ProfileMediaItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final rawAuthor = json['author'];
    final author = rawAuthor is Map<String, dynamic>
        ? PostAuthor.fromJson(rawAuthor)
        : PostAuthor(
            id: json['authorId'] as String? ?? '',
            username: json['username'] as String? ?? 'user',
          );

    return ProfileMediaItem(
      postId: (json['postId'] ?? json['id'] ?? '') as String,
      author: author,
      mediaIndex: (json['mediaIndex'] as num?)?.toInt() ?? 0,
      url: (json['url'] ?? '') as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      mediaType: (json['mediaType'] ?? 'image') as String,
      duration: (json['duration'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      caption: (json['caption'] ?? '') as String,
      visibility: (json['visibility'] ?? 'public') as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      userHasLiked: json['userHasLiked'] as bool? ?? false,
      userReaction: json['userReaction'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }

  final String postId;
  final PostAuthor author;
  final int mediaIndex;
  final String url;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final String mediaType;
  final int? duration;
  final int? width;
  final int? height;
  final String caption;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final bool userHasLiked;
  final String? userReaction;
  final DateTime? createdAt;

  bool get isVideo =>
      mediaType.toLowerCase() == 'video' ||
      (mimeType?.toLowerCase().startsWith('video/') ?? false) ||
      url.toLowerCase().endsWith('.mp4') ||
      url.toLowerCase().endsWith('.mov') ||
      url.toLowerCase().endsWith('.m3u8');

  String get formattedDuration {
    final secs = duration;
    if (secs == null || secs <= 0) return '';
    final mins = secs ~/ 60;
    final remSecs = secs % 60;
    return '$mins:${remSecs.toString().padLeft(2, '0')}';
  }

  PostMediaItem toPostMediaItem() => PostMediaItem(
        url: url,
        thumbnailUrl: thumbnailUrl,
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
        duration: duration,
        width: width,
        height: height,
      );

  PostItem toPostItem() => PostItem(
        id: postId,
        author: author,
        content: caption,
        mediaItems: [toPostMediaItem()],
        visibility: visibility,
        likeCount: likeCount,
        commentCount: commentCount,
        userHasLiked: userHasLiked,
        userReaction: userReaction,
        createdAt: createdAt,
      );

  ProfileMediaItem normalizedForHost(String serverHost) {
    return ProfileMediaItem(
      postId: postId,
      author: author.copyWith(
        avatarUrl: author.avatarUrl != null && author.avatarUrl!.isNotEmpty
            ? normalizeMediaUrl(author.avatarUrl!, serverHost: serverHost)
            : author.avatarUrl,
      ),
      mediaIndex: mediaIndex,
      url: normalizeMediaUrl(url, serverHost: serverHost),
      thumbnailUrl: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
          ? normalizeMediaUrl(thumbnailUrl!, serverHost: serverHost)
          : thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      mediaType: mediaType,
      duration: duration,
      width: width,
      height: height,
      caption: caption,
      visibility: visibility,
      likeCount: likeCount,
      commentCount: commentCount,
      userHasLiked: userHasLiked,
      userReaction: userReaction,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        postId,
        author,
        mediaIndex,
        url,
        thumbnailUrl,
        fileName,
        fileSize,
        mimeType,
        mediaType,
        duration,
        width,
        height,
        caption,
        visibility,
        likeCount,
        commentCount,
        userHasLiked,
        userReaction,
        createdAt,
      ];
}
