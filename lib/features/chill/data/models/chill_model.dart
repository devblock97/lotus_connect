import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_audio.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

/// Data model representing a Chill response from `lotus_connect_system`.
/// Extends/maps seamlessly to domain entity [ChillItem].
@immutable
class ChillModel {
  const ChillModel({
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

  factory ChillModel.fromJson(Map<String, dynamic> json) {
    final item = ChillItem.fromJson(json);
    return ChillModel(
      id: item.id,
      author: item.author,
      postType: item.postType,
      caption: item.caption,
      mediaItems: item.mediaItems,
      videoUrl: item.videoUrl,
      thumbnailUrl: item.thumbnailUrl,
      duration: item.duration,
      width: item.width,
      height: item.height,
      aspectRatio: item.aspectRatio,
      audioTitle: item.audioTitle,
      audioArtist: item.audioArtist,
      audioUrl: item.audioUrl,
      audio: item.audio,
      remixParentId: item.remixParentId,
      isRemix: item.isRemix,
      likeCount: item.likeCount,
      commentCount: item.commentCount,
      shareCount: item.shareCount,
      viewCount: item.viewCount,
      userHasLiked: item.userHasLiked,
      userReaction: item.userReaction,
      userHasSaved: item.userHasSaved,
      isFollowingAuthor: item.isFollowingAuthor,
      tags: item.tags,
      metadata: item.metadata,
      visibility: item.visibility,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
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

  Map<String, dynamic> toJson() => toEntity().toJson();

  ChillItem toEntity() {
    return ChillItem(
      id: id,
      author: author,
      postType: postType,
      caption: caption,
      mediaItems: mediaItems,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      audioTitle: audioTitle,
      audioArtist: audioArtist,
      audioUrl: audioUrl,
      audio: audio,
      remixParentId: remixParentId,
      isRemix: isRemix,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      viewCount: viewCount,
      userHasLiked: userHasLiked,
      userReaction: userReaction,
      userHasSaved: userHasSaved,
      isFollowingAuthor: isFollowingAuthor,
      tags: tags,
      metadata: metadata,
      visibility: visibility,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
