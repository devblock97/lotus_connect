import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class DeleteChillParams extends Equatable {
  const DeleteChillParams({required this.chillId});

  final String chillId;

  @override
  List<Object?> get props => [chillId];
}

class DeleteChillUseCase implements UseCase<bool, DeleteChillParams> {
  const DeleteChillUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<bool> call(DeleteChillParams params) {
    return _repository.deleteChill(params.chillId);
  }
}
