import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/constants.dart';
import '../storage/local_storage.dart';

/// Dio HTTP client with interceptors for the Oshi-Suta BATTLE app
class DioClient {
  late final Dio _dio;
  final LocalStorage _storage;

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConstants.apiBaseUrl}${AppConstants.apiPrefix}',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Get the configured Dio instance
  Dio get dio => _dio;

  /// Setup interceptors for authentication, logging, and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token to requests
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request in debug mode
          if (kDebugMode) {
            debugPrint('┌─────────────────────────────────────────────');
            debugPrint('│ REQUEST: ${options.method} ${options.path}');
            debugPrint('│ Headers: ${options.headers}');
            if (options.queryParameters.isNotEmpty) {
              debugPrint('│ Query: ${options.queryParameters}');
            }
            if (options.data != null) {
              debugPrint('│ Body: ${options.data}');
            }
            debugPrint('└─────────────────────────────────────────────');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response in debug mode
          if (kDebugMode) {
            debugPrint('┌─────────────────────────────────────────────');
            debugPrint(
                '│ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
            debugPrint('│ Data: ${response.data}');
            debugPrint('└─────────────────────────────────────────────');
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error in debug mode
          if (kDebugMode) {
            debugPrint('┌─────────────────────────────────────────────');
            debugPrint('│ ERROR: ${error.requestOptions.path}');
            debugPrint('│ Status: ${error.response?.statusCode}');
            debugPrint('│ Message: ${error.message}');
            debugPrint('│ Response: ${error.response?.data}');
            debugPrint('└─────────────────────────────────────────────');
          }

          // Handle 401 Unauthorized - token expired or invalid
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request with new token
              final options = error.requestOptions;
              final token = await _storage.getAccessToken();
              options.headers['Authorization'] = 'Bearer $token';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                // If retry fails, clear auth and let the error propagate
                await _clearAuth();
                return handler.reject(error);
              }
            } else {
              // Refresh failed, clear auth
              await _clearAuth();
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Add retry interceptor for network failures
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Check if request should be retried
  bool _shouldRetry(DioException error) {
    // Only retry on network errors, not client/server errors
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.type == DioExceptionType.unknown &&
            error.error.toString().contains('SocketException'));
  }

  /// Refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Create a new Dio instance without interceptors to avoid infinite loop
      final dio = Dio(BaseOptions(
        baseUrl: '${AppConstants.apiBaseUrl}${AppConstants.apiPrefix}',
      ));

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await _storage.saveAccessToken(newAccessToken);
        if (newRefreshToken != null) {
          await _storage.saveRefreshToken(newRefreshToken);
        }

        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to refresh token: $e');
      }
    }

    return false;
  }

  /// Clear authentication data
  Future<void> _clearAuth() async {
    await _storage.clearAuth();
    if (kDebugMode) {
      debugPrint('Authentication cleared due to token error');
    }
  }

  /// Update base URL (useful for switching between environments)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = '$baseUrl${AppConstants.apiPrefix}';
  }

  /// Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }
}
