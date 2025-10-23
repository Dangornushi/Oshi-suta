import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../config/constants.dart';
import '../../data/models/user_model.dart';
import '../../data/models/club_model.dart';
import '../../data/models/club_list_response.dart';
import '../../data/models/step_log_model.dart';
import '../../data/models/auth_response.dart';

part 'api_client.g.dart';

/// Retrofit API client for the Oshi-Suta BATTLE app
///
/// This class defines all the API endpoints for the backend server.
/// Code generation is required to create the implementation.
/// Run: flutter pub run build_runner build
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ============================================================================
  // Authentication Endpoints
  // ============================================================================

  /// Register a new user
  ///
  /// POST /auth/register
  /// Body: { "email": "user@example.com", "password": "password", "nickname": "nickname", "club_id": "club_id" }
  /// Returns: AuthResponse with token and user info
  @POST(ApiEndpoints.register)
  Future<HttpResponse<AuthResponse>> register(
    @Body() Map<String, dynamic> body,
  );

  /// Login with email and password
  ///
  /// POST /auth/login
  /// Body: { "email": "user@example.com", "password": "password" }
  /// Returns: AuthResponse with token, user_id, email, nickname, and club_id
  @POST(ApiEndpoints.login)
  Future<HttpResponse<AuthResponse>> login(
    @Body() Map<String, dynamic> body,
  );

  /// Get current user profile
  ///
  /// GET /auth/profile
  /// Requires: Authorization header with Bearer token
  /// Returns: Detailed user profile information
  @GET(ApiEndpoints.profile)
  Future<HttpResponse<UserProfileResponse>> getProfile();

  /// Update user profile (nickname, club_id)
  ///
  /// PATCH /auth/profile
  /// Body: { "nickname": "new_nickname", "club_id": "new_club_id" }
  /// Requires: Authorization header with Bearer token
  /// Returns: Updated user profile information
  @PATCH(ApiEndpoints.profile)
  Future<HttpResponse<UserProfileResponse>> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  /// Update user email address
  ///
  /// PUT /auth/email
  /// Body: { "new_email": "new@example.com", "password": "current_password" }
  /// Requires: Authorization header with Bearer token
  /// Returns: Updated user profile information
  @PUT('/auth/email')
  Future<HttpResponse<UserProfileResponse>> updateEmail(
    @Body() Map<String, dynamic> body,
  );

  /// Change user password
  ///
  /// PUT /auth/password
  /// Body: { "current_password": "old_pass", "new_password": "new_pass" }
  /// Requires: Authorization header with Bearer token
  /// Returns: Success message
  @PUT('/auth/password')
  Future<HttpResponse<dynamic>> changePassword(
    @Body() Map<String, dynamic> body,
  );

  // ============================================================================
  // Step Endpoints
  // ============================================================================

  /// Sync step data to the server
  ///
  /// POST /steps/sync
  /// Body: { "steps": [{ "date": "2024-01-01", "steps": 10000, "source": "health_kit" }] }
  /// Returns: { "synced_count": 1, "total_points_earned": 10, "step_logs": [...] }
  @POST(ApiEndpoints.syncSteps)
  Future<HttpResponse<SyncStepsResponse>> syncSteps(
    @Body() SyncStepsRequest request,
  );

  /// Get step history
  ///
  /// GET /steps/history
  /// Query params: start_date, end_date, limit, offset
  @GET(ApiEndpoints.stepHistory)
  Future<HttpResponse<List<StepLogModel>>> getStepHistory({
    @Query('start_date') String? startDate,
    @Query('end_date') String? endDate,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  /// Get step statistics
  ///
  /// GET /steps/stats
  /// Query params: period (today, week, month, all)
  @GET(ApiEndpoints.stepStats)
  Future<HttpResponse<StepStatsModel>> getStepStats({
    @Query('period') String? period,
  });

  // ============================================================================
  // Club Endpoints
  // ============================================================================

  /// Get list of all clubs
  ///
  /// GET /clubs
  /// Query params: limit, offset, sort_by (points, members, name)
  @GET(ApiEndpoints.clubs)
  Future<HttpResponse<ClubListResponse>> getClubs({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @Query('sort_by') String? sortBy,
  });

  /// Get club by ID
  ///
  /// GET /clubs/{id}
  @GET('/clubs/{id}')
  Future<HttpResponse<ClubModel>> getClubById(
    @Path('id') String id,
  );

  /// Get club statistics
  ///
  /// GET /clubs/{id}/stats
  /// Query params: period (today, week, month, all)
  @GET('/clubs/{id}/stats')
  Future<HttpResponse<ClubStatsModel>> getClubStats(
    @Path('id') String id, {
    @Query('period') String? period,
  });

  /// Join a club
  ///
  /// POST /clubs/{id}/join
  @POST('/clubs/{id}/join')
  Future<HttpResponse<dynamic>> joinClub(
    @Path('id') String id,
  );

  /// Leave current club
  ///
  /// POST /clubs/leave
  @POST('/clubs/leave')
  Future<HttpResponse<dynamic>> leaveClub();

  // ============================================================================
  // Health Check Endpoints
  // ============================================================================

  /// Health check endpoint
  ///
  /// GET /health
  @GET(ApiEndpoints.health)
  Future<HttpResponse<dynamic>> healthCheck();

  /// Ready check endpoint
  ///
  /// GET /health/ready
  @GET(ApiEndpoints.healthReady)
  Future<HttpResponse<dynamic>> readyCheck();

  /// Liveness check endpoint
  ///
  /// GET /health/live
  @GET(ApiEndpoints.healthLive)
  Future<HttpResponse<dynamic>> liveCheck();
}

/// Helper class for creating API requests
class ApiRequest {
  /// Create registration request body
  static Map<String, dynamic> register({
    required String email,
    required String password,
    required String username,
  }) {
    return {
      'email': email,
      'password': password,
      'username': username,
    };
  }

  /// Create login request body
  static Map<String, dynamic> login({
    required String email,
    required String password,
  }) {
    return {
      'email': email,
      'password': password,
    };
  }

  /// Create sync steps request
  static SyncStepsRequest syncSteps(List<StepLogEntry> steps) {
    return SyncStepsRequest(steps: steps);
  }
}

/// Helper class for parsing API responses
class ApiResponse {
  /// Parse login response
  static Map<String, dynamic> parseLogin(Map<String, dynamic> response) {
    return {
      'access_token': response['access_token'],
      'refresh_token': response['refresh_token'],
      'token_type': response['token_type'] ?? 'bearer',
      'user': response['user'] != null ? UserModel.fromJson(response['user']) : null,
    };
  }

  /// Parse register response
  static Map<String, dynamic> parseRegister(Map<String, dynamic> response) {
    return {
      'access_token': response['access_token'],
      'refresh_token': response['refresh_token'],
      'token_type': response['token_type'] ?? 'bearer',
      'user': response['user'] != null ? UserModel.fromJson(response['user']) : null,
    };
  }

  /// Check if response is successful
  static bool isSuccess(HttpResponse response) {
    return response.response.statusCode != null &&
        response.response.statusCode! >= 200 &&
        response.response.statusCode! < 300;
  }

  /// Get error message from response
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response!.data as Map;
        return data['detail'] ?? data['message'] ?? 'An error occurred';
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}
