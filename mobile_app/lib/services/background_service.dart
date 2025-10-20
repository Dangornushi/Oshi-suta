import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../config/constants.dart';
import '../core/storage/local_storage.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_client.dart';
import '../data/models/step_log_model.dart';
import 'health_service.dart';

/// Background service for periodic step synchronization
///
/// Uses WorkManager to schedule periodic tasks that sync step data
/// with the backend server, even when the app is closed.
class BackgroundService {
  static const String _syncTaskName = 'oshi_suta_step_sync';
  static const String _uniqueTaskName = 'oshi_suta_periodic_sync';

  /// Initialize the background service
  ///
  /// This should be called once when the app starts
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    if (kDebugMode) {
      debugPrint('Background service initialized');
    }
  }

  /// Register periodic sync task
  ///
  /// This schedules a task to run periodically based on the sync interval
  /// defined in AppConstants
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      _syncTaskName,
      frequency: AppConstants.syncInterval,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    if (kDebugMode) {
      debugPrint('Periodic sync registered (every ${AppConstants.syncInterval.inHours} hours)');
    }
  }

  /// Register one-time sync task
  ///
  /// This schedules a single sync task to run as soon as possible
  static Future<void> registerOneTimeSync() async {
    await Workmanager().registerOneOffTask(
      'one_time_sync_${DateTime.now().millisecondsSinceEpoch}',
      _syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );

    if (kDebugMode) {
      debugPrint('One-time sync registered');
    }
  }

  /// Cancel all background tasks
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();

    if (kDebugMode) {
      debugPrint('All background tasks cancelled');
    }
  }

  /// Cancel periodic sync task
  static Future<void> cancelPeriodicSync() async {
    await Workmanager().cancelByUniqueName(_uniqueTaskName);

    if (kDebugMode) {
      debugPrint('Periodic sync cancelled');
    }
  }

  /// Perform step synchronization
  ///
  /// This is the actual work that gets done in the background.
  /// It fetches steps from health data and syncs with the server.
  static Future<bool> performSync() async {
    try {
      if (kDebugMode) {
        debugPrint('Starting background sync...');
      }

      // Initialize storage
      final storage = LocalStorage();
      await storage.init();

      // Check if user is logged in
      if (!storage.isLoggedIn()) {
        if (kDebugMode) {
          debugPrint('User not logged in, skipping sync');
        }
        return false;
      }

      // Check if sync is needed
      if (!storage.shouldSync()) {
        if (kDebugMode) {
          debugPrint('Sync not needed yet');
        }
        return true;
      }

      // Initialize health service
      final healthService = HealthService();
      final hasPermissions = await healthService.requestPermissions();

      if (!hasPermissions) {
        if (kDebugMode) {
          debugPrint('Health permissions not granted, skipping sync');
        }
        return false;
      }

      // Get steps for the last 7 days
      final stepsMap = await healthService.getStepsForLastDays(days: 7);

      if (stepsMap.isEmpty) {
        if (kDebugMode) {
          debugPrint('No step data to sync');
        }
        return true;
      }

      // Create step log entries
      final stepEntries = stepsMap.entries
          .map((entry) => StepLogEntry(
                date: entry.key,
                steps: entry.value,
                source: 'background_sync',
              ))
          .toList();

      // Initialize API client
      final dioClient = DioClient(storage);
      final apiClient = ApiClient(dioClient.dio);

      // Sync steps with server
      final response = await apiClient.syncSteps(
        SyncStepsRequest(steps: stepEntries),
      );

      if (response.response.statusCode == 200) {
        // Update last sync time
        await storage.saveLastSyncTime(DateTime.now());

        if (kDebugMode) {
          debugPrint('Background sync completed successfully');
          debugPrint('Synced ${response.data.syncedCount} step logs');
          debugPrint('Earned ${response.data.totalPointsEarned} points');
        }

        return true;
      } else {
        if (kDebugMode) {
          debugPrint('Background sync failed: ${response.response.statusMessage}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during background sync: $e');
      }
      return false;
    }
  }
}

/// Callback dispatcher for WorkManager
///
/// This function is called by WorkManager when a background task is executed.
/// It must be a top-level function (not a class method).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        debugPrint('Background task started: $task');
      }

      switch (task) {
        case 'oshi_suta_step_sync':
          final success = await BackgroundService.performSync();
          return success;
        default:
          if (kDebugMode) {
            debugPrint('Unknown task: $task');
          }
          return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in background task: $e');
      }
      return false;
    }
  });
}
