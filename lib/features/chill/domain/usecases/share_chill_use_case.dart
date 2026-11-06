import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class ShareChillParams extends Equatable {
  const ShareChillParams({required this.chillId});

  final String chillId;

  @override
  List<Object?> get props => [chillId];
}

class ShareChillUseCase implements UseCase<ChillItem, ShareChillParams> {
  const ShareChillUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<ChillItem> call(ShareChillParams params) {
    return _repository.shareChill(params.chillId);
  }
}
