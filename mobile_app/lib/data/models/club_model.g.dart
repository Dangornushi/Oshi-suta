// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubModel _$ClubModelFromJson(Map<String, dynamic> json) => ClubModel(
      id: json['club_id'] as String,
      name: json['name'] as String,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      memberCount: (json['active_members'] as num?)?.toInt() ?? 0,
      rank: (json['league_rank'] as num?)?.toInt(),
      foundedYear: (json['founded_year'] as num?)?.toInt(),
      stadium: json['stadium'] as String?,
      stadiumCapacity: (json['stadium_capacity'] as num?)?.toInt(),
      logoUrl: json['logo_url'] as String?,
      nameEn: json['name_en'] as String?,
    );

Map<String, dynamic> _$ClubModelToJson(ClubModel instance) => <String, dynamic>{
      'club_id': instance.id,
      'name': instance.name,
      'total_points': instance.totalPoints,
      'active_members': instance.memberCount,
      'league_rank': instance.rank,
      'founded_year': instance.foundedYear,
      'stadium': instance.stadium,
      'stadium_capacity': instance.stadiumCapacity,
      'logo_url': instance.logoUrl,
      'name_en': instance.nameEn,
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
