import 'package:json_annotation/json_annotation.dart';

part 'step_log_model.g.dart';

/// Step log model representing a daily step count entry
@JsonSerializable()
class StepLogModel {
  /// Unique identifier for the step log
  final String? id;

  /// ID of the user who logged the steps
  @JsonKey(name: 'user_id')
  final String userId;

  /// Number of steps taken
  final int steps;

  /// Points earned from the steps
  final int points;

  /// Date of the step log (YYYY-MM-DD format)
  final String date;

  /// Timestamp when the log was created
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Timestamp when the log was last updated
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Source of the step data (e.g., 'health_kit', 'google_fit', 'manual')
  final String? source;

  /// Whether the steps have been synced with the server
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isSynced;

  StepLogModel({
    this.id,
    required this.userId,
    required this.steps,
    required this.points,
    required this.date,
    this.createdAt,
    this.updatedAt,
    this.source,
    this.isSynced = false,
  });

  /// Creates a StepLogModel from JSON
  factory StepLogModel.fromJson(Map<String, dynamic> json) =>
      _$StepLogModelFromJson(json);

  /// Converts StepLogModel to JSON
  Map<String, dynamic> toJson() => _$StepLogModelToJson(this);

  /// Creates a copy of this StepLogModel with some fields replaced
  StepLogModel copyWith({
    String? id,
    String? userId,
    int? steps,
    int? points,
    String? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    bool? isSynced,
  }) {
    return StepLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      steps: steps ?? this.steps,
      points: points ?? this.points,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  String toString() {
    return 'StepLogModel(id: $id, userId: $userId, steps: $steps, '
        'points: $points, date: $date, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StepLogModel &&
        other.id == id &&
        other.userId == userId &&
        other.steps == steps &&
        other.points == points &&
        other.date == date &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.source == source &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        steps.hashCode ^
        points.hashCode ^
        date.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        source.hashCode ^
        isSynced.hashCode;
  }
}

/// Step statistics model
@JsonSerializable()
class StepStatsModel {
  /// Total steps
  @JsonKey(name: 'total_steps')
  final int totalSteps;

  /// Total points
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Steps today
  @JsonKey(name: 'today_steps')
  final int todaySteps;

  /// Steps this week
  @JsonKey(name: 'week_steps')
  final int weekSteps;

  /// Steps this month
  @JsonKey(name: 'month_steps')
  final int monthSteps;

  /// Average daily steps
  @JsonKey(name: 'avg_daily_steps')
  final double avgDailySteps;

  /// Best day (most steps)
  @JsonKey(name: 'best_day')
  final String? bestDay;

  /// Best day step count
  @JsonKey(name: 'best_day_steps')
  final int? bestDaySteps;

  /// Current streak in days
  @JsonKey(name: 'current_streak')
  final int currentStreak;

  /// Longest streak in days
  @JsonKey(name: 'longest_streak')
  final int longestStreak;

  StepStatsModel({
    required this.totalSteps,
    required this.totalPoints,
    required this.todaySteps,
    required this.weekSteps,
    required this.monthSteps,
    required this.avgDailySteps,
    this.bestDay,
    this.bestDaySteps,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  /// Creates a StepStatsModel from JSON
  factory StepStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StepStatsModelFromJson(json);

  /// Converts StepStatsModel to JSON
  Map<String, dynamic> toJson() => _$StepStatsModelToJson(this);

  @override
  String toString() {
    return 'StepStatsModel(totalSteps: $totalSteps, totalPoints: $totalPoints, '
        'todaySteps: $todaySteps, currentStreak: $currentStreak)';
  }
}

/// Request model for syncing steps
@JsonSerializable()
class SyncStepsRequest {
  /// List of step logs to sync
  final List<StepLogEntry> steps;

  SyncStepsRequest({required this.steps});

  /// Creates a SyncStepsRequest from JSON
  factory SyncStepsRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncStepsRequestFromJson(json);

  /// Converts SyncStepsRequest to JSON
  Map<String, dynamic> toJson() => _$SyncStepsRequestToJson(this);
}

/// Individual step log entry for syncing
@JsonSerializable()
class StepLogEntry {
  /// Date of the step log (YYYY-MM-DD format)
  final String date;

  /// Number of steps
  final int steps;

  /// Source of the data
  final String? source;

  StepLogEntry({
    required this.date,
    required this.steps,
    this.source,
  });

  /// Creates a StepLogEntry from JSON
  factory StepLogEntry.fromJson(Map<String, dynamic> json) =>
      _$StepLogEntryFromJson(json);

  /// Converts StepLogEntry to JSON
  Map<String, dynamic> toJson() => _$StepLogEntryToJson(this);
}

/// Response model for sync steps
@JsonSerializable()
class SyncStepsResponse {
  /// Number of steps synced
  @JsonKey(name: 'synced_count')
  final int syncedCount;

  /// Total points earned
  @JsonKey(name: 'total_points_earned')
  final int totalPointsEarned;

  /// List of synced step logs
  @JsonKey(name: 'step_logs')
  final List<StepLogModel>? stepLogs;

  /// Any error messages
  final String? message;

  SyncStepsResponse({
    required this.syncedCount,
    required this.totalPointsEarned,
    this.stepLogs,
    this.message,
  });

  /// Creates a SyncStepsResponse from JSON
  factory SyncStepsResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncStepsResponseFromJson(json);

  /// Converts SyncStepsResponse to JSON
  Map<String, dynamic> toJson() => _$SyncStepsResponseToJson(this);
}
