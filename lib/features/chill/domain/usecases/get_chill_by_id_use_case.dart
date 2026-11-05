import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class GetChillByIdParams extends Equatable {
  const GetChillByIdParams({required this.chillId});

  final String chillId;

  @override
  List<Object?> get props => [chillId];
}

class GetChillByIdUseCase implements UseCase<ChillItem, GetChillByIdParams> {
  const GetChillByIdUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<ChillItem> call(GetChillByIdParams params) {
    return _repository.getChillById(params.chillId);
  }
}
