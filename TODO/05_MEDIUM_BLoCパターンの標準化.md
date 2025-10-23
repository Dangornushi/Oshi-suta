# 優先度 MEDIUM: BLoCパターンの標準化

## 🎯 目的
モバイルアプリのBLoCで繰り返されているエラーハンドリングとローディング状態管理を共通化し、コードの重複を削減する。

## 📊 現在の問題

### 問題1: BLoCエラーハンドリングの重複 (8+ 箇所)

```dart
// auth_bloc.dart と club_bloc.dart で繰り返される
try {
  // 処理
} catch (e) {
  emit(AuthError(e.toString().replaceAll('Exception: ', '')));
  emit(const AuthUnauthenticated());
}
```

### 問題2: ローディング状態の重複 (4箇所)

```dart
// club_bloc.dart で繰り返される
emit(const ClubLoading());

try {
    // 操作実行
} catch (e) {
    emit(ClubError(message: '...'));
}
```

## 📋 実装手順

### ステップ1: 基底BLoCクラスを作成

`mobile_app/lib/features/common/base_bloc.dart` を新規作成:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/error/error_handler.dart';

/// BLoC基底クラス
///
/// 共通のエラーハンドリングとローディング状態管理を提供
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// 共通のエラーハンドリング付き非同期処理
  ///
  /// ローディング状態の emit と エラーハンドリングを自動的に行う
  ///
  /// 使用例:
  /// ```dart
  /// await executeWithErrorHandling(
  ///   emit: emit,
  ///   operation: () async {
  ///     final data = await repository.getData();
  ///     emit(DataLoaded(data));
  ///   },
  ///   loadingState: () => const DataLoading(),
  ///   errorState: (message) => DataError(message),
  /// );
  /// ```
  Future<void> executeWithErrorHandling({
    required Emitter<State> emit,
    required Future<void> Function() operation,
    required State Function() loadingState,
    required State Function(String errorMessage) errorState,
    State Function()? fallbackState,
  }) async {
    emit(loadingState());

    try {
      await operation();
    } catch (e) {
      final appException = ErrorHandler.handleError(e);
      emit(errorState(appException.message));

      // オプション: エラー後のフォールバック状態
      if (fallbackState != null) {
        Future.microtask(() => emit(fallbackState()));
      }
    }
  }

  /// リトライ機能付きの非同期処理
  ///
  /// 失敗時に指定回数リトライする
  Future<void> executeWithRetry({
    required Emitter<State> emit,
    required Future<void> Function() operation,
    required State Function() loadingState,
    required State Function(String errorMessage) errorState,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    emit(loadingState());

    int attempt = 0;
    AppException? lastException;

    while (attempt < maxRetries) {
      try {
        await operation();
        return; // 成功したら終了
      } catch (e) {
        lastException = ErrorHandler.handleError(e);
        attempt++;

        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }

    // 全てのリトライが失敗
    if (lastException != null) {
      emit(errorState(lastException.message));
    }
  }
}
```

### ステップ2: AuthBLoCをリファクタリング

`mobile_app/lib/features/auth/bloc/auth_bloc.dart` を修正:

**修正前** (約150行):
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    // ...
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.login(event.request);
      await _saveAuthData(response);
      emit(AuthAuthenticated(user: _mapToUser(response)));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  // 他のイベントハンドラーも同様のパターン
}
```

**修正後** (約100行 - 30%削減):
```dart
import '../../common/base_bloc.dart';

class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  /// ログイン処理
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
      errorState: (message) => AuthError(message),
      fallbackState: () => const AuthUnauthenticated(),
    );
  }

  /// ユーザー登録処理
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    await executeWithErrorHandling(
      emit: emit,
      operation: () async {
        final response = await _authRepository.register(event.request);
        await _saveAuthData(response);
        emit(AuthAuthenticated(user: _mapToUser(response)));
      },
      loadingState: () => const AuthLoading(),
      errorState: (message) => AuthError(message),
      fallbackState: () => const AuthUnauthenticated(),
    );
  }

  /// ログアウト処理
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await executeWithErrorHandling(
      emit: emit,
      operation: () async {
        await _clearAuthData();
        emit(const AuthUnauthenticated());
      },
      loadingState: () => const AuthLoading(),
      errorState: (message) => AuthError(message),
    );
  }

  /// 認証状態チェック
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await LocalStorage.getIsLoggedIn();

    if (isLoggedIn) {
      final userId = await LocalStorage.getUserId();
      final email = await LocalStorage.getUserEmail();
      final clubId = await LocalStorage.getClubId();

      if (userId != null && email != null) {
        emit(AuthAuthenticated(
          user: User(
            userId: userId,
            email: email,
            clubId: clubId,
          ),
        ));
        return;
      }
    }

    emit(const AuthUnauthenticated());
  }

  /// プロフィール更新
  Future<void> _onProfileRefreshRequested(
    AuthProfileRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    await executeWithRetry(  // リトライ機能を使用
      emit: emit,
      operation: () async {
        final profile = await _authRepository.getProfile();
        emit(AuthAuthenticated(user: _mapToUser(profile)));
      },
      loadingState: () => const AuthLoading(),
      errorState: (message) => AuthError(message),
      maxRetries: 3,
    );
  }

  // ヘルパーメソッド
  Future<void> _saveAuthData(AuthResponse response) async {
    await LocalStorage.saveAccessToken(response.accessToken);
    await LocalStorage.saveUserId(response.user.userId);
    await LocalStorage.saveUserEmail(response.user.email);
    if (response.user.clubId != null) {
      await LocalStorage.saveClubId(response.user.clubId!);
    }
    await LocalStorage.setLoggedIn(true);
  }

  Future<void> _clearAuthData() async {
    await LocalStorage.clear();
  }

  User _mapToUser(dynamic response) {
    if (response is AuthResponse) {
      return response.user;
    } else if (response is UserProfileResponse) {
      return User(
        userId: response.userId,
        email: response.email,
        nickname: response.nickname,
        clubId: response.clubId,
        totalPoints: response.totalPoints,
      );
    }
    throw Exception('Unknown response type');
  }
}
```

### ステップ3: ClubBLoCをリファクタリング

`mobile_app/lib/features/club/bloc/club_bloc.dart` を修正:

**修正前** (約120行):
```dart
class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final ClubsRepository _clubsRepository;

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
      print('Failed to load clubs: $e');
      emit(const ClubError(message: '全クラブの読み込みに失敗しました'));
    }
  }

  // 他のイベントハンドラーも同様
}
```

**修正後** (約80行 - 33%削減):
```dart
import '../../common/base_bloc.dart';

class ClubBloc extends BaseBloc<ClubEvent, ClubState> {
  final ClubsRepository _clubsRepository;

  ClubBloc(this._clubsRepository) : super(const ClubInitial()) {
    on<LoadAllClubs>(_onLoadAllClubs);
    on<LoadFavoriteClub>(_onLoadFavoriteClub);
    on<ChangeFavoriteClub>(_onChangeFavoriteClub);
    on<ResetClub>(_onResetClub);
  }

  /// 全クラブ一覧を読み込み
  Future<void> _onLoadAllClubs(
    LoadAllClubs event,
    Emitter<ClubState> emit,
  ) async {
    await executeWithErrorHandling(
      emit: emit,
      operation: () async {
        final response = await _clubsRepository.getAllClubs();
        emit(ClubLoaded(clubs: response.clubs));
      },
      loadingState: () => const ClubLoading(),
      errorState: (message) => ClubError(message: message),
    );
  }

  /// お気に入りクラブを読み込み
  Future<void> _onLoadFavoriteClub(
    LoadFavoriteClub event,
    Emitter<ClubState> emit,
  ) async {
    await executeWithErrorHandling(
      emit: emit,
      operation: () async {
        final favoriteClubId = await LocalStorage.getFavoriteClubId();

        if (favoriteClubId != null) {
          final clubInfo = await _clubsRepository.getClubInfo(favoriteClubId);
          emit(ClubLoaded(clubs: [clubInfo]));
        } else {
          emit(const ClubInitial());
        }
      },
      loadingState: () => const ClubLoading(),
      errorState: (message) => ClubError(message: message),
    );
  }

  /// お気に入りクラブを変更
  Future<void> _onChangeFavoriteClub(
    ChangeFavoriteClub event,
    Emitter<ClubState> emit,
  ) async {
    await executeWithErrorHandling(
      emit: emit,
      operation: () async {
        // API経由でクラブ変更
        await _clubsRepository.joinClub(event.clubId);

        // ローカルストレージに保存
        await LocalStorage.saveFavoriteClubId(event.clubId);
        await LocalStorage.saveFavoriteClubName(event.clubName);

        // 変更後のクラブ情報を取得
        final clubInfo = await _clubsRepository.getClubInfo(event.clubId);
        emit(ClubLoaded(clubs: [clubInfo]));
      },
      loadingState: () => const ClubLoading(),
      errorState: (message) => ClubError(message: message),
    );
  }

  /// クラブ情報をリセット
  Future<void> _onResetClub(
    ResetClub event,
    Emitter<ClubState> emit,
  ) async {
    await LocalStorage.removeFavoriteClubId();
    await LocalStorage.removeFavoriteClubName();
    emit(const ClubInitial());
  }
}
```

### ステップ4: テストの作成

`mobile_app/test/features/common/base_bloc_test.dart` を作成:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

// テスト用のBLoC実装
enum TestEvent { load, error }

abstract class TestState {
  const TestState();
}

class TestInitial extends TestState {
  const TestInitial();
}

class TestLoading extends TestState {
  const TestLoading();
}

class TestLoaded extends TestState {
  final String data;
  const TestLoaded(this.data);
}

class TestError extends TestState {
  final String message;
  const TestError(this.message);
}

class TestBloc extends BaseBloc<TestEvent, TestState> {
  final Future<String> Function() mockOperation;

  TestBloc(this.mockOperation) : super(const TestInitial()) {
    on<TestEvent>((event, emit) async {
      if (event == TestEvent.error) {
        await executeWithErrorHandling(
          emit: emit,
          operation: () async {
            throw Exception('Test error');
          },
          loadingState: () => const TestLoading(),
          errorState: (message) => TestError(message),
        );
      } else {
        await executeWithErrorHandling(
          emit: emit,
          operation: () async {
            final result = await mockOperation();
            emit(TestLoaded(result));
          },
          loadingState: () => const TestLoading(),
          errorState: (message) => TestError(message),
        );
      }
    });
  }
}

void main() {
  group('BaseBloc', () {
    blocTest<TestBloc, TestState>(
      '正常系: データが正しく読み込まれる',
      build: () => TestBloc(() => Future.value('success')),
      act: (bloc) => bloc.add(TestEvent.load),
      expect: () => [
        const TestLoading(),
        const TestLoaded('success'),
      ],
    );

    blocTest<TestBloc, TestState>(
      '異常系: エラーが正しく処理される',
      build: () => TestBloc(() => throw Exception('error')),
      act: (bloc) => bloc.add(TestEvent.error),
      expect: () => [
        const TestLoading(),
        isA<TestError>(),
      ],
    );
  });
}
```

### ステップ5: 依存パッケージを追加

`mobile_app/pubspec.yaml` に追加:

```yaml
dev_dependencies:
  bloc_test: ^9.1.0  # BLoCテスト用
```

```bash
cd mobile_app
flutter pub get
```

## ✅ チェックリスト

- [ ] `lib/features/common/base_bloc.dart` を作成
- [ ] `AuthBloc` をリファクタリング
- [ ] `ClubBloc` をリファクタリング
- [ ] `bloc_test` パッケージを追加
- [ ] `test/features/common/base_bloc_test.dart` を作成
- [ ] ユニットテストを実行
- [ ] 動作確認（実機/エミュレーター）
- [ ] 既存の重複コードを削除

## ⏱️ 推定作業時間

- 基底クラス作成: 1.5時間
- AuthBLoC リファクタリング: 1時間
- ClubBLoC リファクタリング: 1時間
- テスト作成・実行: 1.5時間
- 動作確認: 30分

**合計**: 約5.5時間

## 📈 期待される効果

- ✅ **コード行数が約90行削減** (AuthBLoC + ClubBLoC)
- ✅ **BLoCの一貫性向上**
- ✅ **エラーハンドリングの標準化**
- ✅ **リトライ機能の簡単な追加**
- ✅ **新規BLoC作成が超簡単に**

## 🔄 Before/After比較

### Before
```dart
// 1イベントハンドラーあたり約15行
Future<void> _onLoadAllClubs(...) async {
  emit(const ClubLoading());

  try {
    final response = await _clubsRepository.getAllClubs();
    emit(ClubLoaded(clubs: response.clubs));
  } catch (e) {
    print('Failed to load clubs: $e');
    emit(const ClubError(message: '全クラブの読み込みに失敗しました'));
  }
}
```

### After
```dart
// 1イベントハンドラーあたり約10行 (33%削減!)
Future<void> _onLoadAllClubs(...) async {
  await executeWithErrorHandling(
    emit: emit,
    operation: () async {
      final response = await _clubsRepository.getAllClubs();
      emit(ClubLoaded(clubs: response.clubs));
    },
    loadingState: () => const ClubLoading(),
    errorState: (message) => ClubError(message: message),
  );
}
```

## 📚 参考資料

- [BLoC Pattern Best Practices](https://bloclibrary.dev/#/coreconcepts)
- [Error Handling in BLoC](https://bloclibrary.dev/#/coreconcepts?id=error-handling)
- [BLoC Testing](https://bloclibrary.dev/#/testing)
