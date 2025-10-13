# 認証フロー実装ガイド

このガイドでは、メール・パスワード入力後にデータベースからユーザー情報（ニックネーム・クラブなど）を取得するフローの実装方法を説明します。

## 📋 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [実装されたファイル](#実装されたファイル)
3. [セットアップ手順](#セットアップ手順)
4. [使用方法](#使用方法)
5. [フロー詳細](#フロー詳細)

## 🏗️ アーキテクチャ概要

```
┌─────────────┐
│ LoginScreen │ ← ユーザーがメール・パスワード入力
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  AuthBloc   │ ← 状態管理（flutter_bloc）
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ AuthRepository  │ ← ビジネスロジック
└──────┬──────────┘
       │
       ▼
┌─────────────┐
│  ApiClient  │ ← APIリクエスト（retrofit）
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Backend    │ ← FastAPI バックエンド
└─────────────┘
```

## 📁 実装されたファイル

### 新規作成

1. **データモデル**
   - `lib/data/models/auth_response.dart` - ログイン/登録レスポンスモデル

2. **リポジトリ**
   - `lib/data/repositories/auth_repository.dart` - 認証関連の処理を管理

3. **BLoC（状態管理）**
   - `lib/features/auth/bloc/auth_bloc.dart` - 認証状態管理のメイン
   - `lib/features/auth/bloc/auth_event.dart` - 認証イベント定義
   - `lib/features/auth/bloc/auth_state.dart` - 認証状態定義

### 更新

1. **API Client**
   - `lib/core/network/api_client.dart` - AuthResponseを返すように更新

2. **ログイン画面**
   - `lib/screens/login_screen.dart` - BLoC統合、バリデーション追加

## 🚀 セットアップ手順

### 1. コード生成

新しいモデルを追加したため、コード生成が必要です：

```bash
cd mobile_app
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. main.dartの更新

アプリのエントリーポイントで、BLoCとリポジトリを設定する必要があります：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'core/network/dio_client.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize LocalStorage
  final localStorage = LocalStorage();
  await localStorage.init();

  // Initialize Dio and ApiClient
  final dio = Dio();
  // TODO: Configure base URL from environment
  final apiClient = ApiClient(dio, baseUrl: 'http://localhost:8000/api/v1');

  // Create AuthRepository
  final authRepository = AuthRepository(
    apiClient: apiClient,
    localStorage: localStorage,
  );

  runApp(MyApp(
    authRepository: authRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({
    Key? key,
    required this.authRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authRepository: authRepository)
        ..add(const AuthCheckRequested()), // Check initial auth status
      child: MaterialApp(
        title: 'Oshi-Suta BATTLE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
```

### 3. Dioインターセプター設定（オプション）

認証トークンを自動的に付与するためのインターセプターを設定：

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class DioClient {
  final LocalStorage localStorage;
  late final Dio dio;

  DioClient({required this.localStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8000/api/v1',
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
      ),
    );

    // Add interceptor to automatically attach auth token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await localStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
```

## 📖 使用方法

### ログイン処理

```dart
// LoginScreen内で自動的に処理されます
// ユーザーがメール・パスワードを入力してログインボタンを押すと：

void _handleLogin() {
  context.read<AuthBloc>().add(
    AuthLoginRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    ),
  );
}

// BLocConsumerで状態の変化を監視：
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      // ログイン成功
      // state.userId, state.email, state.nickname, state.clubId が利用可能
      print('ユーザー: ${state.nickname}, クラブ: ${state.clubId}');
    } else if (state is AuthError) {
      // エラー表示
      print('エラー: ${state.message}');
    }
  },
  builder: (context, state) {
    // UI構築
  },
)
```

### 他の画面でユーザー情報を取得

```dart
// 任意の画面で現在の認証状態を取得
final authState = context.read<AuthBloc>().state;

