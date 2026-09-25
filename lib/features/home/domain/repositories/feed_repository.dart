import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';

/// Contract for the feed repository in the domain layer.
abstract class FeedRepository {
  /// Fetches social feed posts.
  FutureResult<List<PostItem>> getFeed();
}
