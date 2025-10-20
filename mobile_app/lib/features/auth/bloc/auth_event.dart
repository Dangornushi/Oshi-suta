import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check initial authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event when user attempts to login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event when user attempts to register
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nickname;
  final String clubId;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.nickname,
    required this.clubId,
  });

  @override
  List<Object?> get props => [email, password, nickname, clubId];
}

/// Event when user logs out
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Event to refresh user profile
class AuthProfileRefreshRequested extends AuthEvent {
  const AuthProfileRefreshRequested();
}
