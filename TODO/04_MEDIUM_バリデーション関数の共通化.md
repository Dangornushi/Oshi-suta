# 優先度 MEDIUM: バリデーション関数の共通化

## 🎯 目的
バックエンドで繰り返されているバリデーションロジックを共通化し、コードの重複を削減する。

## 📊 現在の問題

### 問題1: バリデーション呼び出しの重複

`auth.py` で同じバリデーションパターンが繰り返されている:

```python
# backend/app/api/v1/endpoints/auth.py:61-73
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

# 同じパターンが auth.py:276-283 でも繰り返される
```

### 問題2: パスワード検証の重複

`schemas.py` で2つのクラスが同じパスワード検証を実装:

```python
# UserRegisterRequest (行23-31) と PasswordChangeRequest (行79-87) で重複
@field_validator("password")
@classmethod
def validate_password(cls, v: str) -> str:
    if not any(c.isupper() for c in v):
        raise ValueError("Password must contain at least one uppercase letter")
    if not any(c.islower() for c in v):
        raise ValueError("Password must contain at least one lowercase letter")
    if not any(c.isdigit() for c in v):
        raise ValueError("Password must contain at least one digit")
    return v
```

## 📋 実装手順

### ステップ1: バリデーションユーティリティを強化

`backend/app/utils/validators.py` を拡張:

**現在の内容**:
```python
import re
from typing import Tuple

# クラブID定義
VALID_CLUB_IDS = [
    "urawa_reds",
    # ...
]

def validate_club_id(club_id: str) -> bool:
    return club_id in VALID_CLUB_IDS

def validate_nickname(nickname: str) -> Tuple[bool, str]:
    if len(nickname) < 2:
        return False, "Nickname must be at least 2 characters"
    if len(nickname) > 20:
        return False, "Nickname must be at most 20 characters"
    # ... 他のチェック
    return True, ""
```

