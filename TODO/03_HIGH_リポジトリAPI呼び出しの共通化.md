# 優先度 HIGH: リポジトリAPI呼び出しの共通化

## 🎯 目的
モバイルアプリのリポジトリ層で繰り返されているAPI呼び出しパターンを共通化し、コードの重複を削減する。

## 📊 現在の状況

### ✅ 完了済み
- `ErrorHandler` クラスの実装 (`lib/core/error/error_handler.dart`)
- `BaseRepository` 基底クラスの作成 (`lib/data/repositories/base_repository.dart`)
  - `executeApiCall` メソッド実装済み
- `AuthRepository` のリファクタリング完了（BaseRepositoryを継承、全メソッドで`executeApiCall`を使用）

### 🔄 実装状況

**現在の `BaseRepository` の実装**:
```dart
// mobile_app/lib/data/repositories/base_repository.dart (実装済み)
abstract class BaseRepository {
  Future<T> executeApiCall<T>({
    required Future<HttpResponse<T>> Function() apiCall,
    required String operationName,
  }) async {
    // 実装済み
  }

  // 未実装:
  // - executeListApiCall<T>
  // - executeVoidApiCall
}
```

### 🚧 残りのタスク
1. `BaseRepository` に追加メソッドを実装（オプション）
2. `StepsRepository` を作成（未着手）
3. `ClubsRepository` を作成（未着手）
4. `ClubBloc` を `ClubsRepository` に移行（現在は `ApiClient` を直接使用中）
5. その他のBLoCをリポジトリパターンに移行（必要に応じて）

## 📋 実装手順

### ✅ ステップ1: 基底リポジトリクラスを作成（完了）

`mobile_app/lib/data/repositories/base_repository.dart` を新規作成:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/error/error_handler.dart';

/// リポジトリ基底クラス
///
/// 全てのリポジトリクラスはこのクラスを継承し、
/// executeApiCall メソッドを使用してAPI呼び出しを行う
abstract class BaseRepository {
  /// 共通API呼び出しラッパー
  ///
  /// エラーハンドリングとnullチェックを自動的に行う
  ///
  /// 使用例:
  /// ```dart
  /// Future<AuthResponse> login(LoginRequest request) async {
  ///   return executeApiCall(
  ///     apiCall: () => _apiClient.login(request),
  ///     operationName: 'ログイン',
  ///   );
  /// }
  /// ```
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
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('${operationName}エラー: ${e.toString()}');
    }
  }

  /// リスト取得用の共通ラッパー
  ///
  /// レスポンスがnullの場合、空リストを返す
  Future<List<T>> executeListApiCall<T>({
    required Future<HttpResponse<List<T>>> Function() apiCall,
    required String operationName,
  }) async {
    try {
      final response = await apiCall();
      return response.data ?? [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('${operationName}エラー: ${e.toString()}');
    }
  }

  /// void型の操作用ラッパー
  ///
  /// ステータスコードのみをチェック
  Future<void> executeVoidApiCall({
    required Future<HttpResponse<void>> Function() apiCall,
    required String operationName,
  }) async {
    try {
      final response = await apiCall();

      if (response.response.statusCode == null ||
          response.response.statusCode! >= 400) {
        throw ServerException('${operationName}に失敗しました');
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('${operationName}エラー: ${e.toString()}');
    }
  }
}
```

### ✅ ステップ2: ErrorHandlerを実装（完了）

`mobile_app/lib/core/error/error_handler.dart` を作成（02_HIGHと同じ内容）:

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
  NetworkException([String message = 'ネットワークエラーが発生しました'])
      : super(message, code: 'NETWORK_ERROR');
}

/// 認証エラー
class AuthenticationException extends AppException {
  AuthenticationException([String message = '認証に失敗しました'])
      : super(message, code: 'AUTH_ERROR');
}

/// バリデーションエラー
class ValidationException extends AppException {
  ValidationException(String message)
      : super(message, code: 'VALIDATION_ERROR');
}

/// サーバーエラー
class ServerException extends AppException {
  ServerException([String message = 'サーバーエラーが発生しました'])
      : super(message, code: 'SERVER_ERROR');
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

### ✅ ステップ3: AuthRepositoryをリファクタリング（完了）

`mobile_app/lib/data/repositories/auth_repository.dart` を修正:

**修正前の例** (旧パターン):
```dart
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/auth_response.dart';
// ... 他のimport

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

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.register(request);

      if (response.data == null) {
        throw Exception('登録に失敗しました');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('登録エラー: ${e.toString()}');
    }
  }

  // ... 他のメソッドも同様

  Exception _handleDioError(DioException e) {
    // 35行のエラーハンドリングコード
  }
}
```

**修正後（現在の実装）**:
```dart
import '../../core/network/api_client.dart';
import '../models/auth_response.dart';
import 'base_repository.dart';
// ... 他のimport

