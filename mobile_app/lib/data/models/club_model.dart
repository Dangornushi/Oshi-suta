import 'package:json_annotation/json_annotation.dart';

part 'club_model.g.dart';

/// Club model representing an idol club in the Oshi-Suta BATTLE app
@JsonSerializable()
class ClubModel {
  /// Unique identifier for the club
  final String id;

  /// Name of the club
  final String name;

  /// Description of the club
  final String description;

  /// URL to the club's image/logo
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// Total points earned by the club
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Number of members in the club
  @JsonKey(name: 'member_count')
  final int memberCount;

  /// Timestamp when the club was created
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the club was last updated
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Whether the club is active
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Club's current rank (optional, may be calculated)
  final int? rank;

  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.totalPoints = 0,
    this.memberCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.rank,
  });

  /// Creates a ClubModel from JSON
  factory ClubModel.fromJson(Map<String, dynamic> json) =>
      _$ClubModelFromJson(json);

  /// Converts ClubModel to JSON
  Map<String, dynamic> toJson() => _$ClubModelToJson(this);

  /// Creates a copy of this ClubModel with some fields replaced
  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? totalPoints,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? rank,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rank: rank ?? this.rank,
    );
  }

  @override
  String toString() {
    return 'ClubModel(id: $id, name: $name, totalPoints: $totalPoints, '
        'memberCount: $memberCount, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClubModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.totalPoints == totalPoints &&
        other.memberCount == memberCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.rank == rank;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        totalPoints.hashCode ^
        memberCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode ^
        rank.hashCode;
  }
}

/// Club statistics model
@JsonSerializable()
class ClubStatsModel {
  /// Club ID
  @JsonKey(name: 'club_id')
  final String clubId;

  /// Total points earned by the club
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Total steps by all members
  @JsonKey(name: 'total_steps')
  final int totalSteps;

  /// Number of active members
  @JsonKey(name: 'member_count')
  final int memberCount;

  /// Average points per member
  @JsonKey(name: 'avg_points_per_member')
  final double avgPointsPerMember;

  /// Current rank
  final int rank;

  /// Points earned today
  @JsonKey(name: 'today_points')
  final int? todayPoints;

  /// Points earned this week
  @JsonKey(name: 'week_points')
  final int? weekPoints;

  /// Points earned this month
  @JsonKey(name: 'month_points')
  final int? monthPoints;

  ClubStatsModel({
    required this.clubId,
    required this.totalPoints,
    required this.totalSteps,
    required this.memberCount,
    required this.avgPointsPerMember,
    required this.rank,
    this.todayPoints,
    this.weekPoints,
    this.monthPoints,
  });

  /// Creates a ClubStatsModel from JSON
  factory ClubStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ClubStatsModelFromJson(json);

  /// Converts ClubStatsModel to JSON
  Map<String, dynamic> toJson() => _$ClubStatsModelToJson(this);

  @override
  String toString() {
    return 'ClubStatsModel(clubId: $clubId, totalPoints: $totalPoints, '
        'rank: $rank, memberCount: $memberCount)';
  }
}
