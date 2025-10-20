import 'package:equatable/equatable.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking authentication status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String nickname;
  final String clubId;
  final int? totalPoints;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.clubId,
    this.totalPoints,
  });

  @override
  List<Object?> get props => [userId, email, nickname, clubId, totalPoints];

  /// Create a copy with updated fields
  AuthAuthenticated copyWith({
    String? userId,
    String? email,
    String? nickname,
    String? clubId,
    int? totalPoints,
  }) {
    return AuthAuthenticated(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      clubId: clubId ?? this.clubId,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication in progress (login/register)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authentication failed
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