class AuthRepository extends BaseRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// ログイン
  Future<AuthResponse> login(LoginRequest request) async {
    return executeApiCall(
      apiCall: () => _apiClient.login(request),
      operationName: 'ログイン',
    );
  }

  /// ユーザー登録
  Future<AuthResponse> register(RegisterRequest request) async {
    return executeApiCall(
      apiCall: () => _apiClient.register(request),
      operationName: 'ユーザー登録',
    );
  }

  /// プロフィール取得
  Future<UserProfileResponse> getProfile() async {
    return executeApiCall(
      apiCall: () => _apiClient.getProfile(),
      operationName: 'プロフィール取得',
    );
  }

  /// プロフィール更新
  Future<UserProfileResponse> updateProfile(UpdateProfileRequest request) async {
    return executeApiCall(
      apiCall: () => _apiClient.updateProfile(request),
      operationName: 'プロフィール更新',
    );
  }

  /// メールアドレス更新
  Future<UserProfileResponse> updateEmail(UpdateEmailRequest request) async {
    return executeApiCall(
      apiCall: () => _apiClient.updateEmail(request),
      operationName: 'メールアドレス更新',
    );
  }

  /// パスワード変更
  Future<void> changePassword(ChangePasswordRequest request) async {
    return executeVoidApiCall(
      apiCall: () => _apiClient.changePassword(request),
      operationName: 'パスワード変更',
    );
  }
}
```

### 🚧 ステップ4: StepsRepositoryを作成（未着手）

`mobile_app/lib/data/repositories/steps_repository.dart` を新規作成:

```dart
import '../../core/network/api_client.dart';
import '../models/step_log_model.dart';
import 'base_repository.dart';

/// 歩数データリポジトリ
class StepsRepository extends BaseRepository {
  final ApiClient _apiClient;

  StepsRepository(this._apiClient);

  /// 歩数データを同期
  Future<StepSyncResponse> syncSteps(StepSyncRequest request) async {
    return executeApiCall(
      apiCall: () => _apiClient.syncSteps(request),
      operationName: '歩数データ同期',
    );
  }

  /// 歩数履歴を取得
  Future<List<StepLog>> getStepHistory({
    required String startDate,
    required String endDate,
  }) async {
    return executeListApiCall(
      apiCall: () => _apiClient.getStepHistory(
        startDate: startDate,
        endDate: endDate,
      ),
      operationName: '歩数履歴取得',
    );
  }

  /// 歩数統計を取得
  Future<StepStatsResponse> getStepStats({String? period}) async {
    return executeApiCall(
      apiCall: () => _apiClient.getStepStats(period: period),
      operationName: '歩数統計取得',
    );
  }
}
```

### 🚧 ステップ5: ClubsRepositoryを作成（未着手）

`mobile_app/lib/data/repositories/clubs_repository.dart` を新規作成:

```dart
import '../../core/network/api_client.dart';
import '../models/club_model.dart';
import '../models/club_list_response.dart';
import 'base_repository.dart';

/// クラブ情報リポジトリ
class ClubsRepository extends BaseRepository {
  final ApiClient _apiClient;

  ClubsRepository(this._apiClient);

  /// 全クラブ一覧を取得
  Future<ClubListResponse> getAllClubs() async {
    return executeApiCall(
      apiCall: () => _apiClient.getAllClubs(),
      operationName: '全クラブ一覧取得',
    );
  }

  /// クラブ詳細情報を取得
  Future<ClubInfo> getClubInfo(String clubId) async {
    return executeApiCall(
      apiCall: () => _apiClient.getClubInfo(clubId),
      operationName: 'クラブ詳細取得',
    );
  }

  /// クラブ統計を取得
  Future<ClubStatsResponse> getClubStats(String clubId) async {
    return executeApiCall(
      apiCall: () => _apiClient.getClubStats(clubId),
      operationName: 'クラブ統計取得',
    );
  }

  /// クラブに参加（変更）
  Future<JoinClubResponse> joinClub(String clubId) async {
    return executeApiCall(
      apiCall: () => _apiClient.joinClub(clubId),
      operationName: 'クラブ変更',
    );
  }
}
```

### 🚧 ステップ6: 依存性注入の設定（一部完了）

`mobile_app/lib/main.dart` でリポジトリを登録（AuthRepositoryは登録済み、StepsRepositoryとClubsRepositoryは未登録）:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/network/dio_client.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/steps_repository.dart';
import 'data/repositories/clubs_repository.dart';
// ... 他のimport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive初期化
  await Hive.initFlutter();
  await LocalStorage.init();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // DioClientとApiClientの初期化
  final dioClient = DioClient();
  final apiClient = ApiClient(dioClient.dio);

  // リポジトリの初期化
  final authRepository = AuthRepository(apiClient);
  final stepsRepository = StepsRepository(apiClient);
  final clubsRepository = ClubsRepository(apiClient);

  runApp(MyApp(
    authRepository: authRepository,
    stepsRepository: stepsRepository,
    clubsRepository: clubsRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final StepsRepository stepsRepository;
  final ClubsRepository clubsRepository;

  const MyApp({
    Key? key,
    required this.authRepository,
    required this.stepsRepository,
    required this.clubsRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: stepsRepository),
        RepositoryProvider.value(value: clubsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository)
              ..add(const AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ClubBloc(clubsRepository),
          ),
          // 他のBLoCも追加
        ],
        child: MaterialApp(
          // ... アプリ設定
        ),
      ),
    );
  }
}
```

