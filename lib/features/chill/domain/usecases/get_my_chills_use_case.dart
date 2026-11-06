import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class GetMyChillsParams extends Equatable {
  const GetMyChillsParams({this.cursor, this.limit});

  final String? cursor;
  final int? limit;

  @override
  List<Object?> get props => [cursor, limit];
}

class GetMyChillsUseCase
    implements UseCase<List<ChillItem>, GetMyChillsParams> {
  const GetMyChillsUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<List<ChillItem>> call(GetMyChillsParams params) {
    return _repository.getMyChills(
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
