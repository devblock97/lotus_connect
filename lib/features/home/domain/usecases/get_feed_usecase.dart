import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';

/// Use case to fetch social feed posts.
class GetFeedUseCase implements UseCase<List<PostItem>, NoParams> {
  const GetFeedUseCase({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;

  @override
  FutureResult<List<PostItem>> call(NoParams params) {
    return _repository.getFeed();
  }
}
