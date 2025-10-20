import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthProfileRefreshRequested>(_onAuthProfileRefreshRequested);
  }

  /// Check if user is already authenticated
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = _authRepository.isLoggedIn();

      if (isLoggedIn) {
        // User is logged in, get saved user info
        final userId = _authRepository.getUserId();
        final email = _authRepository.getUserEmail();
        final clubId = _authRepository.getClubId();

        if (userId != null && email != null && clubId != null) {
          emit(AuthAuthenticated(
            userId: userId,
            email: email,
            nickname: '', // Will be loaded from profile
            clubId: clubId,
          ));

          // Fetch full profile in the background
          add(const AuthProfileRefreshRequested());
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('認証状態の確認に失敗しました: ${e.toString()}'));
    }
  }

  /// Handle login request
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Call login API
      final authResponse = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      // Emit authenticated state with user info from login response
      emit(AuthAuthenticated(
        userId: authResponse.userId,
        email: authResponse.email,
        nickname: authResponse.nickname,
        clubId: authResponse.clubId,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle register request
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Call register API
      final authResponse = await _authRepository.register(
        email: event.email,
        password: event.password,
        nickname: event.nickname,
        clubId: event.clubId,
      );

      // Emit authenticated state with user info from register response
      emit(AuthAuthenticated(
        userId: authResponse.userId,
        email: authResponse.email,
        nickname: authResponse.nickname,
        clubId: authResponse.clubId,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle logout request
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('ログアウトに失敗しました: ${e.toString()}'));
    }
  }

  /// Refresh user profile (get detailed information)
  Future<void> _onAuthProfileRefreshRequested(
    AuthProfileRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    try {
      final currentState = state as AuthAuthenticated;

      // Fetch full profile from API
      final profile = await _authRepository.getProfile();

      // Update state with detailed profile information
      emit(currentState.copyWith(
        nickname: profile.nickname,
        totalPoints: profile.totalPoints,
      ));
    } catch (e) {
      // Don't change state on profile refresh failure
      // User is still authenticated, just couldn't get updated profile
      print('プロフィールの更新に失敗しました: $e');
    }
  }
}
