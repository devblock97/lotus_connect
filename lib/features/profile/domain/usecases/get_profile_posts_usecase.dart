import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class GetProfilePostsParams {
  const GetProfilePostsParams({
    this.userId,
    this.filter,
    this.cursor,
    this.limit = 15,
  });

  final String? userId;
  final String? filter;
  final String? cursor;
  final int? limit;
}

class GetProfilePostsUseCase
    implements UseCase<List<PostItem>, GetProfilePostsParams> {
  const GetProfilePostsUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<List<PostItem>> call(GetProfilePostsParams params) {
    return _repository.getUserPosts(
      userId: params.userId,
      filter: params.filter,
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
