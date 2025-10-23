#!/usr/bin/env python3
"""
クラブID移行スクリプト
アンダースコア形式からハイフン形式に変換

使用方法:
    python scripts/migrate_club_ids.py [--dry-run]

オプション:
    --dry-run: 実際の変更を行わず、変更内容のみを表示
"""

import argparse
import sys
import os

# プロジェクトルートをPythonパスに追加
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

# 環境変数を読み込み
load_dotenv()

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
    "shimizu_spulse": "shimizu-spulse",
}


def init_firebase():
    """Firebase初期化"""
    try:
        # すでに初期化されている場合はスキップ
        firebase_admin.get_app()
        print("✓ Firebase already initialized")
    except ValueError:
        # 初期化されていない場合は初期化
        cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "./firebase-credentials.json")
        if not os.path.exists(cred_path):
            print(f"❌ Firebase credentials file not found: {cred_path}")
            print("Please set FIREBASE_CREDENTIALS_PATH environment variable")
            sys.exit(1)

        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("✓ Firebase initialized successfully")


def migrate_users(db, dry_run=False):
    """usersコレクションのclub_idを更新"""
    print("\n" + "="*60)
    print("1. Migrating users collection...")
    print("="*60)

    users_ref = db.collection('users')
    users = users_ref.stream()

    updated_count = 0
    skipped_count = 0

    for user_doc in users:
        user_data = user_doc.to_dict()
        old_club_id = user_data.get('club_id')

        if old_club_id in MIGRATION_MAP:
            new_club_id = MIGRATION_MAP[old_club_id]

            if dry_run:
                print(f"  [DRY RUN] Would update user {user_doc.id}: {old_club_id} -> {new_club_id}")
            else:
                users_ref.document(user_doc.id).update({
                    'club_id': new_club_id
                })
                print(f"  ✓ Updated user {user_doc.id}: {old_club_id} -> {new_club_id}")

            updated_count += 1
        elif old_club_id:
            # すでに新形式の場合、または移行対象外の場合
            if old_club_id in MIGRATION_MAP.values():
                skipped_count += 1
            else:
                print(f"  ⚠️  Unknown club_id in user {user_doc.id}: {old_club_id}")
                skipped_count += 1

    print(f"\n  Total users processed:")
    print(f"    - Updated: {updated_count}")
    print(f"    - Skipped: {skipped_count}")

    return updated_count


def migrate_clubs(db, dry_run=False):
    """clubsコレクションのドキュメントIDを更新"""
    print("\n" + "="*60)
    print("2. Migrating clubs collection...")
    print("="*60)

    clubs_ref = db.collection('clubs')
    migrated_count = 0
    skipped_count = 0

    for old_id, new_id in MIGRATION_MAP.items():
        old_doc = clubs_ref.document(old_id).get()

        if old_doc.exists:
            if dry_run:
                print(f"  [DRY RUN] Would migrate club: {old_id} -> {new_id}")
            else:
                # 新しいドキュメントを作成
                club_data = old_doc.to_dict()
                club_data['club_id'] = new_id
                clubs_ref.document(new_id).set(club_data)

                # 古いドキュメントを削除
                clubs_ref.document(old_id).delete()

                print(f"  ✓ Migrated club: {old_id} -> {new_id}")

            migrated_count += 1
        else:
            # 新しいIDのドキュメントが存在するか確認
            new_doc = clubs_ref.document(new_id).get()
            if new_doc.exists:
                skipped_count += 1
            else:
                print(f"  ⚠️  Club document not found: {old_id}")
                skipped_count += 1

    print(f"\n  Total clubs processed:")
    print(f"    - Migrated: {migrated_count}")
    print(f"    - Skipped: {skipped_count}")

    return migrated_count


def verify_migration(db):
    """マイグレーション結果を検証"""
    print("\n" + "="*60)
    print("3. Verifying migration...")
    print("="*60)

    clubs_ref = db.collection('clubs')
    users_ref = db.collection('users')

    # 新形式のクラブIDが存在することを確認
    new_clubs = []
    old_clubs = []

    for new_id in MIGRATION_MAP.values():
        doc = clubs_ref.document(new_id).get()
        if doc.exists:
            new_clubs.append(new_id)

    for old_id in MIGRATION_MAP.keys():
        doc = clubs_ref.document(old_id).get()
        if doc.exists:
            old_clubs.append(old_id)

    print(f"\n  Clubs with new format IDs: {len(new_clubs)}")
    print(f"  Clubs with old format IDs: {len(old_clubs)}")

    if old_clubs:
        print(f"\n  ⚠️  Warning: Old format clubs still exist:")
        for club in old_clubs:
            print(f"    - {club}")

    # ユーザーのクラブIDを確認
    users = users_ref.stream()
    user_club_ids = {}

    for user_doc in users:
        user_data = user_doc.to_dict()
        club_id = user_data.get('club_id')
        if club_id:
            user_club_ids[club_id] = user_club_ids.get(club_id, 0) + 1

    print(f"\n  User club_id distribution:")
    for club_id, count in sorted(user_club_ids.items()):
        format_type = "NEW" if '-' in club_id else "OLD"
        print(f"    - {club_id}: {count} users [{format_type}]")

    # 検証結果
    has_old_format_users = any('_' in cid for cid in user_club_ids.keys())
    has_old_format_clubs = len(old_clubs) > 0

    if not has_old_format_users and not has_old_format_clubs:
        print("\n  ✅ Migration verification successful!")
        return True
    else:
        print("\n  ⚠️  Migration incomplete - old format data still exists")
        return False


def main():
    parser = argparse.ArgumentParser(description='Migrate club IDs from underscore to hyphen format')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what would be changed without making actual changes')
    args = parser.parse_args()

    print("="*60)
    print("Club ID Migration Script")
    print("="*60)

    if args.dry_run:
        print("\n⚠️  DRY RUN MODE - No actual changes will be made\n")
    else:
        print("\n⚠️  WARNING: This will modify your database!")
        print("⚠️  Make sure you have a backup before proceeding!")
        response = input("\nDo you want to continue? (yes/no): ")
        if response.lower() != 'yes':
            print("Migration cancelled.")
            sys.exit(0)

    # Firebase初期化
    init_firebase()
    db = firestore.client()

    # マイグレーション実行
    try:
        users_updated = migrate_users(db, dry_run=args.dry_run)
        clubs_migrated = migrate_clubs(db, dry_run=args.dry_run)

        # 検証（実際の変更を行った場合のみ）
        if not args.dry_run:
            verify_migration(db)

        # 完了メッセージ
        print("\n" + "="*60)
        if args.dry_run:
            print("DRY RUN COMPLETED")
            print("="*60)
            print(f"\nWould update {users_updated} users")
            print(f"Would migrate {clubs_migrated} clubs")
            print("\nRun without --dry-run to apply changes")
        else:
            print("✅ MIGRATION COMPLETED!")
            print("="*60)
            print(f"\nUpdated {users_updated} users")
            print(f"Migrated {clubs_migrated} clubs")

    except Exception as e:
        print(f"\n❌ Error during migration: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
