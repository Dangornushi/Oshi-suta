# 優先度 HIGH: エラーハンドリングの統一

## 🎯 目的
バックエンドとモバイルアプリの両方で、エラーハンドリングロジックを統一し、コードの重複を削減する。

## 📊 現在の問題

### 問題1: バックエンドで20箇所以上の重複

すべてのエンドポイントで同じエラーハンドリングが繰り返されている:

```python
# auth.py, clubs.py, steps.py で繰り返される
try:
    # ビジネスロジック
    pass
except HTTPException:
    raise
except Exception as e:
    logger.error(f"Operation error: {str(e)}")
    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Failed to operation"
    )
```

**重複箇所**:
- `backend/app/api/v1/endpoints/auth.py`: 5箇所
- `backend/app/api/v1/endpoints/clubs.py`: 4箇所
- `backend/app/api/v1/endpoints/steps.py`: 3箇所

### 問題2: モバイルアプリで8箇所以上の重複

BLoCとリポジトリで同じパターンが繰り返されている:

```dart
// BLoC内
try {
  // 処理
} catch (e) {
  emit(AuthError(e.toString().replaceAll('Exception: ', '')));
  emit(const AuthUnauthenticated());
}

// Repository内
try {
  final response = await _apiClient.operation(...);
  if (response.data == null) {
    throw Exception('操作に失敗しました');
  }
  return response.data!;
} on DioException catch (e) {
  throw _handleDioError(e);
} catch (e) {
  throw Exception('操作エラー: ${e.toString()}');
}
```

## 📋 実装手順

---

## パート1: バックエンド (Python/FastAPI)

### ステップ1: 共通エラーハンドリングモジュールを作成

`backend/app/utils/error_handlers.py` を新規作成:

```python
"""
共通エラーハンドリングユーティリティ
"""

import logging
from functools import wraps
from typing import Callable, Any
from fastapi import HTTPException, status

logger = logging.getLogger(__name__)


class AppError(Exception):
    """アプリケーション基底エラー"""
    def __init__(self, message: str, status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


class ValidationError(AppError):
    """バリデーションエラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_400_BAD_REQUEST)


class NotFoundError(AppError):
    """リソース未発見エラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_404_NOT_FOUND)


class UnauthorizedError(AppError):
    """認証エラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_401_UNAUTHORIZED)


class ForbiddenError(AppError):
    """認可エラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_403_FORBIDDEN)


def handle_exceptions(operation_name: str = "Operation"):
    """
    エンドポイント共通のエラーハンドリングデコレータ

    使用例:
        @router.post("/register")
        @handle_exceptions("User registration")
        async def register(request: UserRegisterRequest):
            # ビジネスロジック
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def wrapper(*args, **kwargs) -> Any:
            try:
                return await func(*args, **kwargs)
            except HTTPException:
                # FastAPIのHTTPExceptionはそのまま再送出
                raise
            except AppError as e:
                # カスタムエラーをHTTPExceptionに変換
                logger.warning(f"{operation_name} failed: {e.message}")
                raise HTTPException(
                    status_code=e.status_code,
                    detail=e.message
                )
            except ValueError as e:
                # バリデーションエラー
                logger.warning(f"{operation_name} validation error: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(e)
                )
            except Exception as e:
                # 予期しないエラー
                logger.error(f"{operation_name} unexpected error: {str(e)}", exc_info=True)
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"{operation_name} failed"
                )
        return wrapper
    return decorator


def validate_and_raise(condition: bool, error_message: str, error_class: type[AppError] = ValidationError):
    """
    条件チェック＆エラー送出ヘルパー

    使用例:
        validate_and_raise(
            validate_club_id(club_id),
            f"Invalid club ID: {club_id}"
        )
    """
    if not condition:
        raise error_class(error_message)
```

### ステップ2: エンドポイントを書き換え

#### 2.1 `backend/app/api/v1/endpoints/auth.py` を修正

**修正前**:
```python
@router.post("/register", response_model=AuthResponse)
async def register(
    request: UserRegisterRequest,
    repo: FirestoreRepository = Depends(get_firestore_repo)
) -> AuthResponse:
    try:
        # バリデーション
        if not validate_club_id(request.club_id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid club ID: {request.club_id}"
            )

        is_valid, error_msg = validate_nickname(request.nickname)
        if not is_valid:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=error_msg
            )

        # ビジネスロジック
        # ...

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Registration error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to register user"
        )
```

**修正後**:
```python
from app.utils.error_handlers import handle_exceptions, validate_and_raise, ValidationError

@router.post("/register", response_model=AuthResponse)
@handle_exceptions("User registration")
async def register(
    request: UserRegisterRequest,
    repo: FirestoreRepository = Depends(get_firestore_repo)
) -> AuthResponse:
    # バリデーション
    validate_and_raise(
        validate_club_id(request.club_id),
        f"Invalid club ID: {request.club_id}"
    )

    is_valid, error_msg = validate_nickname(request.nickname)
    validate_and_raise(is_valid, error_msg)

    # ビジネスロジック
    # ...（try-exceptブロック不要）
```

#### 2.2 他のエンドポイントも同様に修正

- `auth.py` の全エンドポイント
- `clubs.py` の全エンドポイント
- `steps.py` の全エンドポイント

### ステップ3: カスタムエラークラスの活用

`backend/app/repositories/firestore_repo.py` を修正:

**修正前**:
```python
def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
    doc = self.db.collection('users').document(user_id).get()
    if not doc.exists:
        return None
    return doc.to_dict()
```

