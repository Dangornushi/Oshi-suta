import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth_response.dart';

/// Repository for authentication-related operations
class AuthRepository {
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
    try {
      print("$email, $password");
      final response = await _apiClient.login({
        'email': email,
        'password': password,
      });

      if (response.data == null) {
        print("this");
        throw Exception('ログインに失敗しました');
      }

      final authResponse = response.data!;

      // Save authentication data to local storage
      await _saveAuthData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      print("DioException: ${e.toString()}");
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('ログインエラー: ${e.toString()}');
    }
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
    try {
      final response = await _apiClient.register({
        'email': email,
        'password': password,
        'nickname': nickname,
        'club_id': clubId,
      });

      if (response.data == null) {
        throw Exception('登録に失敗しました');
      }

      final authResponse = response.data!;

      // Save authentication data to local storage
      await _saveAuthData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('登録エラー: ${e.toString()}');
    }
  }

  /// Get detailed user profile
  ///
  /// Returns [UserProfileResponse] with complete user information
  Future<UserProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.getProfile();

      if (response.data == null) {
        throw Exception('プロフィールの取得に失敗しました');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('プロフィール取得エラー: ${e.toString()}');
    }
  }

  /// Update user profile (nickname)
  ///
  /// Returns [UserProfileResponse] with updated user information
  Future<UserProfileResponse> updateProfile({
    String? nickname,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nickname != null) body['nickname'] = nickname;

      final response = await _apiClient.updateProfile(body);

      if (response.data == null) {
        throw Exception('プロフィールの更新に失敗しました');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('プロフィール更新エラー: ${e.toString()}');
    }
  }

  /// Update user email address
  ///
  /// Returns [UserProfileResponse] with updated user information
  Future<UserProfileResponse> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final response = await _apiClient.updateEmail({
        'new_email': newEmail,
        'password': password,
      });

      if (response.data == null) {
        throw Exception('メールアドレスの更新に失敗しました');
      }

      // Update local storage with new email
      await _localStorage.saveUserEmail(newEmail);

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('メールアドレス更新エラー: ${e.toString()}');
    }
  }

  /// Change user password
  ///
  /// Returns success message
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.changePassword({
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (response.data == null) {
        throw Exception('パスワードの変更に失敗しました');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('パスワード変更エラー: ${e.toString()}');
    }
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

  /// Handle Dio errors and convert to user-friendly messages
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Extract error message from response
      String message = 'エラーが発生しました';
      if (data is Map<String, dynamic>) {
        message = data['detail'] ?? data['message'] ?? message;
      }

      switch (statusCode) {
        case 400:
          return Exception('入力内容に誤りがあります: $message');
        case 401:
          return Exception('メールアドレスまたはパスワードが正しくありません');
        case 409:
          return Exception('このメールアドレスは既に登録されています');
        case 500:
          return Exception('サーバーエラーが発生しました。時間をおいて再度お試しください');
        default:
          return Exception(message);
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('接続がタイムアウトしました。ネットワーク接続を確認してください');
    } else if (error.type == DioExceptionType.unknown) {
      return Exception('ネットワーク接続を確認してください');
    }

    return Exception('エラーが発生しました: ${error.message}');
  }
}
