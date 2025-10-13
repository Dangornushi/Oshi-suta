"""
Dependency injection for FastAPI endpoints.

This module provides dependency functions for authentication, database access, and caching.
"""

import logging
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import credentials, firestore, auth as firebase_auth
import redis.asyncio as aioredis

from app.config import settings
from app.repositories.firestore_repo import FirestoreRepository

logger = logging.getLogger(__name__)

# Security scheme
security = HTTPBearer()

# Global clients (initialized in main.py)
_db_client: Optional[firestore.Client] = None
_redis_client: Optional[aioredis.Redis] = None


def initialize_firebase() -> None:
    """
    Initialize Firebase Admin SDK.

    Should be called once at application startup.
    """
    global _db_client

    try:
        # Check if Firebase is already initialized
        firebase_admin.get_app()
        logger.info("Firebase already initialized")
    except ValueError:
        # Initialize Firebase
        try:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, {
                'projectId': settings.FIREBASE_PROJECT_ID,
            })
            logger.info("Firebase initialized successfully")
        except Exception as e:
            logger.warning(f"Firebase credentials not found, using default: {str(e)}")
            # For development, initialize without credentials
            firebase_admin.initialize_app(options={
                'projectId': settings.FIREBASE_PROJECT_ID,
            })

    _db_client = firestore.client()


async def initialize_redis() -> None:
    """
    Initialize Redis client.

    Should be called once at application startup.
    """
    global _redis_client

    try:
        _redis_client = await aioredis.from_url(
            f"redis://{settings.REDIS_HOST}:{settings.REDIS_PORT}",
            password=settings.REDIS_PASSWORD if settings.REDIS_PASSWORD else None,
            db=settings.REDIS_DB,
            encoding="utf-8",
            decode_responses=True
        )
        # Test connection
        await _redis_client.ping()
        logger.info("Redis connected successfully")
    except Exception as e:
        logger.error(f"Failed to connect to Redis: {str(e)}")
        _redis_client = None


async def close_redis() -> None:
    """Close Redis connection."""
    global _redis_client
    if _redis_client:
        await _redis_client.close()
        logger.info("Redis connection closed")


def get_firestore_client() -> firestore.Client:
    """
    Get Firestore client instance.

    Returns:
        Firestore client

    Raises:
        HTTPException: If Firestore is not initialized
    """
    if _db_client is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database not initialized"
        )
    return _db_client


def get_firestore_repository(
    db: firestore.Client = Depends(get_firestore_client)
) -> FirestoreRepository:
    """
    Get FirestoreRepository instance.

    Args:
        db: Firestore client (injected)

    Returns:
        FirestoreRepository instance
    """
    return FirestoreRepository(db)


async def get_redis_client() -> Optional[aioredis.Redis]:
    """
    Get Redis client instance.

    Returns:
        Redis client or None if not available
    """
    return _redis_client


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> dict:
    """
    Get current authenticated user from Firebase ID token or JWT access token.

    Args:
        credentials: HTTP bearer token credentials
        repo: Firestore repository

    Returns:
        User data dictionary

    Raises:
        HTTPException: If authentication fails
    """
    token = credentials.credentials
    user_id = None

    # Try JWT access token first (for custom auth)
    try:
        from app.utils.security import decode_access_token
        decoded = decode_access_token(token)
        if decoded:
            user_id = decoded.get('sub')
            logger.debug(f"JWT token decoded: user_id={user_id}")
    except Exception as e:
        logger.debug(f"JWT decode failed: {str(e)}")

    # If JWT failed, try Firebase ID token
    if not user_id:
        try:
            decoded_token = firebase_auth.verify_id_token(token)
            user_id = decoded_token.get('uid')
            logger.debug(f"Firebase token verified: user_id={user_id}")
        except firebase_auth.InvalidIdTokenError:
            logger.debug("Firebase token verification failed")
        except Exception as e:
            logger.debug(f"Firebase token error: {str(e)}")

    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Get user from database
    try:
        user = await repo.get_user(user_id)

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        user["user_id"] = user_id
        return user

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Authentication error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> Optional[dict]:
    """
    Get current user if authenticated, otherwise return None.

    Useful for optional authentication endpoints.

    Args:
        credentials: HTTP bearer token credentials (optional)
        repo: Firestore repository

    Returns:
        User data dictionary or None
    """
    if not credentials:
        return None

    try:
        return await get_current_user(credentials, repo)
    except HTTPException:
        return None
