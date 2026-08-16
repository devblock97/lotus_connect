import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/auth/domain/repositories/auth_repository.dart';

class LoginParams extends Equatable {
  const LoginParams({
    required this.email,
    required this.password,
    this.platform,
    this.deviceToken,
  });

  final String email;
  final String password;
  final String? platform;
  final String? deviceToken;

  @override
  List<Object?> get props => [email, password, platform, deviceToken];
}

class LoginUseCase implements UseCase<User, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<User> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
      platform: params.platform,
      deviceToken: params.deviceToken,
    );
  }
}
