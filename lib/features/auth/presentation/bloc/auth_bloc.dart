import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final token = _authRepository.getCachedToken();
    final cachedUser = _authRepository.getCachedUser();

    if (token != null && cachedUser != null) {
      emit(Authenticated(cachedUser));
      try {
        // Refresh profile in background
        final updatedUser = await _authRepository.getProfile();
        if (updatedUser != null) {
          emit(Authenticated(updatedUser));
        }
      } catch (_) {
        // Keep cached state if offline or token still locally valid
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        department: event.department,
      );
      emit(Authenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(const Unauthenticated());
  }
}

