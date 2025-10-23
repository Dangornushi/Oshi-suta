#!/usr/bin/env python3
"""
Seed J-League club data to Firestore.

This script adds initial club data to the Firestore database.
"""

import os
import sys
from pathlib import Path

# Add parent directory to path to import app modules
sys.path.insert(0, str(Path(__file__).parent.parent))

import firebase_admin
from firebase_admin import credentials, firestore
from app.config import settings

# J-League club data
CLUBS_DATA = [
    {
        "club_id": "urawa-reds",
        "name": "浦和レッズ",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 1,
        "founded_year": 1992,
        "stadium": "埼玉スタジアム2002",
        "logo_url": None,
    },
    {
        "club_id": "kashima-antlers",
        "name": "鹿島アントラーズ",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 2,
        "founded_year": 1992,
        "stadium": "カシマサッカースタジアム",
        "logo_url": None,
    },
    {
        "club_id": "fc-tokyo",
        "name": "FC東京",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 3,
        "founded_year": 1999,
        "stadium": "味の素スタジアム",
        "logo_url": None,
    },
    {
        "club_id": "kawasaki-frontale",
        "name": "川崎フロンターレ",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 4,
        "founded_year": 1997,
        "stadium": "等々力陸上競技場",
        "logo_url": None,
    },
    {
        "club_id": "yokohama-f-marinos",
        "name": "横浜F・マリノス",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 5,
        "founded_year": 1992,
        "stadium": "日産スタジアム",
        "logo_url": None,
    },
    {
        "club_id": "nagoya-grampus",
        "name": "名古屋グランパス",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 6,
        "founded_year": 1991,
        "stadium": "豊田スタジアム",
        "logo_url": None,
    },
    {
        "club_id": "gamba-osaka",
        "name": "ガンバ大阪",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 7,
        "founded_year": 1991,
        "stadium": "パナソニックスタジアム吹田",
        "logo_url": None,
    },
    {
        "club_id": "cerezo-osaka",
        "name": "セレッソ大阪",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 8,
        "founded_year": 1993,
        "stadium": "ヨドコウサクラスタジアム",
        "logo_url": None,
    },
    {
        "club_id": "vissel-kobe",
        "name": "ヴィッセル神戸",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 9,
        "founded_year": 1995,
        "stadium": "ノエビアスタジアム神戸",
        "logo_url": None,
    },
    {
        "club_id": "sanfrecce-hiroshima",
        "name": "サンフレッチェ広島",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 10,
        "founded_year": 1992,
        "stadium": "エディオンスタジアム広島",
        "logo_url": None,
    },
    {
        "club_id": "consadole-sapporo",
        "name": "コンサドーレ札幌",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 11,
        "founded_year": 1996,
        "stadium": "札幌ドーム",
        "logo_url": None,
    },
    {
        "club_id": "vegalta-sendai",
        "name": "ベガルタ仙台",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 12,
        "founded_year": 1988,
        "stadium": "ユアテックスタジアム仙台",
        "logo_url": None,
    },
    {
        "club_id": "kashiwa-reysol",
        "name": "柏レイソル",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 13,
        "founded_year": 1995,
        "stadium": "三協フロンテア柏スタジアム",
        "logo_url": None,
    },
    {
        "club_id": "shimizu-s-pulse",
        "name": "清水エスパルス",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 14,
        "founded_year": 1991,
        "stadium": "IAIスタジアム日本平",
        "logo_url": None,
    },
    {
        "club_id": "jubilo-iwata",
        "name": "ジュビロ磐田",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 15,
        "founded_year": 1994,
        "stadium": "ヤマハスタジアム",
        "logo_url": None,
    },
    {
        "club_id": "kyoto-sanga",
        "name": "京都サンガF.C.",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 16,
        "founded_year": 1922,
        "stadium": "サンガスタジアム by KYOCERA",
        "logo_url": None,
    },
    {
        "club_id": "avispa-fukuoka",
        "name": "アビスパ福岡",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 17,
        "founded_year": 1982,
        "stadium": "ベスト電器スタジアム",
        "logo_url": None,
    },
    {
        "club_id": "sagan-tosu",
        "name": "サガン鳥栖",
        "total_points": 0,
        "active_members": 0,
        "league_rank": 18,
        "founded_year": 1997,
        "stadium": "駅前不動産スタジアム",
        "logo_url": None,
    },
]


def initialize_firebase():
    """Initialize Firebase Admin SDK."""
    try:
        firebase_admin.get_app()
        print("Firebase already initialized")
    except ValueError:
        try:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, {
                'projectId': settings.FIREBASE_PROJECT_ID,
            })
            print("Firebase initialized successfully")
        except Exception as e:
            print(f"Warning: Firebase credentials not found: {str(e)}")
            firebase_admin.initialize_app()
            print("Firebase initialized with default credentials")


def seed_clubs():
    """Seed club data to Firestore."""
    try:
        # Initialize Firebase
        initialize_firebase()

        # Get Firestore client
        db = firestore.client()

        print("\nStarting to seed club data...")
        print(f"Total clubs to add: {len(CLUBS_DATA)}")
        print("-" * 50)

        clubs_collection = db.collection("clubs")

        added_count = 0
        updated_count = 0

        for club_data in CLUBS_DATA:
            club_id = club_data["club_id"]

            # Check if club already exists
            doc_ref = clubs_collection.document(club_id)
            doc = doc_ref.get()

            if doc.exists:
                print(f"⚠️  Club '{club_data['name']}' already exists. Updating...")
                doc_ref.update(club_data)
                updated_count += 1
            else:
                print(f"✓ Adding club: {club_data['name']} ({club_id})")
                doc_ref.set(club_data)
                added_count += 1

        print("-" * 50)
        print(f"✓ Successfully added {added_count} new clubs")
        print(f"✓ Updated {updated_count} existing clubs")
        print(f"✓ Total clubs in database: {added_count + updated_count}")

    except Exception as e:
        print(f"❌ Error seeding clubs: {str(e)}")
        raise


if __name__ == "__main__":
    seed_clubs()
