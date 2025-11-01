import 'package:json_annotation/json_annotation.dart';

part 'club_model.g.dart';

/// Club model representing an idol club in the Oshi-Suta BATTLE app
@JsonSerializable()
class ClubModel {
  /// Unique identifier for the club
  @JsonKey(name: 'club_id')
  final String id;

  /// Name of the club
  final String name;

  /// Total points earned by the club
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Number of active members
  @JsonKey(name: 'active_members')
  final int memberCount;

  /// League ranking
  @JsonKey(name: 'league_rank')
  final int? rank;

  /// Year the club was founded
  @JsonKey(name: 'founded_year')
  final int? foundedYear;

  /// Stadium name
  final String? stadium;

  /// Stadium capacity
  @JsonKey(name: 'stadium_capacity')
  final int? stadiumCapacity;

  /// URL to the club's logo
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  /// English name
  @JsonKey(name: 'name_en')
  final String? nameEn;

  ClubModel({
    required this.id,
    required this.name,
    this.totalPoints = 0,
    this.memberCount = 0,
    this.rank,
    this.foundedYear,
    this.stadium,
    this.stadiumCapacity,
    this.logoUrl,
    this.nameEn,
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
    int? totalPoints,
    int? memberCount,
    int? rank,
    int? foundedYear,
    String? stadium,
    int? stadiumCapacity,
    String? logoUrl,
    String? nameEn,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalPoints: totalPoints ?? this.totalPoints,
      memberCount: memberCount ?? this.memberCount,
      rank: rank ?? this.rank,
      foundedYear: foundedYear ?? this.foundedYear,
      stadium: stadium ?? this.stadium,
      stadiumCapacity: stadiumCapacity ?? this.stadiumCapacity,
      logoUrl: logoUrl ?? this.logoUrl,
      nameEn: nameEn ?? this.nameEn,
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
        other.totalPoints == totalPoints &&
        other.memberCount == memberCount &&
        other.rank == rank &&
        other.foundedYear == foundedYear &&
        other.stadium == stadium &&
        other.stadiumCapacity == stadiumCapacity &&
        other.logoUrl == logoUrl &&
        other.nameEn == nameEn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        totalPoints.hashCode ^
        memberCount.hashCode ^
        rank.hashCode ^
        foundedYear.hashCode ^
        stadium.hashCode ^
        stadiumCapacity.hashCode ^
        logoUrl.hashCode ^
        nameEn.hashCode;
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
