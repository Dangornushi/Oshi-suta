import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth_response.dart';
import 'base_repository.dart';

/// Repository for authentication-related operations
class AuthRepository extends BaseRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AuthRepository({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  /// Login with email and password
  ///
  /// Returns [AuthResponse] containing user info and access token
  /// Saves token and user info to local storage
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final authResponse = await executeApiCall(
      apiCall: () => _apiClient.login({
        'email': email,
        'password': password,
      }),
      operationName: 'ログイン',
    );

    // Save authentication data to local storage
    await _saveAuthData(authResponse);

    return authResponse;
  }

  /// Register a new user
  ///
  /// Returns [AuthResponse] containing user info and access token
  /// Saves token and user info to local storage
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String nickname,
    required String clubId,
  }) async {
    final authResponse = await executeApiCall(
      apiCall: () => _apiClient.register({
        'email': email,
        'password': password,
        'nickname': nickname,
        'club_id': clubId,
      }),
      operationName: 'ユーザー登録',
    );

    // Save authentication data to local storage
    await _saveAuthData(authResponse);

    return authResponse;
  }

  /// Get detailed user profile
  ///
  /// Returns [UserProfileResponse] with complete user information
  Future<UserProfileResponse> getProfile() async {
    return executeApiCall(
      apiCall: () => _apiClient.getProfile(),
      operationName: 'プロフィール取得',
    );
  }

  /// Update user profile (nickname)
  ///
  /// Returns [UserProfileResponse] with updated user information
  Future<UserProfileResponse> updateProfile({
    String? nickname,
  }) async {
    final body = <String, dynamic>{};
    if (nickname != null) body['nickname'] = nickname;

    return executeApiCall(
      apiCall: () => _apiClient.updateProfile(body),
      operationName: 'プロフィール更新',
    );
  }

  /// Update user email address
  ///
  /// Returns [UserProfileResponse] with updated user information
  Future<UserProfileResponse> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    final profile = await executeApiCall(
      apiCall: () => _apiClient.updateEmail({
        'new_email': newEmail,
        'password': password,
      }),
      operationName: 'メールアドレス更新',
    );

    // Update local storage with new email
    await _localStorage.saveUserEmail(newEmail);

    return profile;
  }

  /// Change user password
  ///
  /// Returns success message
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await executeApiCall(
      apiCall: () => _apiClient.changePassword({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
      operationName: 'パスワード変更',
    );
  }

  /// Logout user
  ///
  /// Clears all authentication data from local storage
  Future<void> logout() async {
    try {
      await _localStorage.clearAuth();
    } catch (e) {
      throw Exception('ログアウトエラー: ${e.toString()}');
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _localStorage.isLoggedIn();
  }

  /// Get saved access token
  Future<String?> getAccessToken() async {
    return await _localStorage.getAccessToken();
  }

  /// Get saved user ID
  String? getUserId() {
    return _localStorage.getUserId();
  }

  /// Get saved user email
  String? getUserEmail() {
    return _localStorage.getUserEmail();
  }

  /// Get saved club ID
  String? getClubId() {
    return _localStorage.getClubId();
  }

  /// Save club ID to local storage
  Future<void> saveClubId(String clubId) async {
    await _localStorage.saveClubId(clubId);
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await Future.wait([
      _localStorage.saveAccessToken(authResponse.accessToken),
      _localStorage.saveUserId(authResponse.userId),
      _localStorage.saveUserEmail(authResponse.email),
      _localStorage.saveClubId(authResponse.clubId),
      _localStorage.saveLoginState(true),
    ]);
  }
}
