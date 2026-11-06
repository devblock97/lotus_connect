import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class GetUserChillsParams extends Equatable {
  const GetUserChillsParams({
    required this.userId,
    this.cursor,
    this.limit,
  });

  final String userId;
  final String? cursor;
  final int? limit;

  @override
  List<Object?> get props => [userId, cursor, limit];
}

class GetUserChillsUseCase
    implements UseCase<List<ChillItem>, GetUserChillsParams> {
  const GetUserChillsUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<List<ChillItem>> call(GetUserChillsParams params) {
    return _repository.getUserChills(
      params.userId,
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