if (authState is AuthAuthenticated) {
  print('ニックネーム: ${authState.nickname}');
  print('クラブID: ${authState.clubId}');
  print('ポイント: ${authState.totalPoints}');
}
```

### プロフィール情報の更新

```dart
// 詳細なプロフィール情報を取得
context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
```

### ログアウト

```dart
context.read<AuthBloc>().add(const AuthLogoutRequested());
```

## 🔄 フロー詳細

### 1. ログインフロー

```
User Input (email, password)
    ↓
LoginScreen: _handleLogin()
    ↓
AuthBloc: AuthLoginRequested event
    ↓
AuthRepository: login()
    ↓
ApiClient: POST /api/v1/auth/login
    ↓
Backend: Firestore query + JWT生成
    ↓
Response: {
  "access_token": "eyJ...",
  "token_type": "bearer",
  "user_id": "abc123",
  "email": "user@example.com",
  "nickname": "サポ太郎",
  "club_id": "urawa_reds"
}
    ↓
AuthRepository: トークン・ユーザー情報を保存
    ↓
AuthBloc: AuthAuthenticated state
    ↓
LoginScreen: 成功メッセージ表示、画面遷移
```

### 2. バックエンドレスポンス（現在の実装）

```python
# backend/app/api/v1/endpoints/auth.py:140-199

@router.post("/login", response_model=UserLoginResponse)
async def login(request: UserLoginRequest, repo: FirestoreRepository):
    # Firestoreからユーザー情報取得
    user = await repo.get_user_by_email(request.email)

    # レスポンスにユーザー情報を含める
    return UserLoginResponse(
        access_token=access_token,
        token_type="bearer",
        user_id=user_id,
        email=user["email"],
        nickname=user["nickname"],  # ← ニックネーム
        club_id=user["club_id"]      # ← クラブID
    )
```

**重要**: 現在のバックエンド実装では、ログインレスポンスに既に`nickname`と`club_id`が含まれているため、追加のAPI呼び出しは不要です。

### 3. 詳細情報が必要な場合

より詳細な情報（total_points, created_at等）が必要な場合：

```
ログイン成功後
    ↓
AuthBloc: AuthProfileRefreshRequested event
    ↓
AuthRepository: getProfile()
    ↓
ApiClient: GET /api/v1/auth/profile (with Bearer token)
    ↓
Response: {
  "user_id": "abc123",
  "email": "user@example.com",
  "nickname": "サポ太郎",
  "club_id": "urawa_reds",
  "total_points": 1500,
  "created_at": "2025-01-01T00:00:00",
  "updated_at": "2025-01-10T12:00:00"
}
    ↓
AuthBloc: AuthAuthenticated state更新（total_points追加）
```

## 🎯 ポイント

1. **ログインレスポンスに全情報が含まれる**
   - 現在の実装では、ログイン時に`nickname`と`club_id`が返却される
   - 追加のAPI呼び出しは不要

2. **LocalStorageに保存される情報**
   - `access_token`: JWT認証トークン
   - `user_id`: ユーザーID
   - `email`: メールアドレス
   - `club_id`: クラブID
   - `is_logged_in`: ログイン状態フラグ

3. **BLoCで管理される状態**
   - `AuthInitial`: 初期状態
   - `AuthLoading`: 処理中
   - `AuthAuthenticated`: ログイン済み（ユーザー情報含む）
   - `AuthUnauthenticated`: 未ログイン
   - `AuthError`: エラー

4. **エラーハンドリング**
   - バリデーションエラー（フロントエンド）
   - ネットワークエラー
   - 認証エラー（401）
   - サーバーエラー（500）

## 🔧 トラブルシューティング

### コード生成エラー

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### BLoC未提供エラー

```
Error: BlocProvider.of() called with a context that does not contain an AuthBloc
```

**解決**: `main.dart`で`BlocProvider`を正しく設定してください。

### APIエンドポイントエラー

```
DioError [DioErrorType.connectTimeout]: Connecting timed out
```

**解決**: `baseUrl`を確認し、バックエンドが起動していることを確認してください。

## 📚 参考資料

- [Flutter BLoC公式ドキュメント](https://bloclibrary.dev/)
- [Retrofit for Flutter](https://pub.dev/packages/retrofit)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Hive Local Storage](https://pub.dev/packages/hive)
