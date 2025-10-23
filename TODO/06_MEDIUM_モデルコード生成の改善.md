# 優先度 MEDIUM: モデルコード生成の改善

## 🎯 目的
Flutterモバイルアプリで手動で書かれている `copyWith`、`==`、`hashCode` などのボイラープレートコードを自動生成に切り替え、コードの重複を削減する。

## 📊 現在の問題

全てのモデルクラスで同じ構造のコードが手動で書かれている:

```dart
// club_model.dart, user_model.dart, step_log_model.dart など

// copyWith メソッド (20行)
ClubInfo copyWith({
  String? clubId,
  String? name,
  // ... 多数のフィールド
}) {
  return ClubInfo(
    clubId: clubId ?? this.clubId,
    name: name ?? this.name,
    // ...
  );
}

// equality operator (5行)
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  return other is ClubInfo &&
      other.clubId == clubId &&
      other.name == name;
      // ...
}

// hashCode (3行)
@override
int get hashCode => Object.hash(clubId, name, ...);
```

**問題点**:
- 各モデルで50-80行の重複コード
- フィールド追加時に手動更新が必要
- ヒューマンエラーのリスク

## 📋 実装手順

### ステップ1: freezedパッケージを導入

`freezed` は、Dart/Flutter向けのコード生成パッケージで、以下を自動生成します:
- `copyWith` メソッド
- `==` operator と `hashCode`
- `toString` メソッド
- Immutableクラス
- Union型（sealed class）

#### 1.1 依存パッケージを追加

`mobile_app/pubspec.yaml` を修正:

```yaml
dependencies:
  # 既存の依存関係
  freezed_annotation: ^2.4.1  # 追加

dev_dependencies:
  # 既存のdev依存関係
  build_runner: ^2.4.6  # 追加
  freezed: ^2.4.5  # 追加
  json_serializable: ^6.7.1  # 既存（バージョン確認）
```

#### 1.2 パッケージをインストール

```bash
cd mobile_app
flutter pub get
```

### ステップ2: モデルクラスをリファクタリング

#### 2.1 ClubModel を freezed に変換

**修正前** (`club_model.dart` - 約150行):
```dart
import 'package:json_annotation/json_annotation.dart';

part 'club_model.g.dart';

@JsonSerializable()
class ClubInfo {
  @JsonKey(name: 'club_id')
  final String clubId;

  final String name;

  @JsonKey(name: 'total_points')
  final int totalPoints;

  // ... 他のフィールド

  const ClubInfo({
    required this.clubId,
    required this.name,
    required this.totalPoints,
    // ...
  });

  factory ClubInfo.fromJson(Map<String, dynamic> json) =>
      _$ClubInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ClubInfoToJson(this);

  // copyWith メソッド (25行)
  ClubInfo copyWith({
    String? clubId,
    String? name,
    int? totalPoints,
    // ...
  }) {
    return ClubInfo(
      clubId: clubId ?? this.clubId,
      name: name ?? this.name,
      totalPoints: totalPoints ?? this.totalPoints,
      // ...
    );
  }

  // equality operator (10行)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClubInfo &&
        other.clubId == clubId &&
        other.name == name &&
        other.totalPoints == totalPoints;
        // ...
  }

  // hashCode (3行)
  @override
  int get hashCode => Object.hash(clubId, name, totalPoints, ...);

  // toString (5行)
  @override
  String toString() {
    return 'ClubInfo(clubId: $clubId, name: $name, ...)';
  }
}
```

**修正後** (`club_model.dart` - 約40行、73%削減!):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_model.freezed.dart';
part 'club_model.g.dart';

@freezed
class ClubInfo with _$ClubInfo {
  const factory ClubInfo({
    @JsonKey(name: 'club_id') required String clubId,
    required String name,
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    @JsonKey(name: 'active_members') @Default(0) int activeMembers,
    @JsonKey(name: 'league_rank') @Default(0) int leagueRank,
    @JsonKey(name: 'founded_year') @Default(1900) int foundedYear,
    @Default('') String stadium,
    @JsonKey(name: 'logo_url') String? logoUrl,
  }) = _ClubInfo;

