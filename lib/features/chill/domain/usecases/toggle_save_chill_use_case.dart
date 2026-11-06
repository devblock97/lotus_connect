import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class ToggleSaveChillParams extends Equatable {
  const ToggleSaveChillParams({
    required this.chillId,
    required this.isSaved,
  });

  final String chillId;
  final bool isSaved;

  @override
  List<Object?> get props => [chillId, isSaved];
}

class ToggleSaveChillUseCase implements UseCase<bool, ToggleSaveChillParams> {
  const ToggleSaveChillUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<bool> call(ToggleSaveChillParams params) {
    return _repository.toggleSaveChill(
      params.chillId,
      isSaved: params.isSaved,
    );
  }
}
