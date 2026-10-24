import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';

class GetFeedParam extends Equatable {
  const GetFeedParam({this.cursor, this.limit});

  final String? cursor;
  final int? limit;

  @override
  List<Object?> get props => [cursor];
}

class GetFeedUseCase implements UseCase<List<PostItem>, GetFeedParam> {
  const GetFeedUseCase({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;

  @override
  FutureResult<List<PostItem>> call(GetFeedParam params) {
    return _repository.getFeed(params.cursor, params.limit);
  }
}
