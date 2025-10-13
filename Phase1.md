# Oshi-Suta BATTLE - Phase 1 実装

あなたは「Oshi-Suta BATTLE」というJリーグサポーター向けフィットネス×ゲーミフィケーションアプリを開発します。

## プロジェクト概要
- サポーターの日常の歩数をクラブの応援ポイントに変換
- クラブ間でウィークリーバトルを実施
- リアルタイムでクラブゲージを表示

## Phase 1 の目標
バックエンドAPIの基盤を構築してください。

### 技術スタック
- **バックエンド**: Python 3.11 + FastAPI
- **データベース**: Firebase Firestore
- **キャッシュ**: Redis
- **認証**: Firebase Auth
- **デプロイ**: Docker対応

### 実装タスク

#### 1. プロジェクト構造作成
以下のディレクトリ構造を作成してください：

```
oshi-suta-battle/
├── backend/
│   ├── app/
│   │   ├── init.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── dependencies.py
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── init.py
│   │   │       ├── router.py
│   │   │       └── endpoints/
│   │   │           ├── init.py
│   │   │           ├── auth.py
│   │   │           ├── steps.py
│   │   │           ├── clubs.py
│   │   │           └── health.py
│   │   ├── models/
│   │   │   ├── init.py
│   │   │   ├── user.py
│   │   │   ├── club.py
│   │   │   └── schemas.py
│   │   ├── services/
│   │   │   ├── init.py
│   │   │   ├── step_service.py
│   │   │   └── point_calculator.py
│   │   ├── repositories/
│   │   │   ├── init.py
│   │   │   └── firestore_repo.py
│   │   └── utils/
│   │       ├── init.py
│   │       ├── validators.py
│   │       └── security.py
│   ├── tests/
│   │   ├── init.py
│   │   ├── test_auth.py
│   │   └── test_steps.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── docker-compose.yml
└── README.md

```

#### 2. requirements.txt
以下の依存関係を含めてください：

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pydantic-settings==2.1.0
firebase-admin==6.3.0
redis==5.0.1
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.2
```

#### 3. config.py
環境変数を管理する設定ファイルを作成してください。以下の変数を含む：
- FIREBASE_PROJECT_ID
- FIREBASE_CREDENTIALS_PATH
- REDIS_HOST
- REDIS_PORT
- SECRET_KEY
- API_V1_PREFIX = "/api/v1"
- CORS_ORIGINS

#### 4. main.py
FastAPIアプリケーションのエントリーポイントを作成：
- CORS設定
- ルーター登録
- 起動時のFirebase初期化
- ヘルスチェックエンドポイント

#### 5. dependencies.py
依存性注入用の関数を実装：
- `get_current_user()`: Firebase IDトークン検証
- `get_firestore_client()`: Firestoreクライアント取得
- `get_redis_client()`: Redisクライアント取得

#### 6. models/schemas.py
Pydanticモデルを定義：

```python
# ユーザー登録リクエスト
class UserRegisterRequest(BaseModel):
    email: str
    password: str
    club_id: str
    nickname: str

# 歩数同期リクエスト
class StepSyncRequest(BaseModel):
    steps: int = Field(ge=0, le=100000)
    date: str  # YYYY-MM-DD形式
    source: Literal["healthkit", "googlefit"]
    device_signature: str

# 歩数同期レスポンス
class StepSyncResponse(BaseModel):
    points_earned: int
    total_points: int
    club_contribution: str
    is_verified: bool

# クラブ情報
class ClubInfo(BaseModel):
    club_id: str
    name: str
    total_points: int
    active_members: int
    league_rank: int
