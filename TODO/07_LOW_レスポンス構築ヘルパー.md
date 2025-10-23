# 優先度 LOW: レスポンス構築ヘルパーの作成

## 🎯 目的
バックエンドのエンドポイントで繰り返されるレスポンス構築ロジックをヘルパー関数に抽出し、コードの重複を削減する。

## 📊 現在の問題

`auth.py` で同じ `UserProfileResponse` 構築パターンが3回繰り返されている:

```python
# backend/app/api/v1/endpoints/auth.py:234-242, 301-309, 396-404

return UserProfileResponse(
    user_id=current_user["user_id"],
    email=updated_user["email"],
    nickname=updated_user["nickname"],
    club_id=updated_user["club_id"],
    total_points=updated_user.get("total_points", 0),
    created_at=updated_user.get("created_at"),
    updated_at=updated_user.get("updated_at")
)
```

## 📋 実装手順

### ステップ1: レスポンスビルダーモジュールを作成

`backend/app/utils/response_builders.py` を新規作成:

```python
"""
レスポンス構築ヘルパー関数
"""

from typing import Dict, Any, Optional
from datetime import datetime
from app.models.schemas import (
    UserProfileResponse,
    AuthResponse,
    ClubInfo,
    StepSyncResponse,
)


def build_user_profile_response(
    user_data: Dict[str, Any],
    user_id: Optional[str] = None
) -> UserProfileResponse:
    """
    ユーザープロフィールレスポンスを構築

    Args:
        user_data: Firestoreから取得したユーザーデータ
        user_id: ユーザーID (user_dataに含まれていない場合に指定)

    Returns:
        UserProfileResponse: ユーザープロフィールレスポンス
    """
    return UserProfileResponse(
        user_id=user_id or user_data.get("user_id", ""),
        email=user_data.get("email", ""),
        nickname=user_data.get("nickname"),
        club_id=user_data.get("club_id"),
        total_points=user_data.get("total_points", 0),
        total_steps=user_data.get("total_steps", 0),
        created_at=user_data.get("created_at"),
        updated_at=user_data.get("updated_at")
    )


def build_auth_response(
    access_token: str,
    user_data: Dict[str, Any],
    user_id: Optional[str] = None,
    token_type: str = "bearer"
) -> AuthResponse:
    """
    認証レスポンスを構築

    Args:
        access_token: JWTアクセストークン
        user_data: Firestoreから取得したユーザーデータ
        user_id: ユーザーID
        token_type: トークンタイプ (デフォルト: "bearer")

    Returns:
        AuthResponse: 認証レスポンス
    """
    return AuthResponse(
        access_token=access_token,
        token_type=token_type,
        user=build_user_profile_response(user_data, user_id)
    )


def build_club_info(club_data: Dict[str, Any]) -> ClubInfo:
    """
    クラブ情報レスポンスを構築

    Args:
        club_data: Firestoreから取得したクラブデータ

    Returns:
        ClubInfo: クラブ情報
    """
    return ClubInfo(
        club_id=club_data.get("club_id", ""),
        name=club_data.get("name", ""),
        total_points=club_data.get("total_points", 0),
        active_members=club_data.get("active_members", 0),
        league_rank=club_data.get("league_rank", 0),
        founded_year=club_data.get("founded_year", 1900),
        stadium=club_data.get("stadium", ""),
        logo_url=club_data.get("logo_url")
    )


def build_step_sync_response(
    points_earned: int,
    total_points: int,
    club_contribution: int,
    synced_at: Optional[datetime] = None
) -> StepSyncResponse:
    """
    歩数同期レスポンスを構築

    Args:
        points_earned: 獲得ポイント
        total_points: 総ポイント
        club_contribution: クラブへの貢献ポイント
        synced_at: 同期日時 (デフォルト: 現在時刻)

    Returns:
        StepSyncResponse: 歩数同期レスポンス
    """
    if synced_at is None:
        synced_at = datetime.now()

    return StepSyncResponse(
        points_earned=points_earned,
        total_points=total_points,
        club_contribution=club_contribution,
        synced_at=synced_at.isoformat()
    )


def build_error_response(
    detail: str,
    error_code: Optional[str] = None,
    field: Optional[str] = None
) -> Dict[str, Any]:
    """
    エラーレスポンスを構築

    Args:
        detail: エラー詳細メッセージ
        error_code: エラーコード
        field: エラーが発生したフィールド名

    Returns:
        Dict[str, Any]: エラーレスポンス
    """
    response = {"detail": detail}

    if error_code:
        response["error_code"] = error_code

    if field:
        response["field"] = field

    return response
```

### ステップ2: エンドポイントをリファクタリング

#### 2.1 `auth.py` を修正

