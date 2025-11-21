import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/api_error.dart';
import 'providers.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final Map<String, String>? validationErrors;

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.validationErrors,
  });
  
  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    Map<String, String>? validationErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      validationErrors: validationErrors,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).message;
    }
    return error.toString();
  }

  Map<String, String>? _extractValidationErrors(dynamic error) {
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).validationErrors;
    }
    return null;
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.login(username, password);
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
        validationErrors: _extractValidationErrors(e),
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.register(username, email, password);
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _extractErrorMessage(e),
        validationErrors: _extractValidationErrors(e),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