**修正後**:
```python
from app.utils.error_handlers import NotFoundError

def get_user_by_id(self, user_id: str, raise_if_not_found: bool = False) -> Optional[Dict[str, Any]]:
    doc = self.db.collection('users').document(user_id).get()
    if not doc.exists:
        if raise_if_not_found:
            raise NotFoundError(f"User not found: {user_id}")
        return None
    return doc.to_dict()
```

### ステップ4: グローバルエラーハンドラーを追加

`backend/app/main.py` に追加:

```python
from fastapi import Request
from fastapi.responses import JSONResponse
from app.utils.error_handlers import AppError

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    """カスタムエラーのグローバルハンドラー"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.message,
            "error_type": exc.__class__.__name__
        }
    )
```

---

## パート2: モバイルアプリ (Flutter/Dart)

### ステップ1: 共通エラーハンドリングクラスを作成

`mobile_app/lib/core/error/error_handler.dart` を新規作成:

```dart
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
```

### ステップ2: リポジトリの共通化

`mobile_app/lib/data/repositories/base_repository.dart` を新規作成:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/error/error_handler.dart';

/// リポジトリ基底クラス
abstract class BaseRepository {
  /// 共通API呼び出しラッパー
  Future<T> executeApiCall<T>({
    required Future<HttpResponse<T>> Function() apiCall,
    required String operationName,
  }) async {
    try {
      final response = await apiCall();

      if (response.data == null) {
        throw ServerException('${operationName}に失敗しました');
      }

      return response.data!;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
```

### ステップ3: AuthRepositoryをリファクタリング

`mobile_app/lib/data/repositories/auth_repository.dart` を修正:

**修正前**:
```dart
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.login(request);

      if (response.data == null) {
        throw Exception('ログインに失敗しました');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('ログインエラー: ${e.toString()}');
    }
  }

  // 他のメソッドも同様のパターン...
}
```

**修正後**:
```dart
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResponse> login(LoginRequest request) async {
    return executeApiCall(
      apiCall: () => _apiClient.login(request),
      operationName: 'ログイン',
    );
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    return executeApiCall(
      apiCall: () => _apiClient.register(request),
      operationName: 'ユーザー登録',
    );
  }

  Future<UserProfileResponse> getProfile() async {
    return executeApiCall(
      apiCall: () => _apiClient.getProfile(),
      operationName: 'プロフィール取得',
    );
  }

  // 他のメソッドも同様に簡潔化...
}
```

### ステップ4: BLoC基底クラスを作成

`mobile_app/lib/features/common/base_bloc.dart` を新規作成:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/error/error_handler.dart';

/// BLoC基底クラス
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// 共通のエラーハンドリング付き非同期処理
  Future<void> executeWithErrorHandling({
    required Emitter<State> emit,
    required Future<void> Function() operation,
    required State Function() loadingState,
    required State Function(String errorMessage) errorState,
  }) async {
    emit(loadingState());

    try {
      await operation();
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(errorState(appException.message));
    }
  }
}
```

### ステップ5: AuthBLoCをリファクタリング

`mobile_app/lib/features/auth/bloc/auth_bloc.dart` を修正:

**修正前**:
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // イベントハンドラー内
  on<AuthLoginRequested>((event, emit) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.login(event.request);
      // ...
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  });
}
```

**修正後**:
```dart
import '../../common/base_bloc.dart';

class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    await executeWithErrorHandling(
      emit: emit,
      operation: () async {
        final response = await _authRepository.login(event.request);
        await _saveAuthData(response);
        emit(AuthAuthenticated(user: _mapToUser(response)));
      },
      loadingState: () => const AuthLoading(),
      errorState: (message) {
        // エラー後は未認証状態に戻す
        Future.microtask(() => emit(const AuthUnauthenticated()));
        return AuthError(message);
      },
    );
  }
}
```

### ステップ6: ClubBLoCも同様にリファクタリング

`mobile_app/lib/features/club/bloc/club_bloc.dart` を同様に修正。

---

## ✅ チェックリスト

### バックエンド
- [ ] `backend/app/utils/error_handlers.py` を作成
- [ ] `auth.py` の全エンドポイントにデコレータ適用
- [ ] `clubs.py` の全エンドポイントにデコレータ適用
- [ ] `steps.py` の全エンドポイントにデコレータ適用
- [ ] `firestore_repo.py` でカスタムエラーを活用
- [ ] `main.py` にグローバルエラーハンドラーを追加
- [ ] 既存のtry-exceptブロックを削除
- [ ] テストを実行して全てパス

### モバイルアプリ
- [ ] `lib/core/error/error_handler.dart` を作成
- [ ] `lib/data/repositories/base_repository.dart` を作成
- [ ] `AuthRepository` をリファクタリング
- [ ] `lib/features/common/base_bloc.dart` を作成
- [ ] `AuthBloc` をリファクタリング
- [ ] `ClubBloc` をリファクタリング
- [ ] 既存の重複エラーハンドリングを削除
- [ ] テストを実行して全てパス

## ⏱️ 推定作業時間

- バックエンド実装: 3時間
- モバイルアプリ実装: 3時間
- テスト・デバッグ: 2時間

**合計**: 約8時間

## 📈 期待される効果

- ✅ コード行数が約200行削減
- ✅ エラーハンドリングの一貫性向上
- ✅ バグ発生リスクの低減
- ✅ 新機能追加時の開発速度向上
- ✅ メンテナンス性の向上

## 📚 参考資料

- [FastAPI Exception Handling](https://fastapi.tiangolo.com/tutorial/handling-errors/)
- [Dart Exception Handling Best Practices](https://dart.dev/guides/language/effective-dart/usage#do-use-rethrow-to-rethrow-a-caught-exception)
- [BLoC Pattern Error Handling](https://bloclibrary.dev/#/coreconcepts?id=error-handling)
