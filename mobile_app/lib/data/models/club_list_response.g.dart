// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubListResponse _$ClubListResponseFromJson(Map<String, dynamic> json) =>
    ClubListResponse(
      totalClubs: (json['total_clubs'] as num).toInt(),
      clubs: (json['clubs'] as List<dynamic>)
          .map((e) => ClubModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClubListResponseToJson(ClubListResponse instance) =>
    <String, dynamic>{
      'total_clubs': instance.totalClubs,
      'clubs': instance.clubs,
    };
