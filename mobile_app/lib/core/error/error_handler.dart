import 'package:dio/dio.dart';

/// アプリケーション基底エラー
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// ネットワークエラー
class NetworkException extends AppException {
  NetworkException([String message = 'ネットワークエラーが発生しました']) : super(message);
}

/// 認証エラー
class AuthenticationException extends AppException {
  AuthenticationException([String message = '認証に失敗しました']) : super(message, code: 'AUTH_ERROR');
}

/// バリデーションエラー
class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

/// サーバーエラー
class ServerException extends AppException {
  ServerException([String message = 'サーバーエラーが発生しました']) : super(message, code: 'SERVER_ERROR');
}

/// エラーハンドリングユーティリティ
class ErrorHandler {
  /// DioExceptionを適切なAppExceptionに変換
  static AppException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('通信がタイムアウトしました');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorMessage = error.response?.data?['detail'] ?? 'エラーが発生しました';

        switch (statusCode) {
          case 400:
            return ValidationException(errorMessage);
          case 401:
            return AuthenticationException('認証エラー: $errorMessage');
          case 403:
            return AuthenticationException('アクセス権限がありません');
          case 404:
            return ServerException('リソースが見つかりません');
          case 500:
          case 502:
          case 503:
            return ServerException('サーバーエラー: $errorMessage');
          default:
            return ServerException('エラー($statusCode): $errorMessage');
        }

      case DioExceptionType.cancel:
        return NetworkException('リクエストがキャンセルされました');

      case DioExceptionType.connectionError:
        return NetworkException('ネットワーク接続を確認してください');

      default:
        return ServerException('予期しないエラーが発生しました: ${error.message}');
    }
  }

  /// 汎用エラー変換
  static AppException handleError(Object error) {
    if (error is AppException) {
      return error;
    } else if (error is DioException) {
      return handleDioError(error);
    } else {
      return ServerException('エラー: ${error.toString()}');
    }
  }
}
