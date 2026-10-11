import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

abstract class FeedRepository {
  FutureResult<List<PostItem>> getFeed();

  FutureResult<PostItem> createPost({
    String? content,
    List<PostMediaItem>? mediaItems,
    String visibility = 'public',
  });

  FutureResult<PostItem> updatePost({
    required String postId,
    String? content,
    List<PostMediaItem>? mediaItems,
    String? visibility,
  });

  FutureResult<List<PostMediaItem>> uploadFiles(List<String> filePaths);

  FutureResult<bool> deletePost(String postId);
}
