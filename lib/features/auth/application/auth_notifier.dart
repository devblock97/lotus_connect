import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/notification/push_notification_service.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/application/auth_providers.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lotus_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  final User? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._ref, {
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthState()) {
    _ref.listen<String>(
      settingsProvider.select((s) => s.accessToken),
      (prev, next) {
        if (next.isEmpty && state.user != null) {
          state = const AuthState();
        }
      },
    );
    _initSession();
  }

  final Ref _ref;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  Future<void> _initSession() async {
    final result = await _getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) => null,
      (user) {
        if (user != null) {
          state = AuthState(user: user);
          Future.microtask(() {
            _ref.read(pushNotificationServiceProvider).syncDeviceToken();
          });
        }
      },
    );
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _registerUseCase(
      RegisterParams(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _loginUseCase(
      LoginParams(
        email: email,
        password: password,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = AuthState(user: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _logoutUseCase(const NoParams());
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref,
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});