### ステップ7: ClubBLoCを更新

`mobile_app/lib/features/club/bloc/club_bloc.dart` で新しいリポジトリを使用:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/clubs_repository.dart';
import 'club_event.dart';
import 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final ClubsRepository _clubsRepository;  // 変更

  ClubBloc(this._clubsRepository) : super(const ClubInitial()) {
    on<LoadAllClubs>(_onLoadAllClubs);
    on<LoadFavoriteClub>(_onLoadFavoriteClub);
    on<ChangeFavoriteClub>(_onChangeFavoriteClub);
    on<ResetClub>(_onResetClub);
  }

  Future<void> _onLoadAllClubs(
    LoadAllClubs event,
    Emitter<ClubState> emit,
  ) async {
    emit(const ClubLoading());

    try {
      final response = await _clubsRepository.getAllClubs();
      emit(ClubLoaded(clubs: response.clubs));
    } catch (e) {
      emit(ClubError(message: e.toString()));
    }
  }

  // 他のイベントハンドラーも同様に更新
}
```

### ステップ8: テストの作成

`mobile_app/test/data/repositories/base_repository_test.dart` を作成:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// テスト用のリポジトリ実装
class TestRepository extends BaseRepository {
  final Function mockApiCall;

  TestRepository(this.mockApiCall);

  Future<String> testCall() async {
    return executeApiCall(
      apiCall: () => mockApiCall() as Future<HttpResponse<String>>,
      operationName: 'テスト',
    );
  }
}

void main() {
  group('BaseRepository', () {
    test('正常系: データが返される', () async {
      final mockResponse = HttpResponse('success', Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      ));

      final repository = TestRepository(() => Future.value(mockResponse));
      final result = await repository.testCall();

      expect(result, 'success');
    });

    test('異常系: レスポンスがnull', () async {
      final mockResponse = HttpResponse<String?>(null, Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      ));

      final repository = TestRepository(() => Future.value(mockResponse));

      expect(
        () => repository.testCall(),
        throwsA(isA<ServerException>()),
      );
    });

    test('異常系: DioException', () async {
      final repository = TestRepository(() => Future.error(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      ));

      expect(
        () => repository.testCall(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

## ✅ チェックリスト

- [ ] `lib/core/error/error_handler.dart` を作成
- [ ] `lib/data/repositories/base_repository.dart` を作成
- [ ] `AuthRepository` をリファクタリング
- [ ] `StepsRepository` を作成
- [ ] `ClubsRepository` を作成
- [ ] `main.dart` で依存性注入を設定
- [ ] `ClubBloc` を新しいリポジトリに更新
- [ ] 他のBLoCも更新（必要に応じて）
- [ ] ユニットテストを作成
- [ ] 統合テストを実行
- [ ] 動作確認（実機/エミュレーター）

## ⏱️ 推定作業時間

- 基底クラス作成: 1時間
- リポジトリリファクタリング: 2時間
- BLoC更新: 1時間
- テスト作成・実行: 1.5時間
- 動作確認: 30分

**合計**: 約6時間

## 📈 期待される効果

- ✅ **コード行数が約150行削減** (AuthRepositoryだけで70%削減)
- ✅ **新規リポジトリ作成が超簡単に** (5行程度で1メソッド追加可能)
- ✅ **エラーハンドリングの一貫性向上**
- ✅ **テストカバレッジの向上** (基底クラスをテストすれば全体がカバー)
- ✅ **バグ発生リスクの低減**

## 🔄 Before/After比較

### Before
```dart
// 1メソッドあたり約25行
Future<AuthResponse> login(LoginRequest request) async {
  try {
    final response = await _apiClient.login(request);
    if (response.data == null) {
      throw Exception('ログインに失敗しました');
    }
    return response.data!;
  } on DioException catch (e) {
    throw _handleDioError(e);  // 35行の巨大メソッド
  } catch (e) {
    throw Exception('ログインエラー: ${e.toString()}');
  }
}
```

### After
```dart
// 1メソッドあたり約5行 (80%削減!)
Future<AuthResponse> login(LoginRequest request) async {
  return executeApiCall(
    apiCall: () => _apiClient.login(request),
    operationName: 'ログイン',
  );
}
```

## 📚 参考資料

- [Repository Pattern in Flutter](https://medium.com/flutter-community/repository-design-pattern-for-flutter-b999ef752080)
- [Error Handling in Dio](https://pub.dev/packages/dio#error-handling)
- [Retrofit for Dart](https://pub.dev/packages/retrofit)
