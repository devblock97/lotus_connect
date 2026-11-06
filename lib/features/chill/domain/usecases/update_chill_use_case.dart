import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/entities/update_chill_params.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class UpdateChillUseCase implements UseCase<ChillItem, UpdateChillParams> {
  const UpdateChillUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<ChillItem> call(UpdateChillParams params) {
    return _repository.updateChill(params);
  }
}