**修正前**:
```python
@router.post("/register", response_model=AuthResponse)
@handle_exceptions("User registration")
async def register(
    request: UserRegisterRequest,
    repo: FirestoreRepository = Depends(get_firestore_repo)
) -> AuthResponse:
    # ... バリデーションとビジネスロジック

    # レスポンス構築 (8行)
    return AuthResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserProfileResponse(
            user_id=user_id,
            email=user_data["email"],
            nickname=user_data["nickname"],
            club_id=user_data["club_id"],
            total_points=user_data.get("total_points", 0),
            created_at=user_data.get("created_at"),
            updated_at=user_data.get("updated_at")
        )
    )
```

**修正後**:
```python
from app.utils.response_builders import build_auth_response

@router.post("/register", response_model=AuthResponse)
@handle_exceptions("User registration")
async def register(
    request: UserRegisterRequest,
    repo: FirestoreRepository = Depends(get_firestore_repo)
) -> AuthResponse:
    # ... バリデーションとビジネスロジック

    # レスポンス構築 (1行!)
    return build_auth_response(access_token, user_data, user_id)
```

#### 2.2 `update_profile` エンドポイントを修正

**修正前**:
```python
@router.patch("/profile", response_model=UserProfileResponse)
async def update_profile(...) -> UserProfileResponse:
    # ... ビジネスロジック

    return UserProfileResponse(
        user_id=current_user["user_id"],
        email=updated_user["email"],
        nickname=updated_user["nickname"],
        club_id=updated_user["club_id"],
        total_points=updated_user.get("total_points", 0),
        created_at=updated_user.get("created_at"),
        updated_at=updated_user.get("updated_at")
    )
```

**修正後**:
```python
from app.utils.response_builders import build_user_profile_response

@router.patch("/profile", response_model=UserProfileResponse)
async def update_profile(...) -> UserProfileResponse:
    # ... ビジネスロジック

    return build_user_profile_response(updated_user, current_user["user_id"])
```

#### 2.3 `clubs.py` を修正

**修正前**:
```python
@router.get("/", response_model=ClubListResponse)
async def get_all_clubs(...) -> ClubListResponse:
    clubs_data = repo.get_all_clubs()

    # 各クラブの変換 (12行)
    clubs = [
        ClubInfo(
            club_id=club.get("club_id", ""),
            name=club.get("name", ""),
            total_points=club.get("total_points", 0),
            active_members=club.get("active_members", 0),
            league_rank=club.get("league_rank", 0),
            founded_year=club.get("founded_year", 1900),
            stadium=club.get("stadium", ""),
            logo_url=club.get("logo_url")
        )
        for club in clubs_data
    ]

    return ClubListResponse(clubs=clubs)
```

**修正後**:
```python
from app.utils.response_builders import build_club_info

@router.get("/", response_model=ClubListResponse)
async def get_all_clubs(...) -> ClubListResponse:
    clubs_data = repo.get_all_clubs()

    # 各クラブの変換 (1行!)
    clubs = [build_club_info(club) for club in clubs_data]

    return ClubListResponse(clubs=clubs)
```

#### 2.4 `steps.py` を修正

**修正前**:
```python
@router.post("/sync", response_model=StepSyncResponse)
async def sync_steps(...) -> StepSyncResponse:
    # ... ビジネスロジック

    return StepSyncResponse(
        points_earned=points,
        total_points=user_data.get("total_points", 0),
        club_contribution=points,
        synced_at=datetime.now().isoformat()
    )
```

**修正後**:
```python
from app.utils.response_builders import build_step_sync_response

@router.post("/sync", response_model=StepSyncResponse)
async def sync_steps(...) -> StepSyncResponse:
    # ... ビジネスロジック

    return build_step_sync_response(
        points_earned=points,
        total_points=user_data.get("total_points", 0),
        club_contribution=points
    )
```

### ステップ3: テストの作成

`backend/tests/test_response_builders.py` を作成:

```python
"""
レスポンスビルダーのテスト
"""

import pytest
from datetime import datetime
from app.utils.response_builders import (
    build_user_profile_response,
    build_auth_response,
    build_club_info,
    build_step_sync_response,
    build_error_response,
)


class TestUserProfileResponseBuilder:
    """ユーザープロフィールレスポンス構築のテスト"""

    def test_build_user_profile_response_with_all_fields(self):
        user_data = {
            "user_id": "user123",
            "email": "test@example.com",
            "nickname": "テストユーザー",
            "club_id": "urawa-reds",
            "total_points": 1000,
            "total_steps": 50000,
            "created_at": "2024-01-01T00:00:00",
            "updated_at": "2024-01-02T00:00:00"
        }

        response = build_user_profile_response(user_data)

        assert response.user_id == "user123"
        assert response.email == "test@example.com"
        assert response.nickname == "テストユーザー"
        assert response.club_id == "urawa-reds"
        assert response.total_points == 1000
        assert response.total_steps == 50000

    def test_build_user_profile_response_with_defaults(self):
        user_data = {
            "email": "test@example.com",
        }

        response = build_user_profile_response(user_data, user_id="user456")

        assert response.user_id == "user456"
        assert response.email == "test@example.com"
        assert response.total_points == 0
        assert response.total_steps == 0
        assert response.nickname is None


class TestAuthResponseBuilder:
    """認証レスポンス構築のテスト"""

    def test_build_auth_response(self):
        user_data = {
            "email": "test@example.com",
            "nickname": "テストユーザー",
            "club_id": "urawa-reds",
        }

        response = build_auth_response(
            access_token="test_token_123",
            user_data=user_data,
            user_id="user123"
        )

        assert response.access_token == "test_token_123"
        assert response.token_type == "bearer"
        assert response.user.user_id == "user123"
        assert response.user.email == "test@example.com"


class TestClubInfoBuilder:
    """クラブ情報構築のテスト"""

    def test_build_club_info_with_all_fields(self):
        club_data = {
            "club_id": "urawa-reds",
            "name": "浦和レッズ",
            "total_points": 50000,
            "active_members": 1000,
            "league_rank": 3,
            "founded_year": 1950,
            "stadium": "埼玉スタジアム2002",
            "logo_url": "https://example.com/logo.png"
        }

        response = build_club_info(club_data)

        assert response.club_id == "urawa-reds"
        assert response.name == "浦和レッズ"
        assert response.total_points == 50000
        assert response.active_members == 1000
        assert response.league_rank == 3


class TestStepSyncResponseBuilder:
    """歩数同期レスポンス構築のテスト"""

    def test_build_step_sync_response(self):
        response = build_step_sync_response(
            points_earned=10,
            total_points=100,
            club_contribution=10
        )

        assert response.points_earned == 10
        assert response.total_points == 100
        assert response.club_contribution == 10
        assert response.synced_at is not None

    def test_build_step_sync_response_with_custom_time(self):
        custom_time = datetime(2024, 1, 1, 12, 0, 0)

        response = build_step_sync_response(
            points_earned=10,
            total_points=100,
            club_contribution=10,
            synced_at=custom_time
        )

        assert "2024-01-01T12:00:00" in response.synced_at


class TestErrorResponseBuilder:
    """エラーレスポンス構築のテスト"""

    def test_build_error_response_simple(self):
        response = build_error_response("エラーが発生しました")

        assert response["detail"] == "エラーが発生しました"
        assert "error_code" not in response
        assert "field" not in response

    def test_build_error_response_with_code(self):
        response = build_error_response(
            detail="バリデーションエラー",
            error_code="VALIDATION_ERROR"
        )

        assert response["detail"] == "バリデーションエラー"
        assert response["error_code"] == "VALIDATION_ERROR"

    def test_build_error_response_with_field(self):
        response = build_error_response(
            detail="無効なメールアドレス",
            error_code="VALIDATION_ERROR",
            field="email"
        )

        assert response["detail"] == "無効なメールアドレス"
        assert response["error_code"] == "VALIDATION_ERROR"
        assert response["field"] == "email"
```

### ステップ4: テスト実行

```bash
cd backend
pytest tests/test_response_builders.py -v
```

## ✅ チェックリスト

- [ ] `backend/app/utils/response_builders.py` を作成
- [ ] `auth.py` でヘルパー関数を使用
- [ ] `clubs.py` でヘルパー関数を使用
- [ ] `steps.py` でヘルパー関数を使用
- [ ] `test_response_builders.py` を作成
- [ ] テストを実行して全てパス
- [ ] 既存の重複コードを削除
- [ ] ドキュメントを更新

## ⏱️ 推定作業時間

- ヘルパー関数作成: 1.5時間
- エンドポイント修正: 1時間
- テスト作成: 1時間
- テスト実行・デバッグ: 30分

**合計**: 約4時間

## 📈 期待される効果

- ✅ **コード行数が約40行削減**
- ✅ **レスポンス構築の一貫性向上**
- ✅ **フィールド追加時の修正が1箇所で完結**
- ✅ **テストカバレッジの向上**
- ✅ **可読性の向上**

## 🔄 Before/After比較

### Before
```python
# 8行のレスポンス構築
return AuthResponse(
    access_token=access_token,
    token_type="bearer",
    user=UserProfileResponse(
        user_id=user_id,
        email=user_data["email"],
        nickname=user_data["nickname"],
        club_id=user_data["club_id"],
        total_points=user_data.get("total_points", 0),
        created_at=user_data.get("created_at"),
        updated_at=user_data.get("updated_at")
    )
)
```

### After
```python
# 1行のレスポンス構築 (87%削減!)
return build_auth_response(access_token, user_data, user_id)
```

## 📚 参考資料

- [FastAPI Response Models](https://fastapi.tiangolo.com/tutorial/response-model/)
- [Python Builder Pattern](https://refactoring.guru/design-patterns/builder/python/example)
