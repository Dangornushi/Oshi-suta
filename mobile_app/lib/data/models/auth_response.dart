import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

/// Login/Register response model
@JsonSerializable()
class AuthResponse {
  /// JWT access token
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// Token type (usually "bearer")
  @JsonKey(name: 'token_type')
  final String tokenType;

  /// User ID
  @JsonKey(name: 'user_id')
  final String userId;

  /// User email
  final String email;

  /// User nickname
  final String nickname;

  /// Club ID
  @JsonKey(name: 'club_id')
  final String clubId;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.nickname,
    required this.clubId,
  });

  /// Creates an AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  /// Converts AuthResponse to JSON
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  String toString() {
    return 'AuthResponse(userId: $userId, email: $email, nickname: $nickname, clubId: $clubId)';
  }
}

/// User profile response model (detailed information)
@JsonSerializable()
class UserProfileResponse {
  /// User ID
  @JsonKey(name: 'user_id')
  final String userId;

  /// User email
  final String email;

  /// User nickname
  final String nickname;

  /// Club ID
  @JsonKey(name: 'club_id')
  final String clubId;

  /// Total points earned
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Account creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Last update timestamp
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  UserProfileResponse({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.clubId,
    required this.totalPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserProfileResponse from JSON
  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);

  /// Converts UserProfileResponse to JSON
  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);

  @override
  String toString() {
    return 'UserProfileResponse(userId: $userId, email: $email, nickname: $nickname, clubId: $clubId, totalPoints: $totalPoints)';
  }
}
