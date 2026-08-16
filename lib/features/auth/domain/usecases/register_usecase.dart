import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
  });

  final String username;
  final String email;
  final String password;
  final String? fullName;

  @override
  List<Object?> get props => [username, email, password, fullName];
}

class RegisterUseCase implements UseCase<User, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<User> call(RegisterParams params) {
    return _repository.register(
      username: params.username,
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}
