import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

/// Contract for the feed repository in the domain layer.
abstract class FeedRepository {
  /// Fetches social feed posts.
  FutureResult<List<PostItem>> getFeed();

  /// Creates a new social post with optional caption, media items, and
  /// visibility.
  FutureResult<PostItem> createPost({
    String? content,
    List<PostMediaItem>? mediaItems,
    String visibility = 'public',
  });

  /// Updates an existing post's caption, media items, or visibility.
  FutureResult<PostItem> updatePost({
    required String postId,
    String? content,
    List<PostMediaItem>? mediaItems,
    String? visibility,
  });

  /// Uploads media files (photos/videos) to backend storage.
  FutureResult<List<PostMediaItem>> uploadFiles(List<String> filePaths);

  /// Deletes an existing post.
  FutureResult<bool> deletePost(String postId);
}
