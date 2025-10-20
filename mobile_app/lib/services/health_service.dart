import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/constants.dart';

/// Health data service using the health package
///
/// Handles requesting permissions and fetching step count data from
/// Apple Health (iOS) or Google Fit (Android).
class HealthService {
  final Health _health = Health();

  /// List of health data types we want to access
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
  ];

  /// Permissions for the health data types
  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
  ];

  bool _isAuthorized = false;

  /// Check if health permissions are granted
  bool get isAuthorized => _isAuthorized;

  /// Initialize and request health permissions
  ///
  /// Returns true if permissions were granted, false otherwise.
  Future<bool> requestPermissions() async {
    try {
      // Check if the platform supports health data
      final hasPermissions = await _health.hasPermissions(_types, permissions: _permissions);

      if (hasPermissions == true) {
        _isAuthorized = true;
        if (kDebugMode) {
          debugPrint('Health permissions already granted');
        }
        return true;
      }

      // Request permissions
      _isAuthorized = await _health.requestAuthorization(_types, permissions: _permissions);

      if (kDebugMode) {
        debugPrint('Health permissions ${_isAuthorized ? 'granted' : 'denied'}');
      }

      return _isAuthorized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting health permissions: $e');
      }
      _isAuthorized = false;
      return false;
    }
  }

  /// Check activity recognition permission (Android)
  ///
  /// On Android 10+, activity recognition permission is required for step counting
  Future<bool> requestActivityRecognitionPermission() async {
    try {
      final status = await Permission.activityRecognition.status;

      if (status.isGranted) {
        if (kDebugMode) {
          debugPrint('Activity recognition permission already granted');
        }
        return true;
      }

      final result = await Permission.activityRecognition.request();

      if (kDebugMode) {
        debugPrint('Activity recognition permission: ${result.isGranted ? 'granted' : 'denied'}');
      }

      return result.isGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting activity recognition permission: $e');
      }
      return false;
    }
  }

  /// Get step count for a specific date
  ///
  /// [date] The date to get steps for (defaults to today)
  /// Returns the total number of steps, or null if unavailable
  Future<int?> getStepsForDate(DateTime date) async {
    if (!_isAuthorized) {
      if (kDebugMode) {
        debugPrint('Health permissions not granted');
      }
      return null;
    }

    try {
      // Set start and end times for the date
      final startDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Fetch health data
      final healthData = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startDate,
        endTime: endDate,
      );

      if (healthData.isEmpty) {
        if (kDebugMode) {
          debugPrint('No health data found for ${date.toIso8601String()}');
        }
        return 0;
      }

      // Sum up all step counts for the day
      int totalSteps = 0;
      for (final data in healthData) {
        if (data.type == HealthDataType.STEPS) {
          final value = data.value;
          if (value is NumericHealthValue) {
            totalSteps += value.numericValue.toInt();
          }
        }
      }

      // Apply max daily steps limit
      if (totalSteps > AppConstants.maxDailySteps) {
        if (kDebugMode) {
          debugPrint('Steps ($totalSteps) exceed max daily limit, capping at ${AppConstants.maxDailySteps}');
        }
        totalSteps = AppConstants.maxDailySteps;
      }

      if (kDebugMode) {
        debugPrint('Steps for ${date.toIso8601String()}: $totalSteps');
      }

      return totalSteps;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting steps for date: $e');
      }
      return null;
    }
  }

  /// Get step count for today
  Future<int?> getTodaySteps() async {
    return getStepsForDate(DateTime.now());
  }

  /// Get step counts for a date range
  ///
  /// [startDate] Start of the date range
  /// [endDate] End of the date range
  /// Returns a map of date strings (YYYY-MM-DD) to step counts
  Future<Map<String, int>> getStepsForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isAuthorized) {
      if (kDebugMode) {
        debugPrint('Health permissions not granted');
      }
      return {};
    }

    final Map<String, int> stepsMap = {};

    try {
      // Normalize dates
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      // Fetch health data for the entire range
      final healthData = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: end,
      );

      if (healthData.isEmpty) {
        if (kDebugMode) {
          debugPrint('No health data found for range');
        }
        return stepsMap;
      }

      // Group steps by date
      for (final data in healthData) {
        if (data.type == HealthDataType.STEPS) {
          final date = data.dateFrom;
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          final value = data.value;
          if (value is NumericHealthValue) {
            final steps = value.numericValue.toInt();
            stepsMap[dateKey] = (stepsMap[dateKey] ?? 0) + steps;
          }
        }
      }

      // Apply max daily steps limit to each day
      stepsMap.updateAll((key, value) {
        if (value > AppConstants.maxDailySteps) {
          return AppConstants.maxDailySteps;
        }
        return value;
      });

      if (kDebugMode) {
        debugPrint('Steps for range: $stepsMap');
      }

      return stepsMap;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting steps for range: $e');
      }
      return stepsMap;
    }
  }

  /// Get step count for the last N days
  ///
  /// [days] Number of days to go back (default: 7)
  /// Returns a map of date strings to step counts
  Future<Map<String, int>> getStepsForLastDays({int days = 7}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    return getStepsForRange(startDate: startDate, endDate: endDate);
  }

  /// Calculate points from steps
  ///
  /// Uses the ratio defined in AppConstants
  int calculatePoints(int steps) {
    return steps ~/ AppConstants.stepsToPointsRatio;
  }

  /// Check if health data is available on this device
  Future<bool> isHealthDataAvailable() async {
    try {
      // This will throw an exception on unsupported platforms
      await _health.hasPermissions(_types);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Health data not available: $e');
      }
      return false;
    }
  }

  /// Get health connect or health kit status
  Future<HealthConnectSdkStatus> getHealthConnectSdkStatus() async {
    try {
      return await _health.getHealthConnectSdkStatus() ?? HealthConnectSdkStatus.sdkUnavailable;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting Health Connect SDK status: $e');
      }
      return HealthConnectSdkStatus.sdkUnavailable;
    }
  }

  /// Revoke health permissions
  Future<void> revokePermissions() async {
    try {
      await _health.revokePermissions();
      _isAuthorized = false;

      if (kDebugMode) {
        debugPrint('Health permissions revoked');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error revoking permissions: $e');
      }
    }
  }

  /// Format date to YYYY-MM-DD string
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse YYYY-MM-DD string to DateTime
  DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing date: $e');
      }
      return null;
    }
  }
}
