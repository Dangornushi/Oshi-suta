import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model representing a user in the Oshi-Suta BATTLE app
@JsonSerializable()
class UserModel {
  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's display name
  final String username;

  /// ID of the club the user belongs to
  @JsonKey(name: 'club_id')
  final String? clubId;

  /// Total points earned by the user
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Total steps logged by the user
  @JsonKey(name: 'total_steps')
  final int totalSteps;

  /// Timestamp when the user was created
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the user was last updated
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Whether the user account is active
  @JsonKey(name: 'is_active')
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.clubId,
    this.totalPoints = 0,
    this.totalSteps = 0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Creates a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts UserModel to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Creates a copy of this UserModel with some fields replaced
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? clubId,
    int? totalPoints,
    int? totalSteps,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      clubId: clubId ?? this.clubId,
      totalPoints: totalPoints ?? this.totalPoints,
      totalSteps: totalSteps ?? this.totalSteps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, '
        'clubId: $clubId, totalPoints: $totalPoints, totalSteps: $totalSteps)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.clubId == clubId &&
        other.totalPoints == totalPoints &&
        other.totalSteps == totalSteps &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        clubId.hashCode ^
        totalPoints.hashCode ^
        totalSteps.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode;
  }
}
