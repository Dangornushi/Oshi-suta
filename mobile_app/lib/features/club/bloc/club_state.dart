import 'package:equatable/equatable.dart';
import '../../../config/club_theme.dart';
import '../../../data/models/club_model.dart';

abstract class ClubState extends Equatable {
  const ClubState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ClubInitial extends ClubState {
  const ClubInitial();
}

/// Loading state
class ClubLoading extends ClubState {
  const ClubLoading();
}

/// Loaded state with club information
class ClubLoaded extends ClubState {
  final String clubId;
  final String clubName;
  final ClubTheme theme;

  const ClubLoaded({
    required this.clubId,
    required this.clubName,
    required this.theme,
  });

  @override
  List<Object?> get props => [clubId, clubName, theme];

  ClubLoaded copyWith({
    String? clubId,
    String? clubName,
    ClubTheme? theme,
  }) {
    return ClubLoaded(
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      theme: theme ?? this.theme,
    );
  }
}

/// Error state
class ClubError extends ClubState {
  final String message;

  const ClubError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Clubs list loaded state
class ClubListLoaded extends ClubState {
  final List<ClubModel> clubs;

  const ClubListLoaded({required this.clubs});

  @override
  List<Object?> get props => [clubs];
}
