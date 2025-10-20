// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubModel _$ClubModelFromJson(Map<String, dynamic> json) => ClubModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      rank: (json['rank'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClubModelToJson(ClubModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'total_points': instance.totalPoints,
      'member_count': instance.memberCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_active': instance.isActive,
      'rank': instance.rank,
    };

ClubStatsModel _$ClubStatsModelFromJson(Map<String, dynamic> json) =>
    ClubStatsModel(
      clubId: json['club_id'] as String,
      totalPoints: (json['total_points'] as num).toInt(),
      totalSteps: (json['total_steps'] as num).toInt(),
      memberCount: (json['member_count'] as num).toInt(),
      avgPointsPerMember: (json['avg_points_per_member'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
      todayPoints: (json['today_points'] as num?)?.toInt(),
      weekPoints: (json['week_points'] as num?)?.toInt(),
      monthPoints: (json['month_points'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClubStatsModelToJson(ClubStatsModel instance) =>
    <String, dynamic>{
      'club_id': instance.clubId,
      'total_points': instance.totalPoints,
      'total_steps': instance.totalSteps,
      'member_count': instance.memberCount,
      'avg_points_per_member': instance.avgPointsPerMember,
      'rank': instance.rank,
      'today_points': instance.todayPoints,
      'week_points': instance.weekPoints,
      'month_points': instance.monthPoints,
    };
