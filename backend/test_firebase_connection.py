"""
Firebase connection test script.

This script tests the Firebase connection and verifies that the credentials are properly configured.
"""

import os
import sys
import logging
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

import firebase_admin
from firebase_admin import credentials, firestore
from app.config import settings

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def test_firebase_connection():
    """Test Firebase connection and basic operations."""

    print("\n" + "="*60)
    print("Firebase Connection Test")
    print("="*60 + "\n")

    # Step 1: Check credentials file
    print(f"1. Checking credentials file...")
    creds_path = settings.FIREBASE_CREDENTIALS_PATH
    print(f"   Credentials path: {creds_path}")

    if not os.path.exists(creds_path):
        print(f"   ❌ Credentials file not found at: {creds_path}")
        return False
    print(f"   ✅ Credentials file found")

    # Step 2: Initialize Firebase
    print(f"\n2. Initializing Firebase Admin SDK...")
    print(f"   Project ID: {settings.FIREBASE_PROJECT_ID}")

    try:
        # Check if already initialized
        try:
            firebase_admin.get_app()
            print("   ⚠️  Firebase already initialized, using existing app")
        except ValueError:
            # Initialize Firebase
            cred = credentials.Certificate(creds_path)
            firebase_admin.initialize_app(cred, {
                'projectId': settings.FIREBASE_PROJECT_ID,
            })
            print("   ✅ Firebase Admin SDK initialized successfully")
    except Exception as e:
        print(f"   ❌ Failed to initialize Firebase: {str(e)}")
        return False

    # Step 3: Get Firestore client
    print(f"\n3. Connecting to Firestore...")
    try:
        db = firestore.client()
        print("   ✅ Firestore client created successfully")
    except Exception as e:
        print(f"   ❌ Failed to create Firestore client: {str(e)}")
        return False

    # Step 4: Test Firestore read operation
    print(f"\n4. Testing Firestore operations...")
    try:
        # Try to list collections (this requires read permission)
        all_collections = list(db.collections())
        print(f"   ✅ Successfully connected to Firestore")
        print(f"   📊 Database has {len(all_collections)} collection(s)")

        # List collection names
        if all_collections:
            print(f"   📁 Collections found:")
            for coll in all_collections:
                print(f"      - {coll.id}")
        else:
            print(f"   📁 No collections found (database is empty)")

    except Exception as e:
        print(f"   ❌ Failed to access Firestore: {str(e)}")
        return False

    # Step 5: Test write operation (optional)
    print(f"\n5. Testing write operation...")
    try:
        test_collection = db.collection('_connection_test')
        test_doc = test_collection.document('test')
        test_doc.set({
            'test': True,
            'timestamp': firestore.SERVER_TIMESTAMP,
            'message': 'Connection test successful'
        })
        print("   ✅ Write operation successful")

        # Read it back
        doc = test_doc.get()
        if doc.exists:
            print("   ✅ Read operation successful")
            print(f"   📝 Document data: {doc.to_dict()}")

        # Clean up
        test_doc.delete()
        print("   ✅ Delete operation successful (cleanup completed)")

    except Exception as e:
        print(f"   ⚠️  Write operation failed: {str(e)}")
        print("   ℹ️  This might be due to permissions, but read operations are working")

    # Success
    print("\n" + "="*60)
    print("✅ Firebase connection test completed successfully!")
    print("="*60 + "\n")
    return True


if __name__ == "__main__":
    try:
        success = test_firebase_connection()
        sys.exit(0 if success else 1)
    except Exception as e:
        logger.error(f"Unexpected error during test: {str(e)}", exc_info=True)
        print(f"\n❌ Test failed with error: {str(e)}")
        sys.exit(1)