**拡張後**:
```python
"""
バリデーションユーティリティ
"""

import re
from typing import Tuple, Optional
from app.config.constants import VALID_CLUB_IDS

# ===== クラブID検証 =====

def validate_club_id(club_id: str) -> bool:
    """クラブIDが有効かチェック"""
    return club_id in VALID_CLUB_IDS


# ===== ニックネーム検証 =====

MIN_NICKNAME_LENGTH = 2
MAX_NICKNAME_LENGTH = 20

def validate_nickname(nickname: str) -> Tuple[bool, str]:
    """
    ニックネームのバリデーション

    Returns:
        Tuple[bool, str]: (有効かどうか, エラーメッセージ)
    """
    if len(nickname) < MIN_NICKNAME_LENGTH:
        return False, f"Nickname must be at least {MIN_NICKNAME_LENGTH} characters"

    if len(nickname) > MAX_NICKNAME_LENGTH:
        return False, f"Nickname must be at most {MAX_NICKNAME_LENGTH} characters"

    # 使用禁止文字のチェック
    if not re.match(r'^[a-zA-Z0-9_\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+$', nickname):
        return False, "Nickname contains invalid characters"

    return True, ""


# ===== パスワード検証 =====

MIN_PASSWORD_LENGTH = 8
MAX_PASSWORD_LENGTH = 128

def validate_password_strength(password: str) -> Tuple[bool, str]:
    """
    パスワード強度のバリデーション

    要件:
    - 8文字以上
    - 大文字を1文字以上含む
    - 小文字を1文字以上含む
    - 数字を1文字以上含む

    Returns:
        Tuple[bool, str]: (有効かどうか, エラーメッセージ)
    """
    if len(password) < MIN_PASSWORD_LENGTH:
        return False, f"Password must be at least {MIN_PASSWORD_LENGTH} characters"

    if len(password) > MAX_PASSWORD_LENGTH:
        return False, f"Password must be at most {MAX_PASSWORD_LENGTH} characters"

    if not any(c.isupper() for c in password):
        return False, "Password must contain at least one uppercase letter"

    if not any(c.islower() for c in password):
        return False, "Password must contain at least one lowercase letter"

    if not any(c.isdigit() for c in password):
        return False, "Password must contain at least one digit"

    return True, ""


def validate_password(password: str) -> str:
    """
    パスワードのバリデーション（Pydanticバリデーター用）

    Raises:
        ValueError: パスワードが要件を満たさない場合

    Returns:
        str: 検証済みのパスワード
    """
    is_valid, error_msg = validate_password_strength(password)
    if not is_valid:
        raise ValueError(error_msg)
    return password


# ===== メールアドレス検証 =====

EMAIL_REGEX = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

def validate_email(email: str) -> Tuple[bool, str]:
    """
    メールアドレスのバリデーション

    Returns:
        Tuple[bool, str]: (有効かどうか, エラーメッセージ)
    """
    if not EMAIL_REGEX.match(email):
        return False, "Invalid email format"

    if len(email) > 254:  # RFC 5321
        return False, "Email address is too long"

    return True, ""


# ===== 日付検証 =====

from datetime import datetime

DATE_FORMAT = "%Y-%m-%d"

def validate_date_format(date_str: str) -> Tuple[bool, str]:
    """
    日付形式のバリデーション (YYYY-MM-DD)

    Returns:
        Tuple[bool, str]: (有効かどうか, エラーメッセージ)
    """
    try:
        datetime.strptime(date_str, DATE_FORMAT)
        return True, ""
    except ValueError:
        return False, f"Invalid date format. Expected: {DATE_FORMAT}"


def validate_date_range(start_date: str, end_date: str) -> Tuple[bool, str]:
    """
    日付範囲のバリデーション

    Returns:
        Tuple[bool, str]: (有効かどうか, エラーメッセージ)
    """
    try:
        start = datetime.strptime(start_date, DATE_FORMAT)
        end = datetime.strptime(end_date, DATE_FORMAT)

        if start > end:
            return False, "Start date must be before end date"

        return True, ""
    except ValueError as e:
        return False, str(e)


# ===== 歩数データ検証 =====

MIN_STEPS = 0
MAX_STEPS = 100000  # 1日の最大歩数（異常値検出用）

def validate_steps(steps: int) -> Tuple[bool, str]:
    """
    歩数データのバリデーション

    Returns:
        Tuple[bool, str]: (有効かどうか, エラーメッセージ)
    """
    if steps < MIN_STEPS:
        return False, f"Steps cannot be negative"

    if steps > MAX_STEPS:
        return False, f"Steps value seems abnormal (max: {MAX_STEPS})"

    return True, ""


# ===== ヘルパー関数 =====

def validate_and_raise_http(
    condition: bool,
    error_message: str,
    status_code: int = 400
):
    """
    バリデーション失敗時にHTTPExceptionを送出

    使用例:
        validate_and_raise_http(
            validate_club_id(club_id),
            f"Invalid club ID: {club_id}"
        )
    """
    from fastapi import HTTPException

    if not condition:
        raise HTTPException(
            status_code=status_code,
            detail=error_message
        )


def validate_tuple_and_raise_http(
    validation_result: Tuple[bool, str],
    status_code: int = 400
):
    """
    Tuple形式のバリデーション結果を処理

    使用例:
        validate_tuple_and_raise_http(
            validate_nickname(nickname)
        )
    """
    from fastapi import HTTPException

    is_valid, error_msg = validation_result
    if not is_valid:
        raise HTTPException(
            status_code=status_code,
            detail=error_msg
        )
```

### ステップ2: Pydanticスキーマを更新

`backend/app/models/schemas.py` を修正:

**修正前**:
```python
from pydantic import BaseModel, Field, field_validator

class UserRegisterRequest(BaseModel):
    email: str
    password: str = Field(..., min_length=8)
    nickname: str
    club_id: str

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not any(c.islower() for c in v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one digit")
        return v

class PasswordChangeRequest(BaseModel):
    current_password: str
    new_password: str = Field(..., min_length=8)

    @field_validator("new_password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        # 同じコードが重複
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain at least one uppercase letter")
        # ...
        return v
```

