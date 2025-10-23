# 優先度 HIGH: 定数の統一化

## 🎯 目的
バックエンドとモバイルアプリ間でクラブID定義が不一致な問題を解決し、共通の定数管理を確立する。

## ⚠️ 現在の問題

### 問題1: クラブIDの命名規則の不一致

**バックエンド** (`backend/app/utils/validators.py:12-25`):
```python
VALID_CLUB_IDS = [
    "urawa_reds",  # アンダースコア
    "kashima_antlers",
    "yokohama_fmarinos",
    # ...
]
```

**モバイルアプリ** (`mobile_app/lib/config/club_theme.dart`):
```dart
static final Map<String, ClubThemeData> clubThemes = {
  'urawa-reds': ClubThemeData(...),  // ハイフン
  'kashima-antlers': ClubThemeData(...),
  'yokohama-fmarinos': ClubThemeData(...),
  // ...
};
```

→ **この不一致がバリデーションエラーやデータ同期問題を引き起こす可能性あり！**

### 問題2: ポイント計算定数の分散

- `backend/app/services/point_calculator.py`: `STEPS_PER_POINT = 1000`
- `mobile_app/lib/config/constants.dart`: `stepsToPointsRatio = 1000`

→ 現在は一致しているが、片方だけ変更されるリスクあり

## 📋 実装手順

### ステップ1: 命名規則を決定する

**推奨**: ハイフン形式 (`urawa-reds`) を採用
- 理由1: URLフレンドリー
- 理由2: JSON/APIでの標準的な形式
- 理由3: モバイル側の変更範囲が小さい

### ステップ2: バックエンドの定数を修正

#### 2.1 `backend/app/utils/validators.py` を修正

```python
# 修正前
VALID_CLUB_IDS = [
    "urawa_reds",
    "kashima_antlers",
    "yokohama_fmarinos",
    "fc_tokyo",
    "kawasaki_frontale",
    "gamba_osaka",
    "cerezo_osaka",
    "nagoya_grampus",
    "vissel_kobe",
    "sanfrecce_hiroshima",
    "consadole_sapporo",
    "shimizu_spulse"
]

# 修正後
VALID_CLUB_IDS = [
    "urawa-reds",
    "kashima-antlers",
    "yokohama-fmarinos",
    "fc-tokyo",
    "kawasaki-frontale",
    "gamba-osaka",
    "cerezo-osaka",
    "nagoya-grampus",
    "vissel-kobe",
    "sanfrecce-hiroshima",
    "consadole-sapporo",
    "shimizu-spulse"
]
```

#### 2.2 `backend/app/models/club.py` のCLUB_NAMESも同様に修正

```python
# 修正前
CLUB_NAMES = {
    "urawa_reds": "浦和レッズ",
    # ...
}

# 修正後
CLUB_NAMES = {
    "urawa-reds": "浦和レッズ",
    # ...
}
```

### ステップ3: 共通定数ファイルを作成

#### 3.1 バックエンド側

`backend/app/config/constants.py` を新規作成:

```python
"""
共通定数定義
このファイルはシステム全体で使用される定数を定義します。
"""

# クラブID定義
VALID_CLUB_IDS = [
    "urawa-reds",
    "kashima-antlers",
    "yokohama-fmarinos",
    "fc-tokyo",
    "kawasaki-frontale",
    "gamba-osaka",
    "cerezo-osaka",
    "nagoya-grampus",
    "vissel-kobe",
    "sanfrecce-hiroshima",
    "consadole-sapporo",
    "shimizu-spulse"
]

# クラブ名（日本語）
CLUB_NAMES = {
    "urawa-reds": "浦和レッズ",
    "kashima-antlers": "鹿島アントラーズ",
    "yokohama-fmarinos": "横浜F・マリノス",
    "fc-tokyo": "FC東京",
    "kawasaki-frontale": "川崎フロンターレ",
    "gamba-osaka": "ガンバ大阪",
    "cerezo-osaka": "セレッソ大阪",
    "nagoya-grampus": "名古屋グランパス",
    "vissel-kobe": "ヴィッセル神戸",
    "sanfrecce-hiroshima": "サンフレッチェ広島",
    "consadole-sapporo": "北海道コンサドーレ札幌",
    "shimizu-spulse": "清水エスパルス"
}

# ポイント計算定数
STEPS_PER_POINT = 1000  # 1000歩 = 1ポイント

# その他の定数
DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 100
```

#### 3.2 既存ファイルからの参照を変更

`backend/app/utils/validators.py`:
```python
from app.config.constants import VALID_CLUB_IDS

def validate_club_id(club_id: str) -> bool:
    return club_id in VALID_CLUB_IDS
```

`backend/app/services/point_calculator.py`:
```python
from app.config.constants import STEPS_PER_POINT

class PointCalculator:
    @staticmethod
    def calculate_points(steps: int) -> int:
        return steps // STEPS_PER_POINT
```

### ステップ4: データベースの既存データを移行

#### 4.1 マイグレーションスクリプトを作成

`backend/scripts/migrate_club_ids.py` を作成:

```python
"""
クラブID移行スクリプト
アンダースコア形式からハイフン形式に変換
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
from dotenv import load_dotenv

load_dotenv()

# Firebase初期化
cred = credentials.Certificate(os.getenv("FIREBASE_CREDENTIALS_PATH"))
firebase_admin.initialize_app(cred)
db = firestore.client()

# 移行マッピング
MIGRATION_MAP = {
    "urawa_reds": "urawa-reds",
    "kashima_antlers": "kashima-antlers",
    "yokohama_fmarinos": "yokohama-fmarinos",
    "fc_tokyo": "fc-tokyo",
    "kawasaki_frontale": "kawasaki-frontale",
    "gamba_osaka": "gamba-osaka",
    "cerezo_osaka": "cerezo-osaka",
    "nagoya_grampus": "nagoya-grampus",
    "vissel_kobe": "vissel-kobe",
    "sanfrecce_hiroshima": "sanfrecce-hiroshima",
    "consadole_sapporo": "consadole-sapporo",
    "shimizu_spulse": "shimizu-spulse"
}

def migrate_users():
    """usersコレクションのclub_idを更新"""
    users_ref = db.collection('users')
    users = users_ref.stream()

    updated_count = 0
    for user_doc in users:
        user_data = user_doc.to_dict()
        old_club_id = user_data.get('club_id')

        if old_club_id in MIGRATION_MAP:
            new_club_id = MIGRATION_MAP[old_club_id]
            users_ref.document(user_doc.id).update({
                'club_id': new_club_id
            })
            print(f"Updated user {user_doc.id}: {old_club_id} -> {new_club_id}")
            updated_count += 1

    print(f"\nTotal users updated: {updated_count}")

def migrate_clubs():
    """clubsコレクションのドキュメントIDを更新"""
    clubs_ref = db.collection('clubs')

    for old_id, new_id in MIGRATION_MAP.items():
        old_doc = clubs_ref.document(old_id).get()

        if old_doc.exists:
            # 新しいドキュメントを作成
            club_data = old_doc.to_dict()
            club_data['club_id'] = new_id
            clubs_ref.document(new_id).set(club_data)

            # 古いドキュメントを削除
            clubs_ref.document(old_id).delete()

            print(f"Migrated club: {old_id} -> {new_id}")

if __name__ == "__main__":
    print("Starting club ID migration...")
    print("\n1. Migrating users collection...")
    migrate_users()

    print("\n2. Migrating clubs collection...")
    migrate_clubs()

    print("\n✅ Migration completed!")
```

#### 4.2 マイグレーション実行

```bash
cd backend
python scripts/migrate_club_ids.py
```

⚠️ **注意**: 本番環境で実行する前に、必ずバックアップを取得すること！

### ステップ5: モバイルアプリ側の確認

モバイルアプリはすでにハイフン形式を使用しているため、修正は不要。
ただし、定数の一元管理のため `mobile_app/lib/config/constants.dart` を更新:

```dart
class AppConstants {
  // API設定
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';

  // クラブID定義（バックエンドと同期）
  static const List<String> validClubIds = [
    'urawa-reds',
    'kashima-antlers',
    'yokohama-fmarinos',
    'fc-tokyo',
    'kawasaki-frontale',
    'gamba-osaka',
    'cerezo-osaka',
    'nagoya-grampus',
    'vissel-kobe',
    'sanfrecce-hiroshima',
    'consadole-sapporo',
    'shimizu-spulse',
  ];

  // ポイント計算（バックエンドと同期）
  static const int stepsToPointsRatio = 1000;  // 1000歩 = 1ポイント

  // その他の定数
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
```

### ステップ6: テストの更新

#### 6.1 バックエンドのテストを更新

`backend/tests/test_auth.py`:
```python
def test_register_invalid_club_id():
    response = client.post("/api/v1/auth/register", json={
        "email": "test@example.com",
        "password": "Test1234",
        "nickname": "テストユーザー",
        "club_id": "invalid_club"  # 修正前
    })
    # ↓
    "club_id": "invalid-club"  # 修正後
```

全てのテストファイルで `club_id` の形式を確認・修正

#### 6.2 テスト実行

```bash
# バックエンド
cd backend
pytest tests/ -v

# モバイルアプリ
cd mobile_app
flutter test
```

### ステップ7: ドキュメント更新

以下のファイルを更新:
- `README.md`
- `backend/README.md`
- `mobile_app/README.md`
- API仕様書（あれば）

クラブIDの形式が **ハイフン形式** であることを明記。

## ✅ チェックリスト

- [ ] バックエンドの `validators.py` を修正
- [ ] バックエンドの `club.py` を修正
- [ ] `backend/app/config/constants.py` を作成
- [ ] 既存ファイルからの参照を更新
- [ ] マイグレーションスクリプトを作成
- [ ] **本番DBのバックアップを取得**
- [ ] マイグレーションスクリプトを実行（開発環境）
- [ ] マイグレーションスクリプトを実行（本番環境）
- [ ] モバイルアプリの定数ファイルを更新
- [ ] 全テストを更新
- [ ] テストが全てパスすることを確認
- [ ] ドキュメントを更新
- [ ] 動作確認（E2Eテスト）

## ⏱️ 推定作業時間

- コード修正: 2時間
- マイグレーション準備・実行: 1時間
- テスト修正・実行: 1時間
- ドキュメント更新: 30分

**合計**: 約4.5時間

## 🚨 注意事項

1. **必ずバックアップを取得してからマイグレーション実行**
2. まず開発環境で実行し、問題がないことを確認
3. 本番環境での実行はメンテナンス時間帯に実施
4. ロールバック計画を準備しておく
5. この変更後、既存のモバイルアプリ（古いバージョン）が動作しなくなる可能性あり → アプリの強制アップデート機能が必要

## 📚 参考資料

- [Firebase Firestoreデータ移行ベストプラクティス](https://firebase.google.com/docs/firestore/manage-data/move-data)
- [REST APIデザインガイドライン](https://restfulapi.net/resource-naming/)
