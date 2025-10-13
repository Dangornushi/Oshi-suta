# Docker開発環境セットアップガイド

## 📋 概要

このプロジェクトはDockerとDocker Composeを使用して開発環境を構築しています。

## 🏗️ アーキテクチャ

```
┌─────────────────────────────────────────┐
│  docker-compose.yml                     │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │     API      │    │    Redis     │  │
│  │  (FastAPI)   │───▶│   (Cache)    │  │
│  │  Port: 8000  │    │  Port: 6379  │  │
│  └──────────────┘    └──────────────┘  │
│         │                               │
│         ▼                               │
│  ┌──────────────┐                      │
│  │   Firestore  │                      │
│  │  (Firebase)  │                      │
│  └──────────────┘                      │
└─────────────────────────────────────────┘
```

## 🚀 セットアップ手順

### 1. 前提条件の確認

以下がインストールされていることを確認：

```bash
docker --version
docker-compose --version
```

### 2. Firebase認証情報の配置

Firebase Admin SDKの認証情報ファイルを取得し、配置：

```bash
# backend/ディレクトリに配置
cp /path/to/your/firebase-credentials.json backend/oshi-suta-battle-firebase-adminsdk-fbsvc-47d1d81ed5.json
```

### 3. 環境変数の確認

プロジェクトルートの `.env` ファイルが存在することを確認：

```bash
cat .env
```

内容：
```env
FIREBASE_WEB_API_KEY=AIzaSyCrGjKDwfa_UJdUL3ucqSQ8Yd0k8os-flY
```

### 4. Docker Composeでビルド＆起動

```bash
# プロジェクトルートで実行
docker-compose up --build
```

初回は数分かかる場合があります。

### 5. 動作確認

別のターミナルで以下を実行：

```bash
# ヘルスチェック
curl http://localhost:8000/api/v1/health

# 期待されるレスポンス
{
  "status": "healthy",
  "timestamp": "2025-10-13T...",
  "version": "0.1.0",
  "services": {
    "firestore": "healthy",
    "redis": "healthy"
  }
}
```

## 🔧 開発コマンド

### コンテナの起動

```bash
# フォアグラウンドで起動（ログを表示）
docker-compose up

# バックグラウンドで起動
docker-compose up -d
```

### コンテナの停止

```bash
# 停止
docker-compose down

# 停止 + ボリューム削除（データベースもクリア）
docker-compose down -v
```

### コンテナの再ビルド

コードやDockerfileを変更した場合：

```bash
docker-compose up --build
```

### ログの確認

```bash
# 全コンテナのログ
docker-compose logs

# APIコンテナのログのみ
docker-compose logs api

# リアルタイムでログを追跡
docker-compose logs -f api
```

### コンテナ内でコマンド実行

```bash
# APIコンテナに入る
docker-compose exec api bash

# コンテナ内で実行できること
python -m pytest          # テスト実行
pip list                  # インストール済みパッケージ確認
uvicorn app.main:app      # サーバー手動起動
```

## 📁 ディレクトリ構造

```
Oshi-suta/
├── .env                           # Docker Compose用環境変数
├── docker-compose.yml             # Docker Compose設定
├── backend/
│   ├── .env                       # バックエンドアプリ用環境変数
│   ├── Dockerfile                 # APIコンテナのビルド定義
│   ├── requirements.txt           # Python依存関係
│   ├── oshi-suta-battle-firebase-adminsdk-*.json  # Firebase認証情報
│   └── app/
│       └── ...                    # アプリケーションコード
└── mobile_app/
    └── ...                        # Flutterアプリ
```

## 🔄 ホットリロード

`docker-compose.yml`で以下の設定により、コード変更が自動的に反映されます：

```yaml
volumes:
  - ./backend:/app           # ローカルのコードをマウント
command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

ファイルを編集すると、自動的にサーバーが再起動します。

## 🐛 トラブルシューティング

### ポートが既に使用されている

```bash
# エラー例
Error: bind: address already in use

# 解決方法：使用中のプロセスを確認
lsof -i :8000
lsof -i :6379

# プロセスを停止
kill -9 <PID>
```

### Firebase認証エラー

```bash
# エラー例
Error: Could not load Firebase credentials

# 解決方法
1. backend/ディレクトリにFirebase認証情報ファイルがあるか確認
2. docker-compose.ymlのFIREBASE_CREDENTIALS_PATHが正しいか確認
3. コンテナを再ビルド: docker-compose up --build
```

### Redis接続エラー

```bash
# Redisコンテナの状態を確認
docker-compose ps redis

# Redisのヘルスチェック
docker-compose exec redis redis-cli ping
# 期待される出力: PONG
```

### 依存関係のエラー

```bash
# requirements.txtを更新した場合
docker-compose build --no-cache api
docker-compose up
```

### コンテナのクリーンアップ

```bash
# 全コンテナ停止＆削除
docker-compose down

# 未使用のイメージ・ボリュームも削除
docker system prune -a --volumes
```

## 📊 コンテナの状態確認

```bash
# 実行中のコンテナ
docker-compose ps

# コンテナのリソース使用状況
docker stats

# 特定のコンテナの詳細情報
docker-compose logs api
```

## 🧪 テストの実行

```bash
# コンテナ内でテスト実行
docker-compose exec api python -m pytest

# 詳細な出力
docker-compose exec api python -m pytest -v

# 特定のテストファイル
docker-compose exec api python -m pytest tests/test_auth.py
```

## 🔐 環境変数の管理

### .envファイルの優先順位

1. `docker-compose.yml`の`environment`セクション（最優先）
2. プロジェクトルートの`.env`（Docker Compose用）
3. `backend/.env`（アプリケーション用）

### 本番環境用設定

本番環境では、`.env`ファイルではなく、Docker Compose overrideまたは環境変数を直接指定：

```bash
# 本番環境用のdocker-compose.prod.yml
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## 📝 API ドキュメント

サーバー起動後、以下のURLでAPIドキュメントを確認：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🔗 関連ドキュメント

- [README.md](README.md) - プロジェクト概要
- [PASSWORD_AUTH_SETUP.md](backend/PASSWORD_AUTH_SETUP.md) - パスワード認証セットアップ
- [AUTHENTICATION_GUIDE.md](mobile_app/AUTHENTICATION_GUIDE.md) - Flutter認証実装ガイド

## 💡 ベストプラクティス

1. **コードを変更したら**: 自動リロードされるので再起動不要
2. **Dockerfileを変更したら**: `docker-compose up --build`
3. **requirements.txtを変更したら**: `docker-compose build --no-cache api`
4. **環境変数を変更したら**: `docker-compose down && docker-compose up`
5. **データベースをリセットしたら**: `docker-compose down -v`