**修正後**:
```python
from pydantic import BaseModel, Field, field_validator
from app.utils.validators import validate_password

class UserRegisterRequest(BaseModel):
    email: str
    password: str = Field(..., min_length=8)
    nickname: str
    club_id: str

    # 共通のvalidate_password関数を使用
    _validate_password = field_validator("password")(lambda cls, v: validate_password(v))


class PasswordChangeRequest(BaseModel):
    current_password: str
    new_password: str = Field(..., min_length=8)

    # 同じvalidate_password関数を再利用
    _validate_new_password = field_validator("new_password")(lambda cls, v: validate_password(v))
```

### ステップ3: エンドポイントをリファクタリング

`backend/app/api/v1/endpoints/auth.py` を修正:

**修正前**:
```python
@router.post("/register")
async def register(request: UserRegisterRequest, ...):
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
```

**修正後**:
```python
from app.utils.validators import (
    validate_club_id,
    validate_nickname,
    validate_and_raise_http,
    validate_tuple_and_raise_http
)

@router.post("/register")
async def register(request: UserRegisterRequest, ...):
    # バリデーション（1行で完結）
    validate_and_raise_http(
        validate_club_id(request.club_id),
        f"Invalid club ID: {request.club_id}"
    )

    validate_tuple_and_raise_http(
        validate_nickname(request.nickname)
    )

    # ビジネスロジック
    # ...
```

または、02_HIGHで作成した `validate_and_raise` を使用:

```python
from app.utils.error_handlers import validate_and_raise, ValidationError

@router.post("/register")
async def register(request: UserRegisterRequest, ...):
    # バリデーション
    validate_and_raise(
        validate_club_id(request.club_id),
        f"Invalid club ID: {request.club_id}"
    )

    is_valid, error_msg = validate_nickname(request.nickname)
    validate_and_raise(is_valid, error_msg)

    # ビジネスロジック
    # ...
```

### ステップ4: 歩数エンドポイントのバリデーション強化

`backend/app/api/v1/endpoints/steps.py` を修正:

```python
from app.utils.validators import (
    validate_steps,
    validate_date_format,
    validate_tuple_and_raise_http
)
from app.utils.error_handlers import handle_exceptions

@router.post("/sync", response_model=StepSyncResponse)
@handle_exceptions("Step sync")
async def sync_steps(
    request: StepSyncRequest,
    current_user: dict = Depends(get_current_user),
    repo: FirestoreRepository = Depends(get_firestore_repo)
) -> StepSyncResponse:
    # バリデーション
    validate_tuple_and_raise_http(validate_steps(request.steps))
    validate_tuple_and_raise_http(validate_date_format(request.date))

    # ビジネスロジック
    # ...
```

### ステップ5: バリデーションのユニットテストを作成

`backend/tests/test_validators.py` を新規作成:

```python
"""
バリデーション関数のテスト
"""

import pytest
from app.utils.validators import (
    validate_club_id,
    validate_nickname,
    validate_password_strength,
    validate_email,
    validate_date_format,
    validate_date_range,
    validate_steps,
)


class TestClubIdValidation:
    """クラブIDバリデーションのテスト"""

    def test_valid_club_id(self):
        assert validate_club_id("urawa-reds") is True

    def test_invalid_club_id(self):
        assert validate_club_id("invalid-club") is False


class TestNicknameValidation:
    """ニックネームバリデーションのテスト"""

    def test_valid_nickname(self):
        is_valid, _ = validate_nickname("テストユーザー")
        assert is_valid is True

    def test_too_short_nickname(self):
        is_valid, error_msg = validate_nickname("a")
        assert is_valid is False
        assert "at least 2 characters" in error_msg

    def test_too_long_nickname(self):
        is_valid, error_msg = validate_nickname("a" * 21)
        assert is_valid is False
        assert "at most 20 characters" in error_msg

    def test_invalid_characters(self):
        is_valid, error_msg = validate_nickname("user@#$")
        assert is_valid is False
        assert "invalid characters" in error_msg.lower()


class TestPasswordValidation:
    """パスワードバリデーションのテスト"""

    def test_valid_password(self):
        is_valid, _ = validate_password_strength("Test1234")
        assert is_valid is True

    def test_no_uppercase(self):
        is_valid, error_msg = validate_password_strength("test1234")
        assert is_valid is False
        assert "uppercase" in error_msg.lower()

    def test_no_lowercase(self):
        is_valid, error_msg = validate_password_strength("TEST1234")
        assert is_valid is False
        assert "lowercase" in error_msg.lower()

    def test_no_digit(self):
        is_valid, error_msg = validate_password_strength("TestTest")
        assert is_valid is False
        assert "digit" in error_msg.lower()

    def test_too_short(self):
        is_valid, error_msg = validate_password_strength("Test12")
        assert is_valid is False
        assert "at least 8 characters" in error_msg


class TestEmailValidation:
    """メールアドレスバリデーションのテスト"""

    def test_valid_email(self):
        is_valid, _ = validate_email("test@example.com")
        assert is_valid is True

    def test_invalid_format(self):
        is_valid, error_msg = validate_email("invalid-email")
        assert is_valid is False

    def test_too_long_email(self):
        long_email = "a" * 250 + "@example.com"
        is_valid, error_msg = validate_email(long_email)
        assert is_valid is False


class TestDateValidation:
    """日付バリデーションのテスト"""

    def test_valid_date(self):
        is_valid, _ = validate_date_format("2024-01-01")
        assert is_valid is True

    def test_invalid_format(self):
        is_valid, error_msg = validate_date_format("01-01-2024")
        assert is_valid is False

    def test_valid_date_range(self):
        is_valid, _ = validate_date_range("2024-01-01", "2024-12-31")
        assert is_valid is True

    def test_invalid_date_range(self):
        is_valid, error_msg = validate_date_range("2024-12-31", "2024-01-01")
        assert is_valid is False
        assert "before" in error_msg.lower()


class TestStepsValidation:
    """歩数バリデーションのテスト"""

    def test_valid_steps(self):
        is_valid, _ = validate_steps(10000)
        assert is_valid is True

    def test_negative_steps(self):
        is_valid, error_msg = validate_steps(-100)
        assert is_valid is False
        assert "negative" in error_msg.lower()

    def test_abnormal_steps(self):
        is_valid, error_msg = validate_steps(200000)
        assert is_valid is False
        assert "abnormal" in error_msg.lower()
```

### ステップ6: テスト実行

```bash
cd backend
pytest tests/test_validators.py -v
```

## ✅ チェックリスト

- [ ] `validators.py` を拡張（パスワード、メール、日付、歩数）
- [ ] ヘルパー関数を追加（`validate_and_raise_http`など）
- [ ] `schemas.py` でパスワードバリデーションを共通化
- [ ] `auth.py` のバリデーション呼び出しを簡潔化
- [ ] `steps.py` のバリデーションを強化
- [ ] `test_validators.py` を作成
- [ ] 全テストを実行してパス確認
- [ ] 既存の重複バリデーションコードを削除
- [ ] ドキュメントを更新

## ⏱️ 推定作業時間

- バリデーション関数の拡張: 2時間
- スキーマとエンドポイントの修正: 1.5時間
- テストの作成: 1.5時間
- テスト実行・デバッグ: 1時間

**合計**: 約6時間

## 📈 期待される効果

- ✅ **コード行数が約50行削減**
- ✅ **バリデーションロジックの一貫性向上**
- ✅ **バリデーションルールの変更が1箇所で完結**
- ✅ **テストカバレッジの向上**
- ✅ **新しいバリデーションルールの追加が容易**

## 🔄 Before/After比較

### Before
```python
# auth.py 内で繰り返される (10行)
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
```

### After
```python
# 2行で完結 (80%削減!)
validate_and_raise_http(validate_club_id(request.club_id), f"Invalid club ID: {request.club_id}")
validate_tuple_and_raise_http(validate_nickname(request.nickname))
```

## 📚 参考資料

- [Pydantic Field Validators](https://docs.pydantic.dev/latest/usage/validators/)
- [FastAPI Request Validation](https://fastapi.tiangolo.com/tutorial/body/)
- [Python Validation Best Practices](https://realpython.com/python-data-validation/)
