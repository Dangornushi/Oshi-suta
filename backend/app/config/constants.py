"""
共通定数定義

このファイルはシステム全体で使用される定数を定義します。
バックエンドとモバイルアプリ間で整合性を保つため、定数はここで一元管理されます。
"""

from typing import Set

# ============================================================================
# クラブID定義 (Club IDs)
# ============================================================================
# J-League clubs - Phase 1 implementation
# 命名規則: ハイフン形式 (例: urawa-reds)
# 理由:
#   1. URLフレンドリー
#   2. JSON/APIでの標準的な形式
#   3. モバイル側との互換性

VALID_CLUB_IDS: Set[str] = {
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
    "shimizu-spulse",
}

# クラブ名（日本語表記）
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
    "shimizu-spulse": "清水エスパルス",
}

# ============================================================================
# ポイント計算定数 (Point Calculation)
# ============================================================================
STEPS_PER_POINT = 1000  # 1000歩 = 1ポイント
MAX_DAILY_STEPS = 100000  # 1日の最大歩数

# ============================================================================
# ページネーション定数 (Pagination)
# ============================================================================
DEFAULT_PAGE_SIZE = 20  # デフォルトのページサイズ
MAX_PAGE_SIZE = 100  # 最大ページサイズ

# ============================================================================
# バリデーション定数 (Validation)
# ============================================================================
MIN_STEPS = 0  # 最小歩数
MAX_STEPS = MAX_DAILY_STEPS  # 最大歩数

# ニックネーム制限
MIN_NICKNAME_LENGTH = 2
MAX_NICKNAME_LENGTH = 50

# パスワード制限
MIN_PASSWORD_LENGTH = 8
MAX_PASSWORD_LENGTH = 100

# デバイス署名制限
MIN_DEVICE_SIGNATURE_LENGTH = 1
MAX_DEVICE_SIGNATURE_LENGTH = 200
