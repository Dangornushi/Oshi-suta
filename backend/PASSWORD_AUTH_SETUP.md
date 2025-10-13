# パスワード認証のセットアップガイド

## 概要

このガイドでは、Firebase Authenticationを使用したパスワード認証の設定方法を説明します。

## 🔐 実装内容

### 変更されたファイル

1. **backend/app/config.py**
   - `FIREBASE_WEB_API_KEY` 設定を追加

2. **backend/app/utils/security.py**
   - `verify_password_with_firebase()` 関数を追加（Firebase Auth REST APIでパスワード検証）

3. **backend/app/api/v1/endpoints/auth.py**
   - `login` エンドポイントを更新（パスワード検証を追加）

4. **backend/requirements.txt**
   - `requests` ライブラリを追加

## 📝 セットアップ手順

### 1. Firebase Web API Keyの取得

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクトを選択
3. 左側メニューから「プロジェクトの設定」（歯車アイコン）をクリック
4. 「全般」タブの「ウェブ API キー」をコピー

### 2. 環境変数の設定

`backend/.env` ファイルに以下を追加：

```env
FIREBASE_WEB_API_KEY=your-web-api-key-here
```

または、Docker Composeを使用している場合は `docker-compose.yml` に追加：

```yaml
environment:
  - FIREBASE_WEB_API_KEY=your-web-api-key-here
```

### 3. 依存関係のインストール

```bash
cd backend
pip install -r requirements.txt
```

Docker を使用している場合：

```bash
docker-compose build
```

### 4. 動作確認

サーバーを起動：

```bash
# ローカル環境
uvicorn app.main:app --reload

# または Docker
docker-compose up
```

## 🔄 認証フロー

### ログイン時の処理

```
1. ユーザーがメール・パスワードを入力
   ↓
2. POST /api/v1/auth/login
   {
     "email": "user@example.com",
     "password": "Password123"
   }
   ↓
3. verify_password_with_firebase() を呼び出し
   ↓
4. Firebase Auth REST API にリクエスト
   POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword
   ↓
5. パスワードが正しい場合、Firebase UIDを取得
   ↓
6. FirestoreからユーザーデータをUIDで検索
   ↓
7. JWTトークンを生成
   ↓
8. レスポンス
   {
     "access_token": "eyJ...",
     "token_type": "bearer",
     "user_id": "firebase_uid",
     "email": "user@example.com",
     "nickname": "サポ太郎",
     "club_id": "urawa_reds"
   }
```

## 🔍 パスワードの保存場所

### Firebase Authentication
- **場所**: Firebase Authに暗号化されて保存
- **アクセス方法**: Firebase Admin SDK または Firebase Auth REST API
- **セキュリティ**: Googleが管理する高セキュリティな環境

### Firestore
- **パスワードは保存されない**（セキュリティ上正しい）
- ユーザー情報のみ保存：
  - `user_id` (Firebase UID)
  - `email`
  - `nickname`
  - `club_id`
  - `total_points`
  - `total_steps`

## 🧪 テスト方法

### 1. ユーザー登録

```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123",
    "nickname": "テストユーザー",
    "club_id": "urawa_reds"
  }'
```

### 2. ログイン（正しいパスワード）

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123"
  }'
```

**期待される結果**: ステータスコード 200、トークンとユーザー情報が返却

### 3. ログイン（間違ったパスワード）

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "WrongPassword"
  }'
```

**期待される結果**: ステータスコード 401、エラーメッセージ

## 🔧 トラブルシューティング

### エラー: "FIREBASE_WEB_API_KEY is not configured"

**原因**: 環境変数が設定されていない

**解決方法**:
1. `.env` ファイルに `FIREBASE_WEB_API_KEY` を追加
2. サーバーを再起動

### エラー: "Invalid email or password"

**原因**:
- メールアドレスが間違っている
- パスワードが間違っている
- ユーザーがFirebase Authに登録されていない

**解決方法**:
1. Firebase Console でユーザーが登録されているか確認
2. 正しい認証情報を使用

### エラー: "User data not found"

**原因**: Firebase Authにはユーザーが存在するが、Firestoreにユーザーデータがない

**解決方法**:
1. `/auth/register` エンドポイントを使用して登録
2. または、Firestoreに手動でユーザーデータを追加

## 📚 Firebase Auth REST API リファレンス

### エンドポイント
```
POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}
```

### リクエストボディ
```json
{
  "email": "user@example.com",
  "password": "Password123",
  "returnSecureToken": true
}
```

### レスポンス（成功時）
```json
{
  "localId": "firebase_user_id",
  "email": "user@example.com",
  "idToken": "eyJ...",
  "refreshToken": "refresh_token",
  "expiresIn": "3600"
}
```

### エラーレスポンス
```json
{
  "error": {
    "code": 400,
    "message": "INVALID_PASSWORD",
    "errors": [...]
  }
}
```

## 🔒 セキュリティのベストプラクティス

1. **Web API Keyの保護**
   - 環境変数で管理
   - `.env` ファイルを `.gitignore` に追加
   - 本番環境では秘密管理サービスを使用

2. **HTTPS を使用**
   - 本番環境では必ずHTTPSを使用
   - パスワードが平文で送信されないようにする

3. **レート制限**
   - ログイン試行回数を制限
   - Firebase Authが自動的に不審なアクティビティを検出

4. **トークンの管理**
   - JWTトークンに適切な有効期限を設定
   - リフレッシュトークンの実装を検討

## 📖 参考資料

- [Firebase Authentication REST API](https://firebase.google.com/docs/reference/rest/auth)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)