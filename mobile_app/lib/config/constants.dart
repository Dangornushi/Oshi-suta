/// Application-wide constants
class AppConstants {
  // API Configuration
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  // For iOS simulator, use 'localhost' or '127.0.0.1'
  // For physical devices, use your machine's IP address (e.g., '192.168.1.100')
  static const String apiBaseUrl = 'http://10.0.2.2:8000';
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Health Data
  static const int stepsToPointsRatio = 1000; // 1000 steps = 1 point
  static const int maxDailySteps = 100000;

  // Background Sync
  static const Duration syncInterval = Duration(hours: 1);

  // Cache
  static const Duration cacheExpiration = Duration(minutes: 5);

  // Pagination
  static const int defaultPageSize = 20;
}

/// Local storage keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String clubId = 'club_id';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastSyncTime = 'last_sync_time';
  static const String favoriteClubId = 'favorite_club_id';
  static const String favoriteClubName = 'favorite_club_name';
}

/// API Endpoints
class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Steps
  static const String syncSteps = '/steps/sync';
  static const String stepHistory = '/steps/history';
  static const String stepStats = '/steps/stats';

  // Clubs
  static const String clubs = '/clubs';
  static String clubById(String id) => '/clubs/$id';
  static String clubStats(String id) => '/clubs/$id/stats';

  // Health
  static const String health = '/health';
  static const String healthReady = '/health/ready';
  static const String healthLive = '/health/live';
}
