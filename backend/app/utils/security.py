"""
Security utility functions.

This module provides security-related functions for authentication and authorization.
"""

from datetime import datetime, timedelta
from typing import Optional
import requests
import logging
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.settings import settings

logger = logging.getLogger(__name__)

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """
    Hash a password using bcrypt.

    Args:
        password: Plain text password

    Returns:
        Hashed password string
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a password against its hash.

    Args:
        plain_password: Plain text password to verify
        hashed_password: Hashed password to check against

    Returns:
        True if password matches, False otherwise
    """
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT access token.

    Args:
        data: Dictionary of data to encode in the token
        expires_delta: Optional custom expiration time

    Returns:
        Encoded JWT token string
    """
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """
    Decode and verify a JWT access token.

    Args:
        token: JWT token string to decode

    Returns:
        Decoded token payload as dictionary, or None if invalid
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None


def verify_password_with_firebase(email: str, password: str) -> Optional[dict]:
    """
    Verify user credentials with Firebase Authentication REST API.

    Firebase Admin SDK doesn't provide a direct way to verify passwords,
    so we use the Firebase Auth REST API.

    Args:
        email: User's email address
        password: User's plain text password

    Returns:
        User data dict if authentication succeeds, None otherwise
    """
    if not settings.FIREBASE_WEB_API_KEY:
        logger.error("FIREBASE_WEB_API_KEY is not configured")
        return None

    # Firebase Auth REST API endpoint
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={settings.FIREBASE_WEB_API_KEY}"

    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True
    }

    try:
        response = requests.post(url, json=payload, timeout=10)

        if response.status_code == 200:
            data = response.json()
            return {
                "local_id": data.get("localId"),
                "email": data.get("email"),
                "id_token": data.get("idToken"),
                "refresh_token": data.get("refreshToken"),
                "expires_in": data.get("expiresIn")
            }
        else:
            error_data = response.json()
            error_message = error_data.get("error", {}).get("message", "Unknown error")
            logger.warning(f"Firebase Auth failed for {email}: {error_message}")
            return None

    except requests.RequestException as e:
        logger.error(f"Firebase Auth request error: {str(e)}")
        return None
    except Exception as e:
        logger.error(f"Firebase Auth error: {str(e)}")
        return None


def verify_firebase_token(token: str) -> Optional[dict]:
    """
    Verify a Firebase ID token.

    This is a placeholder for Firebase token verification.
    In production, use firebase_admin.auth.verify_id_token()

    Args:
        token: Firebase ID token

    Returns:
        Decoded token data or None if invalid
    """
    # TODO: Implement proper Firebase token verification
    # from firebase_admin import auth
    # try:
    #     decoded_token = auth.verify_id_token(token)
    #     return decoded_token
    # except Exception:
    #     return None

    # For now, return a placeholder
    return {"uid": "test_user_id", "email": "test@example.com"}
