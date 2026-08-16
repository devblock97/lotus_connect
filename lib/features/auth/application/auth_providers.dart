import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/notification/push_notification_service.dart';
import 'package:lotus_connect/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:lotus_connect/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:lotus_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lotus_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:lotus_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref: ref);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    pushNotificationService: ref.watch(pushNotificationServiceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});
