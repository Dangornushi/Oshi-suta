# Oshi-Suta BATTLE - Phase 1

Jリーグサポーター向けフィットネス×ゲーミフィケーションアプリのバックエンドAPI

## プロジェクト概要

**Oshi-Suta BATTLE**は、Jリーグサポーターが日常の歩数をクラブの応援ポイントに変換し、クラブ間で競い合うフィットネスアプリです。

### 主な機能

- 歩数データの同期とポイント変換（1,000歩 = 1ポイント）
- ユーザー認証（Firebase Auth）
- クラブ統計とランキング
- 歩数履歴と統計情報
- リアルタイムポイント集計

## 技術スタック

- **バックエンド**: Python 3.11 + FastAPI
- **データベース**: Firebase Firestore
- **キャッシュ**: Redis
- **認証**: Firebase Auth
- **デプロイ**: Docker + Docker Compose

## プロジェクト構造

```
oshi-suta-battle/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # FastAPIアプリケーション
│   │   ├── config.py               # 設定管理
│   │   ├── dependencies.py         # 依存性注入
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── router.py       # APIルーター
│   │   │       └── endpoints/      # エンドポイント
│   │   ├── models/                 # データモデル
│   │   ├── services/               # ビジネスロジック
│   │   ├── repositories/           # データアクセス層
│   │   └── utils/                  # ユーティリティ
│   ├── tests/                      # テストコード
│   ├── requirements.txt            # Python依存関係
│   ├── Dockerfile                  # Dockerイメージ定義
│   └── .env.example                # 環境変数テンプレート
├── docker-compose.yml              # Docker Compose設定
└── README.md
```

## セットアップ手順

### 前提条件

- Docker Desktop（または Docker + Docker Compose）
- Python 3.11以上（ローカル開発の場合）
- Firebase プロジェクト（本番環境の場合）

### 1. リポジトリのクローン

```bash
cd oshi-suta-battle
```

### 2. Firebase認証情報の設定

Firebase Consoleから認証情報をダウンロードします：

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. プロジェクトを選択
3. 設定（歯車アイコン）→ プロジェクトの設定
4. サービスアカウント タブ
5. 「新しい秘密鍵の生成」をクリック
6. ダウンロードしたJSONファイルを `backend/` ディレクトリに配置
7. ファイル名を `.env` の `FIREBASE_CREDENTIALS_PATH` に合わせる

### 3. 環境変数の設定

```bash
cd backend
cp .env.example .env
```

`.env` ファイルを編集して必要な環境変数を設定します：

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
SECRET_KEY=your-secret-key
REDIS_HOST=redis
```

### 4. Docker Composeで起動

```bash
cd ..
docker-compose up --build
```

サービスが起動したら、以下のURLにアクセスできます：

- API: http://localhost:8000
- API ドキュメント: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- Redis: localhost:6379

### 5. ヘルスチェック

```bash
curl http://localhost:8000/api/v1/health
```

期待されるレスポンス：

```json
{
  "status": "healthy",
  "timestamp": "2025-10-10T12:00:00",
  "version": "0.1.0",
  "services": {
    "firestore": "healthy",
    "redis": "healthy"
  }
}
```

## API エンドポイント

### 認証 (`/api/v1/auth`)

- `POST /auth/register` - ユーザー登録
- `POST /auth/login` - ログイン
- `GET /auth/profile` - プロフィール取得
- `PATCH /auth/profile` - プロフィール更新

### 歩数管理 (`/api/v1/steps`)

- `POST /steps/sync` - 歩数データ同期
- `GET /steps/history` - 歩数履歴取得
- `GET /steps/stats` - 統計情報取得

### クラブ情報 (`/api/v1/clubs`)

- `GET /clubs` - 全クラブ一覧
- `GET /clubs/{club_id}` - 特定クラブ情報
- `GET /clubs/{club_id}/stats` - クラブ統計

### ヘルスチェック (`/api/v1/health`)

- `GET /health` - ヘルスチェック
- `GET /health/ready` - Readiness Probe
- `GET /health/live` - Liveness Probe

## 開発

### ローカル環境での実行

```bash
cd backend

# 仮想環境の作成
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 依存関係のインストール
pip install -r requirements.txt

# サーバーの起動
docker-compose up --build
```

### テストの実行

```bash
cd backend
pytest
```

### コードフォーマット

```bash
# Black（コードフォーマッター）
black app/

# isort（import文の整理）
isort app/

# flake8（リンター）
flake8 app/
```

## 環境変数

| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `FIREBASE_PROJECT_ID` | Firebase プロジェクトID | `oshi-suta-battle` |
| `FIREBASE_CREDENTIALS_PATH` | Firebase認証情報ファイルパス | `./firebase-credentials.json` |
| `REDIS_HOST` | Redisホスト | `redis` |
| `REDIS_PORT` | Redisポート | `6379` |
| `SECRET_KEY` | JWTシークレットキー | （必須：本番環境で変更）|
| `API_V1_PREFIX` | APIバージョンプレフィックス | `/api/v1` |
| `CORS_ORIGINS` | CORS許可オリジン | `http://localhost:3000,...` |
| `DEBUG` | デバッグモード | `True` |
| `STEPS_PER_POINT` | ポイント計算基準（歩数） | `1000` |
| `MAX_DAILY_STEPS` | 1日の最大歩数 | `100000` |

## 対応クラブ（Phase 1）

- 浦和レッズ（urawa_reds）
- 鹿島アントラーズ（kashima_antlers）
- 横浜F・マリノス（yokohama_fmarinos）
- FC東京（fc_tokyo）
- 川崎フロンターレ（kawasaki_frontale）
- ガンバ大阪（gamba_osaka）
- セレッソ大阪（cerezo_osaka）
- 名古屋グランパス（nagoya_grampus）
- ヴィッセル神戸（vissel_kobe）
- サンフレッチェ広島（sanfrecce_hiroshima）
- 北海道コンサドーレ札幌（consadole_sapporo）
- 清水エスパルス（shimizu_spulse）

## トラブルシューティング

### Firestoreに接続できない

1. Firebase プロジェクトが正しく設定されているか確認
2. Firebase認証情報ファイルが正しく配置されているか確認

   ```bash
   ls backend/firebase-credentials.json  # または.envで指定したパス
   ```

3. 環境変数 `FIREBASE_PROJECT_ID` が正しいか確認
4. Firebase Console でFirestore Database が有効化されているか確認
5. サービスアカウントに必要な権限が付与されているか確認

### Redisに接続できない

```bash
# Redisコンテナが起動しているか確認
docker ps | grep redis

# Redisコンテナのログを確認
docker-compose logs redis
```

### ポート競合エラー

既に8000番ポートや6379番ポートが使用されている場合：

```bash
# ポートを使用しているプロセスを確認
lsof -i :8000
lsof -i :6379

# docker-compose.ymlでポートを変更
```

## Phase 2 の予定機能

- [ ] ウィークリーバトル実装
- [ ] プッシュ通知
- [ ] リーダーボード
- [ ] バッジ・実績システム
- [ ] ソーシャル機能（友達追加、メッセージ）
- [ ] Apple HealthKit / Google Fit 連携強化

## ライセンス

MIT License

## お問い合わせ

問題が発生した場合は、GitHubのIssuesで報告してください。