```
7. endpoints/auth.py

認証エンドポイントを実装：

POST /auth/register: ユーザー登録
POST /auth/login: ログイン（Firebase Auth使用）
GET /auth/profile: プロフィール取得
PATCH /auth/profile: プロフィール更新

8. endpoints/steps.py
歩数管理エンドポイントを実装：

POST /steps/sync: 歩数データ同期

リクエストバリデーション
ポイント計算（1,000歩 = 1ポイント）
Firestore保存
クラブポイント集計


GET /steps/history: 歩数履歴取得
GET /steps/stats: 統計情報取得

9. endpoints/clubs.py
クラブ情報エンドポイントを実装：

GET /clubs: 全クラブ一覧
GET /clubs/{club_id}: 特定クラブ情報
GET /clubs/{club_id}/stats: クラブ統計

10. services/step_service.py
歩数処理ロジックを実装：
```python
class StepService:
    async def sync_steps(self, user_id: str, steps: int, date: str) -> dict:
        """歩数データを同期してポイント計算"""
        # 1. 重複チェック
        # 2. ポイント計算
        # 3. Firestore保存
        # 4. クラブ集計トリガー
        pass
    
    async def calculate_points(self, steps: int) -> int:
        """歩数からポイント計算"""
        return steps // 1000
    
    async def get_user_history(self, user_id: str, days: int = 30) -> list:
        """ユーザーの歩数履歴取得"""
        pass

```
11. repositories/firestore_repo.py
Firestore操作を抽象化：

```python
class FirestoreRepository:
    def __init__(self, db):
        self.db = db
    
    async def create_user(self, user_id: str, data: dict):
        """ユーザー作成"""
        pass
    
    async def get_user(self, user_id: str) -> dict:
        """ユーザー取得"""
        pass
    
    async def update_user(self, user_id: str, data: dict):
        """ユーザー更新"""
        pass
    
    async def save_step_log(self, user_id: str, date: str, steps: int):
        """歩数ログ保存"""
        pass
    
    async def get_club(self, club_id: str) -> dict:
        """クラブ情報取得"""
        pass
```

12. utils/validators.py
バリデーション関数を実装：

```python
def validate_steps(steps: int) -> bool:
    """歩数の妥当性チェック"""
    return 0 <= steps <= 100000

def validate_date_format(date_str: str) -> bool:
    """日付フォーマットチェック（YYYY-MM-DD）"""
    pass

def validate_club_id(club_id: str) -> bool:
    """クラブIDの存在チェック"""
    pass

```

13. Dockerfile
本番環境用のDockerfileを作成：

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

14. docker-compose.yml
開発環境用のDocker Compose設定：

```yaml
version: '3.8'

services:
  api:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - REDIS_HOST=redis
      - ENV=development
    volumes:
      - ./backend:/app
    depends_on:
      - redis
    command: uvicorn app.main:app --host 0.0.0.0 --reload
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

15. テストファイル作成
tests/test_steps.pyにユニットテストを作成：

```python
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_sync_steps():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/steps/sync",
            json={
                "steps": 8543,
                "date": "2025-10-10",
                "source": "healthkit",
                "device_signature": "test_signature"
            },
            headers={"Authorization": "Bearer test_token"}
        )
        assert response.status_code == 200
        data = response.json()
        assert "points_earned" in data


```
16. README.md
プロジェクトのドキュメントを作成：

プロジェクト概要
セットアップ手順
環境変数の説明
API仕様へのリンク
開発・テスト方法

実装時の注意事項

型ヒント: すべての関数に型ヒントを付けてください
エラーハンドリング: try-exceptで適切な例外処理を実装
ログ: logging モジュールで適切なログ出力
ドキュメント: 各関数にdocstringを記載
セキュリティ: パスワードのハッシュ化、SQLインジェクション対策
テスト: 主要な関数にユニットテストを作成

完了基準

- すべてのファイルが作成されている
- docker-compose upでサーバーが起動する
- curl http://localhost:8000/healthでヘルスチェックが成功
- pytestですべてのテストが通過
- OpenAPI ドキュメントがhttp://localhost:8000/docsで閲覧可能

実装を開始してください。質問があれば途中で確認してください。また、段階ごとにテストを挟み、実装を進めるようにして。