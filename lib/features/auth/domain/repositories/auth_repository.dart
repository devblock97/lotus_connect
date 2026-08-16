import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  FutureResult<User> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  });

  FutureResult<User> login({
    required String email,
    required String password,
    String? platform,
    String? deviceToken,
  });

  FutureResult<void> logout();

  FutureResult<User?> getCachedUser();
}
