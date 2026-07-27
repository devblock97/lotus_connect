import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/api/auth_service.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';

/// State object representing Auth session details.
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

/// Riverpod state notifier to manage user registration, login and session lifecycle.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref, this._authService) : super(const AuthState()) {
    _ref.listen<String>(
      settingsProvider.select((s) => s.accessToken),
      (prev, next) {
        if (next.isEmpty && state.user != null) {
          state = const AuthState();
        }
      },
    );
  }

  final Ref _ref;
  final AuthService _authService;

  /// Registration action.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.register(
        username: username,
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Login action. Updates SQLite settings store with JWT token pairs.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credentials = await _authService.login(
        email: email,
        password: password,
      );
      final user = credentials['user'] as User;
      final accessToken = credentials['accessToken'] as String;
      final refreshToken = credentials['refreshToken'] as String;

      // Persist auth tokens securely in local SQLite settings database
      final settingsNotifier = _ref.read(settingsProvider.notifier);
      await settingsNotifier.setTokens(accessToken, refreshToken);

      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Logout action. Invalidates server session and drops token states.
  Future<void> logout() async {
    final settings = _ref.read(settingsProvider);
    final settingsNotifier = _ref.read(settingsProvider.notifier);

    if (settings.refreshToken.isNotEmpty) {
      await _authService.logout(refreshToken: settings.refreshToken);
    }

    await settingsNotifier.clearTokens();
    state = const AuthState();
  }
}

/// Provider for Auth Service client.
final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthService(dioClient: dioClient);
});

/// Global provider to watch authentication state actions.
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(ref, authService);
});
