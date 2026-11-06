import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class GetExploreChillsParams extends Equatable {
  const GetExploreChillsParams({this.cursor, this.limit, this.tag});

  final String? cursor;
  final int? limit;
  final String? tag;

  @override
  List<Object?> get props => [cursor, limit, tag];
}

class GetExploreChillsUseCase
    implements UseCase<List<ChillItem>, GetExploreChillsParams> {
  const GetExploreChillsUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<List<ChillItem>> call(GetExploreChillsParams params) {
    return _repository.getExploreChills(
      cursor: params.cursor,
      limit: params.limit,
      tag: params.tag,
    );
  }
}
