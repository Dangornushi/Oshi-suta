import 'package:equatable/equatable.dart';

abstract class ClubEvent extends Equatable {
  const ClubEvent();

  @override
  List<Object?> get props => [];
}

/// Load the user's favorite club
class LoadFavoriteClub extends ClubEvent {
  const LoadFavoriteClub();
}

/// Change the user's favorite club
class ChangeFavoriteClub extends ClubEvent {
  final String clubId;
  final String clubName;

  const ChangeFavoriteClub({
    required this.clubId,
    required this.clubName,
  });

  @override
  List<Object?> get props => [clubId, clubName];
}

/// Reset club to default
class ResetClub extends ClubEvent {
  const ResetClub();
}

/// Load all available clubs from API
class LoadAllClubs extends ClubEvent {
  const LoadAllClubs();
}
