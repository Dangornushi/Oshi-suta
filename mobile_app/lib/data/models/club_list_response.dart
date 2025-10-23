import 'package:json_annotation/json_annotation.dart';
import 'club_model.dart';

part 'club_list_response.g.dart';

/// Club list response model
@JsonSerializable()
class ClubListResponse {
  /// Total number of clubs
  @JsonKey(name: 'total_clubs')
  final int totalClubs;

  /// List of clubs
  final List<ClubModel> clubs;

  ClubListResponse({
    required this.totalClubs,
    required this.clubs,
  });

  /// Creates a ClubListResponse from JSON
  factory ClubListResponse.fromJson(Map<String, dynamic> json) =>
      _$ClubListResponseFromJson(json);

  /// Converts ClubListResponse to JSON
  Map<String, dynamic> toJson() => _$ClubListResponseToJson(this);

  @override
  String toString() {
    return 'ClubListResponse(totalClubs: $totalClubs, clubs: ${clubs.length})';
  }
}