  factory ClubInfo.fromJson(Map<String, dynamic> json) =>
      _$ClubInfoFromJson(json);
}
```

**変更点**:
- `@freezed` アノテーションを追加
- `const factory` コンストラクタに変更
- `@Default()` でデフォルト値を指定
- `copyWith`, `==`, `hashCode`, `toString` は自動生成される
- `part` ディレクティブで生成ファイルを参照

#### 2.2 UserModel を freezed に変換

**修正後** (`user_model.dart`):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: 'user_id') required String userId,
    required String email,
    String? nickname,
    @JsonKey(name: 'club_id') String? clubId,
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    @JsonKey(name: 'total_steps') @Default(0) int totalSteps,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}
```

#### 2.3 StepLogModel を freezed に変換

**修正後** (`step_log_model.dart`):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'step_log_model.freezed.dart';
part 'step_log_model.g.dart';

@freezed
class StepLog with _$StepLog {
  const factory StepLog({
    required String date,
    required int steps,
    required int points,
    @Default('') String source,
    @JsonKey(name: 'device_signature') String? deviceSignature,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _StepLog;

  factory StepLog.fromJson(Map<String, dynamic> json) =>
      _$StepLogFromJson(json);
}

@freezed
class StepSyncRequest with _$StepSyncRequest {
  const factory StepSyncRequest({
    required int steps,
    required String date,
    @Default('manual') String source,
    @JsonKey(name: 'device_signature') String? deviceSignature,
  }) = _StepSyncRequest;

  factory StepSyncRequest.fromJson(Map<String, dynamic> json) =>
      _$StepSyncRequestFromJson(json);
}

@freezed
class StepSyncResponse with _$StepSyncResponse {
  const factory StepSyncResponse({
    @JsonKey(name: 'points_earned') required int pointsEarned,
    @JsonKey(name: 'total_points') required int totalPoints,
    @JsonKey(name: 'club_contribution') required int clubContribution,
    @JsonKey(name: 'synced_at') required String syncedAt,
  }) = _StepSyncResponse;

  factory StepSyncResponse.fromJson(Map<String, dynamic> json) =>
      _$StepSyncResponseFromJson(json);
}
```

#### 2.4 AuthResponse を freezed に変換

**修正後** (`auth_response.dart`):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
    required User user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    required String nickname,
    @JsonKey(name: 'club_id') required String clubId,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
```

### ステップ3: コード生成を実行

```bash
cd mobile_app

# 全モデルのコードを生成
flutter pub run build_runner build --delete-conflicting-outputs

# または、ウォッチモード（ファイル変更時に自動生成）
flutter pub run build_runner watch --delete-conflicting-outputs
```

**生成されるファイル**:
- `*.freezed.dart` - freezed によるコード生成
- `*.g.dart` - json_serializable によるコード生成

### ステップ4: 使用箇所の更新

#### 4.1 copyWith の使用

**Before**:
```dart
final updatedUser = user.copyWith(
  nickname: 'New Nickname',
);
```

**After** (同じAPI、自動生成されたメソッドを使用):
```dart
final updatedUser = user.copyWith(
  nickname: 'New Nickname',
);
```

#### 4.2 Equality チェック

**Before**:
```dart
if (user1 == user2) {
  // 同じユーザー
}
```

**After** (同じAPI):
```dart
if (user1 == user2) {
  // 同じユーザー
}
```

#### 4.3 デバッグ出力

**Before**:
```dart
print(user.toString());
```

**After** (自動生成された toString を使用):
```dart
print(user);  // より詳細な情報が出力される
```

### ステップ5: .gitignore を更新

`mobile_app/.gitignore` に追加:

```gitignore
# Freezed 生成ファイル
*.freezed.dart

# Json Serializable 生成ファイルは既に含まれている
# *.g.dart
```

### ステップ6: Union型の活用（オプション）

freezed の強力な機能として、Union型（sealed class）があります。
BLoC の State クラスに活用できます。

**例**: `auth_state.dart` を Union型に変換

**Before**:
```dart
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
```

**After**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated({required User user}) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

**使用時**:
```dart
// パターンマッチング
state.when(
  initial: () => Text('初期化中'),
  loading: () => CircularProgressIndicator(),
  authenticated: (user) => Text('ようこそ ${user.nickname}'),
  unauthenticated: () => Text('ログインしてください'),
  error: (message) => Text('エラー: $message'),
);

// または maybeWhen
state.maybeWhen(
  authenticated: (user) => Text('ようこそ ${user.nickname}'),
  orElse: () => Text('その他'),
);
```

## ✅ チェックリスト

- [ ] `freezed` と `freezed_annotation` を追加
- [ ] `ClubModel` を freezed に変換
- [ ] `UserModel` を freezed に変換
- [ ] `StepLogModel` を freezed に変換
- [ ] `AuthResponse` を freezed に変換
- [ ] `ClubListResponse` を freezed に変換
- [ ] コード生成を実行
- [ ] 既存の手動実装を削除
- [ ] `.gitignore` を更新
- [ ] テストを実行
- [ ] 動作確認
- [ ] （オプション）State クラスを Union型に変換

## ⏱️ 推定作業時間

- パッケージ追加: 15分
- モデルクラス変換: 3時間
- コード生成・確認: 30分
- テスト・デバッグ: 1.5時間
- 動作確認: 30分

**合計**: 約5.5時間

## 📈 期待される効果

- ✅ **コード行数が約300行削減** (全モデル合計で70%削減)
- ✅ **フィールド追加時の手動更新が不要**
- ✅ **ヒューマンエラーのリスク低減**
- ✅ **Union型によるパターンマッチングが可能**
- ✅ **開発速度の向上**

## 🔄 Before/After比較

### Before
```dart
// 150行のモデルクラス
class ClubInfo {
  final String clubId;
  final String name;
  // ... 多数のフィールド

  const ClubInfo({...});

  factory ClubInfo.fromJson(...) => _$ClubInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ClubInfoToJson(this);

  ClubInfo copyWith({...}) {
    return ClubInfo(...);  // 25行
  }

  @override
  bool operator ==(Object other) {...}  // 10行

  @override
  int get hashCode => Object.hash(...);  // 3行

  @override
  String toString() {...}  // 5行
}
```

### After
```dart
// 40行のモデルクラス (73%削減!)
@freezed
class ClubInfo with _$ClubInfo {
  const factory ClubInfo({
    @JsonKey(name: 'club_id') required String clubId,
    required String name,
    // ... 他のフィールド
  }) = _ClubInfo;

  factory ClubInfo.fromJson(Map<String, dynamic> json) =>
      _$ClubInfoFromJson(json);
}

// copyWith, ==, hashCode, toString は自動生成!
```

## 🚨 注意事項

1. **既存コードとの互換性**: freezed に変換後も、`copyWith` などのAPIは同じなので、既存コードはほとんど変更不要
2. **生成ファイルのコミット**: `.freezed.dart` ファイルは `.gitignore` に追加し、コミットしない
3. **ビルド時間**: 初回のコード生成には時間がかかるが、その後はインクリメンタルビルドで高速化
4. **Mutable vs Immutable**: freezed はデフォルトでImmutableなので、既存のMutableなコードは調整が必要

## 📚 参考資料

- [freezed 公式ドキュメント](https://pub.dev/packages/freezed)
- [freezed を使った実践的なFlutter開発](https://medium.com/flutter-community/freezed-data-classes-in-dart-8e39a4f9891e)
- [Union型とパターンマッチング](https://pub.dev/packages/freezed#union-types-and-sealed-classes)
