import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/club_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import 'club_event.dart';
import 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final ApiClient apiClient;
  final LocalStorage localStorage;

  ClubBloc({
    required this.apiClient,
    required this.localStorage,
  }) : super(const ClubInitial()) {
    on<LoadFavoriteClub>(_onLoadFavoriteClub);
    on<ChangeFavoriteClub>(_onChangeFavoriteClub);
    on<ResetClub>(_onResetClub);
    on<LoadAllClubs>(_onLoadAllClubs);
  }

  /// Load favorite club from API only
  Future<void> _onLoadFavoriteClub(
    LoadFavoriteClub event,
    Emitter<ClubState> emit,
  ) async {
    try {
      emit(const ClubLoading());

      // Fetch from API only
      try {
        final response = await apiClient.getProfile();
        final fetchedClubId = response.data.clubId;
        final theme = ClubTheme.getTheme(fetchedClubId);
        final fetchedClubName = theme.clubName;

        emit(ClubLoaded(
          clubId: fetchedClubId,
          clubName: fetchedClubName,
          theme: theme,
        ));
        return;
      } catch (e) {
        print('Failed to fetch club from API: $e');
        emit(ClubError(message: 'クラブ情報の取得に失敗しました。ネットワーク接続を確認してください。'));
      }
    } catch (e) {
      emit(ClubError(message: 'クラブ情報の読み込みに失敗しました: $e'));
    }
  }

  /// Change favorite club
  Future<void> _onChangeFavoriteClub(
    ChangeFavoriteClub event,
    Emitter<ClubState> emit,
  ) async {
    try {
      emit(const ClubLoading());

      print('=== Changing club to: ${event.clubId} (${event.clubName}) ===');

      // Call API to join the club - must succeed
      final response = await apiClient.joinClub(event.clubId);

      print('=== API Response Status: ${response.response.statusCode} ===');
      print('=== API Response Data: ${response.response.data} ===');

      // Get theme for the new club
      final theme = ClubTheme.getTheme(event.clubId);

      emit(ClubLoaded(
        clubId: event.clubId,
        clubName: event.clubName,
        theme: theme,
      ));

      print('=== Club changed successfully ===');
    } catch (e) {
      print('=== Failed to join club via API: $e ===');
      emit(ClubError(message: 'クラブの変更に失敗しました。ネットワーク接続を確認してください。'));
    }
  }

  /// Reset club to default
  Future<void> _onResetClub(
    ResetClub event,
    Emitter<ClubState> emit,
  ) async {
    try {
      emit(const ClubLoading());

      const defaultClubId = 'urawa-reds';
      const defaultClubName = '浦和レッズ';
      final defaultTheme = ClubTheme.getTheme(defaultClubId);

      // Call API to join default club
      await apiClient.joinClub(defaultClubId);

      emit(ClubLoaded(
        clubId: defaultClubId,
        clubName: defaultClubName,
        theme: defaultTheme,
      ));
    } catch (e) {
      print('Failed to reset club via API: $e');
      emit(ClubError(message: 'クラブのリセットに失敗しました。'));
    }
  }

  /// Load all available clubs from API
  Future<void> _onLoadAllClubs(
    LoadAllClubs event,
    Emitter<ClubState> emit,
  ) async {
    try {
      emit(const ClubLoading());

      // Fetch all clubs from API
      final response = await apiClient.getClubs();

      if (response.data.clubs.isEmpty) {
        emit(const ClubError(message: 'クラブ情報が見つかりませんでした。'));
        return;
      }

      emit(ClubListLoaded(clubs: response.data.clubs));
    } catch (e) {
      print('Failed to load clubs from API: $e');
      emit(const ClubError(message: 'クラブ一覧の取得に失敗しました。'));
    }
  }
}
