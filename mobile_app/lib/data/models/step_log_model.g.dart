// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepLogModel _$StepLogModelFromJson(Map<String, dynamic> json) => StepLogModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      steps: (json['steps'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      date: json['date'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$StepLogModelToJson(StepLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'steps': instance.steps,
      'points': instance.points,
      'date': instance.date,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'source': instance.source,
    };

StepStatsModel _$StepStatsModelFromJson(Map<String, dynamic> json) =>
    StepStatsModel(
      totalSteps: (json['total_steps'] as num).toInt(),
      totalPoints: (json['total_points'] as num).toInt(),
      todaySteps: (json['today_steps'] as num).toInt(),
      weekSteps: (json['week_steps'] as num).toInt(),
      monthSteps: (json['month_steps'] as num).toInt(),
      avgDailySteps: (json['avg_daily_steps'] as num).toDouble(),
      bestDay: json['best_day'] as String?,
      bestDaySteps: (json['best_day_steps'] as num?)?.toInt(),
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StepStatsModelToJson(StepStatsModel instance) =>
    <String, dynamic>{
      'total_steps': instance.totalSteps,
      'total_points': instance.totalPoints,
      'today_steps': instance.todaySteps,
      'week_steps': instance.weekSteps,
      'month_steps': instance.monthSteps,
      'avg_daily_steps': instance.avgDailySteps,
      'best_day': instance.bestDay,
      'best_day_steps': instance.bestDaySteps,
      'current_streak': instance.currentStreak,
      'longest_streak': instance.longestStreak,
    };

SyncStepsRequest _$SyncStepsRequestFromJson(Map<String, dynamic> json) =>
    SyncStepsRequest(
      steps: (json['steps'] as List<dynamic>)
          .map((e) => StepLogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncStepsRequestToJson(SyncStepsRequest instance) =>
    <String, dynamic>{
      'steps': instance.steps,
    };

StepLogEntry _$StepLogEntryFromJson(Map<String, dynamic> json) => StepLogEntry(
      date: json['date'] as String,
      steps: (json['steps'] as num).toInt(),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$StepLogEntryToJson(StepLogEntry instance) =>
    <String, dynamic>{
      'date': instance.date,
      'steps': instance.steps,
      'source': instance.source,
    };

SyncStepsResponse _$SyncStepsResponseFromJson(Map<String, dynamic> json) =>
    SyncStepsResponse(
      syncedCount: (json['synced_count'] as num).toInt(),
      totalPointsEarned: (json['total_points_earned'] as num).toInt(),
      stepLogs: (json['step_logs'] as List<dynamic>?)
          ?.map((e) => StepLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SyncStepsResponseToJson(SyncStepsResponse instance) =>
    <String, dynamic>{
      'synced_count': instance.syncedCount,
      'total_points_earned': instance.totalPointsEarned,
      'step_logs': instance.stepLogs,
      'message': instance.message,
    };
