import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/constants.dart';

/// Local storage wrapper using Hive
///
/// Provides a type-safe interface for storing and retrieving data locally.
/// Uses Hive for fast and efficient key-value storage.
class LocalStorage {
  static const String _boxName = 'oshi_suta_box';
  static const String _secureBoxName = 'oshi_suta_secure_box';

  Box? _box;
  Box? _secureBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Open regular box for non-sensitive data
      _box = await Hive.openBox(_boxName);

      // Open secure box for sensitive data (tokens, etc.)
      // In production, consider using encrypted box with a key from secure storage
      _secureBox = await Hive.openBox(_secureBoxName);

      if (kDebugMode) {
        debugPrint('LocalStorage initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing LocalStorage: $e');
      }
      rethrow;
    }
  }

  /// Check if storage is initialized
  bool get isInitialized => _box != null && _secureBox != null;

  // ============================================================================
  // Authentication Storage
  // ============================================================================

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _secureBox?.put(StorageKeys.accessToken, token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return _secureBox?.get(StorageKeys.accessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureBox?.put(StorageKeys.refreshToken, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _secureBox?.get(StorageKeys.refreshToken);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _box?.put(StorageKeys.userId, userId);
  }

  /// Get user ID
  String? getUserId() {
    return _box?.get(StorageKeys.userId);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    await _box?.put(StorageKeys.userEmail, email);
  }

  /// Get user email
  String? getUserEmail() {
    return _box?.get(StorageKeys.userEmail);
  }

  /// Save club ID
  Future<void> saveClubId(String clubId) async {
    await _box?.put(StorageKeys.clubId, clubId);
  }

  /// Get club ID
  String? getClubId() {
    return _box?.get(StorageKeys.clubId);
  }

  /// Save favorite club ID
  Future<void> saveFavoriteClubId(String clubId) async {
    await _box?.put(StorageKeys.favoriteClubId, clubId);
  }

  /// Get favorite club ID
  Future<String?> getFavoriteClubId() async {
    return _box?.get(StorageKeys.favoriteClubId);
  }

  /// Save favorite club name
  Future<void> saveFavoriteClubName(String clubName) async {
    await _box?.put(StorageKeys.favoriteClubName, clubName);
  }

  /// Get favorite club name
  Future<String?> getFavoriteClubName() async {
    return _box?.get(StorageKeys.favoriteClubName);
  }

  /// Save login state
  Future<void> saveLoginState(bool isLoggedIn) async {
    await _box?.put(StorageKeys.isLoggedIn, isLoggedIn);
  }

  /// Get login state
  bool isLoggedIn() {
    return _box?.get(StorageKeys.isLoggedIn, defaultValue: false) ?? false;
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    await _secureBox?.delete(StorageKeys.accessToken);
    await _secureBox?.delete(StorageKeys.refreshToken);
    await _box?.delete(StorageKeys.userId);
    await _box?.delete(StorageKeys.userEmail);
    await _box?.delete(StorageKeys.clubId);
    await _box?.delete(StorageKeys.isLoggedIn);

    if (kDebugMode) {
      debugPrint('Authentication data cleared');
    }
  }

  // ============================================================================
  // Sync Storage
  // ============================================================================

  /// Save last sync time
  Future<void> saveLastSyncTime(DateTime time) async {
    await _box?.put(StorageKeys.lastSyncTime, time.toIso8601String());
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final timeString = _box?.get(StorageKeys.lastSyncTime);
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  /// Check if sync is needed based on interval
  bool shouldSync() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    return difference >= AppConstants.syncInterval;
  }

  // ============================================================================
  // Generic Storage Methods
  // ============================================================================

  /// Save any value with a key (non-sensitive data)
  Future<void> save(String key, dynamic value) async {
    await _box?.put(key, value);
  }

  /// Get value by key (non-sensitive data)
  T? get<T>(String key, {T? defaultValue}) {
    return _box?.get(key, defaultValue: defaultValue);
  }

  /// Delete value by key (non-sensitive data)
  Future<void> delete(String key) async {
    await _box?.delete(key);
  }

  /// Save sensitive value with a key
  Future<void> saveSecure(String key, dynamic value) async {
    await _secureBox?.put(key, value);
  }

  /// Get sensitive value by key
  T? getSecure<T>(String key, {T? defaultValue}) {
    return _secureBox?.get(key, defaultValue: defaultValue);
  }

  /// Delete sensitive value by key
  Future<void> deleteSecure(String key) async {
    await _secureBox?.delete(key);
  }

  /// Check if key exists (non-sensitive)
  bool containsKey(String key) {
    return _box?.containsKey(key) ?? false;
  }

  /// Check if key exists (sensitive)
  bool containsSecureKey(String key) {
    return _secureBox?.containsKey(key) ?? false;
  }

  /// Get all keys (non-sensitive)
  Iterable<dynamic> get keys => _box?.keys ?? [];

  /// Get all keys (sensitive)
  Iterable<dynamic> get secureKeys => _secureBox?.keys ?? [];

  // ============================================================================
  // Cleanup Methods
  // ============================================================================

  /// Clear all non-sensitive data
  Future<void> clear() async {
    await _box?.clear();
    if (kDebugMode) {
      debugPrint('Local storage cleared');
    }
  }

  /// Clear all sensitive data
  Future<void> clearSecure() async {
    await _secureBox?.clear();
    if (kDebugMode) {
      debugPrint('Secure storage cleared');
    }
  }

  /// Clear all data (both regular and secure)
  Future<void> clearAll() async {
    await clear();
    await clearSecure();
    if (kDebugMode) {
      debugPrint('All storage cleared');
    }
  }

  /// Close storage boxes
  Future<void> close() async {
    await _box?.close();
    await _secureBox?.close();
    if (kDebugMode) {
      debugPrint('Storage boxes closed');
    }
  }

  /// Compact storage boxes to reclaim space
  Future<void> compact() async {
    await _box?.compact();
    await _secureBox?.compact();
    if (kDebugMode) {
      debugPrint('Storage boxes compacted');
    }
  }

  // ============================================================================
  // Debug Methods
  // ============================================================================

  /// Print all storage contents (for debugging)
  void debugPrintAll() {
    if (kDebugMode) {
      debugPrint('========== Local Storage Contents ==========');
      debugPrint('Regular Box:');
      _box?.toMap().forEach((key, value) {
        debugPrint('  $key: $value');
      });
      debugPrint('Secure Box:');
      _secureBox?.toMap().forEach((key, value) {
        debugPrint('  $key: [REDACTED]');
      });
      debugPrint('==========================================');
    }
  }

  /// Get storage size in bytes
  int getStorageSize() {
    return (_box?.length ?? 0) + (_secureBox?.length ?? 0);
  }
}
