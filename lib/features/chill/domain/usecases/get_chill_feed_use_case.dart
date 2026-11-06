import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class GetChillFeedParams extends Equatable {
  const GetChillFeedParams({this.cursor, this.limit, this.tag});

  final String? cursor;
  final int? limit;
  final String? tag;

  @override
  List<Object?> get props => [cursor, limit, tag];
}

class GetChillFeedUseCase
    implements UseCase<List<ChillItem>, GetChillFeedParams> {
  const GetChillFeedUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<List<ChillItem>> call(GetChillFeedParams params) {
    return _repository.getChillFeed(
      cursor: params.cursor,
      limit: params.limit,
      tag: params.tag,
    );
  }
}
