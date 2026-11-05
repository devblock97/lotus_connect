import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_upload_result.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class UploadChillVideoParams extends Equatable {
  const UploadChillVideoParams({required this.filePath});

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class UploadChillVideoUseCase
    implements UseCase<ChillUploadResult, UploadChillVideoParams> {
  const UploadChillVideoUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<ChillUploadResult> call(UploadChillVideoParams params) {
    return _repository.uploadChillVideo(params.filePath);
  }
}
