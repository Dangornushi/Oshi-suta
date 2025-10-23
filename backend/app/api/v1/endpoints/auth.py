"""
Authentication endpoints.

This module handles user registration, login, and profile management.
"""

import logging
from fastapi import APIRouter, Depends, HTTPException, status
from firebase_admin import auth as firebase_auth

from app.models.schemas import (
    UserRegisterRequest,
    UserLoginRequest,
    UserLoginResponse,
    UserProfileResponse,
    UserProfileUpdateRequest,
    EmailUpdateRequest,
    PasswordChangeRequest,
    ErrorResponse
)
from app.dependencies import get_firestore_repository, get_current_user
from app.repositories.firestore_repo import FirestoreRepository
from app.utils.validators import validate_club_id, validate_nickname
from app.utils.security import hash_password, verify_password, create_access_token, verify_password_with_firebase
from app.utils.error_handlers import handle_exceptions, validate_and_raise, ValidationError

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["authentication"])


@router.post(
    "/register",
    response_model=UserLoginResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponse, "description": "Invalid input"},
        409: {"model": ErrorResponse, "description": "User already exists"}
    }
)
@handle_exceptions("User registration")
async def register(
    request: UserRegisterRequest,
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> UserLoginResponse:
    """
    Register a new user.

    Creates a new user account in Firebase Auth and Firestore.

    Args:
        request: User registration data
        repo: Firestore repository

    Returns:
        UserLoginResponse with access token and user info

    Raises:
        HTTPException: If registration fails
    """
    # Validate club ID
    validate_and_raise(
        validate_club_id(request.club_id),
        f"Invalid club ID: {request.club_id}"
    )

    # Validate nickname
    is_valid, error_msg = validate_nickname(request.nickname)
    validate_and_raise(is_valid, error_msg)

    # Check if user already exists
    existing_user = await repo.get_user_by_email(request.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User with this email already exists"
        )

    # Create user in Firebase Auth
    try:
        firebase_user = firebase_auth.create_user(
            email=request.email,
            password=request.password,
            display_name=request.nickname
        )
        user_id = firebase_user.uid
    except firebase_auth.EmailAlreadyExistsError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already in use"
        )
    except Exception as e:
        logger.error(f"Firebase Auth error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create user account"
        )

    # Create user document in Firestore
    user_data = {
        "email": request.email,
        "nickname": request.nickname,
        "club_id": request.club_id,
        "total_points": 0,
        "total_steps": 0
    }

    await repo.create_user(user_id, user_data)

    # Increment club member count
    await repo.get_club(request.club_id)  # Ensure club exists
    # Note: In production, you'd want to increment active_members here

    # Generate access token
    access_token = create_access_token(data={"sub": user_id, "email": request.email})

    logger.info(f"User registered successfully: {user_id}")

    return UserLoginResponse(
        access_token=access_token,
        token_type="bearer",
        user_id=user_id,
        email=request.email,
        nickname=request.nickname,
        club_id=request.club_id
    )


@router.post(
    "/login",
    response_model=UserLoginResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Invalid credentials"}
    }
)
@handle_exceptions("User login")
async def login(
    request: UserLoginRequest,
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> UserLoginResponse:
    """
    Login with email and password.

    Verifies credentials with Firebase Auth, then returns user info from Firestore.

    Args:
        request: Login credentials
        repo: Firestore repository

    Returns:
        UserLoginResponse with access token and user info

    Raises:
        HTTPException: If login fails
    """
    # Step 1: Verify password with Firebase Auth
    firebase_result = verify_password_with_firebase(request.email, request.password)

    if not firebase_result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Step 2: Get user info from Firestore using Firebase UID
    firebase_uid = firebase_result.get("local_id")
    user = await repo.get_user(firebase_uid)

    if not user:
        # User exists in Firebase Auth but not in Firestore
        logger.error(f"User {firebase_uid} exists in Firebase Auth but not in Firestore")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User data not found"
        )

    # Step 3: Generate our own access token
    access_token = create_access_token(data={"sub": firebase_uid, "email": request.email})

    logger.info(f"User {firebase_uid} logged in successfully")

    return UserLoginResponse(
        access_token=access_token,
        token_type="bearer",
        user_id=firebase_uid,
        email=user["email"],
        nickname=user["nickname"],
        club_id=user["club_id"]
    )


@router.get(
    "/profile",
    response_model=UserProfileResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"},
        404: {"model": ErrorResponse, "description": "User not found"}
    }
)
async def get_profile(
    current_user: dict = Depends(get_current_user)
) -> UserProfileResponse:
    """
    Get current user's profile.

    Args:
        current_user: Current authenticated user

    Returns:
        UserProfileResponse with user profile data
    """
    return UserProfileResponse(
        user_id=current_user["user_id"],
        email=current_user["email"],
        nickname=current_user["nickname"],
        club_id=current_user["club_id"],
        total_points=current_user.get("total_points", 0),
        created_at=current_user.get("created_at"),
        updated_at=current_user.get("updated_at")
    )


@router.patch(
    "/profile",
    response_model=UserProfileResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Invalid input"},
        401: {"model": ErrorResponse, "description": "Unauthorized"}
    }
)
@handle_exceptions("Profile update")
async def update_profile(
    request: UserProfileUpdateRequest,
    current_user: dict = Depends(get_current_user),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> UserProfileResponse:
    """
    Update user profile.

    Args:
        request: Profile update data
        current_user: Current authenticated user
        repo: Firestore repository

    Returns:
        Updated UserProfileResponse

    Raises:
        HTTPException: If update fails
    """
    update_data = {}

    # Validate and add nickname if provided
    if request.nickname:
        is_valid, error_msg = validate_nickname(request.nickname)
        validate_and_raise(is_valid, error_msg)
        update_data["nickname"] = request.nickname

    # Validate and add club_id if provided
    if request.club_id:
        validate_and_raise(
            validate_club_id(request.club_id),
            f"Invalid club ID: {request.club_id}"
        )
        update_data["club_id"] = request.club_id

    # Update user in Firestore
    if update_data:
        await repo.update_user(current_user["user_id"], update_data)

    # Get updated user data
    updated_user = await repo.get_user(current_user["user_id"])

    return UserProfileResponse(
        user_id=current_user["user_id"],
        email=updated_user["email"],
        nickname=updated_user["nickname"],
        club_id=updated_user["club_id"],
        total_points=updated_user.get("total_points", 0),
        created_at=updated_user.get("created_at"),
        updated_at=updated_user.get("updated_at")
    )


@router.put(
    "/email",
    response_model=UserProfileResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Invalid input"},
        401: {"model": ErrorResponse, "description": "Unauthorized or invalid password"},
        409: {"model": ErrorResponse, "description": "Email already in use"}
    }
)
@handle_exceptions("Email update")
async def update_email(
    request: EmailUpdateRequest,
    current_user: dict = Depends(get_current_user),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> UserProfileResponse:
    """
    Update user email address.

    Args:
        request: Email update data
        current_user: Current authenticated user
        repo: Firestore repository

    Returns:
        Updated UserProfileResponse

    Raises:
        HTTPException: If update fails
    """
    # Step 1: Verify current password
    verify_result = verify_password_with_firebase(
        current_user["email"],
        request.password
    )

    if not verify_result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid password"
        )

    # Step 2: Check if new email is already in use
    existing_user = await repo.get_user_by_email(request.new_email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already in use"
        )

    # Step 3: Update email in Firebase Auth
    try:
        firebase_auth.update_user(
            current_user["user_id"],
            email=request.new_email
        )
    except firebase_auth.EmailAlreadyExistsError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already in use"
        )
    except Exception as e:
        logger.error(f"Firebase Auth email update error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update email in authentication system"
        )

    # Step 4: Update email in Firestore
    await repo.update_user(current_user["user_id"], {"email": request.new_email})

    # Step 5: Get updated user data
    updated_user = await repo.get_user(current_user["user_id"])

    logger.info(f"Email updated successfully for user: {current_user['user_id']}")

    return UserProfileResponse(
        user_id=current_user["user_id"],
        email=updated_user["email"],
        nickname=updated_user["nickname"],
        club_id=updated_user["club_id"],
        total_points=updated_user.get("total_points", 0),
        created_at=updated_user.get("created_at"),
        updated_at=updated_user.get("updated_at")
    )


@router.put(
    "/password",
    status_code=status.HTTP_200_OK,
    responses={
        400: {"model": ErrorResponse, "description": "Invalid input"},
        401: {"model": ErrorResponse, "description": "Unauthorized or invalid password"}
    }
)
@handle_exceptions("Password change")
async def change_password(
    request: PasswordChangeRequest,
    current_user: dict = Depends(get_current_user)
) -> dict:
    """
    Change user password.

    Args:
        request: Password change data
        current_user: Current authenticated user

    Returns:
        Success message

    Raises:
        HTTPException: If password change fails
    """
    # Step 1: Verify current password
    verify_result = verify_password_with_firebase(
        current_user["email"],
        request.current_password
    )

    if not verify_result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid current password"
        )

    # Step 2: Check new password is different from current
    if request.current_password == request.new_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="New password must be different from current password"
        )

    # Step 3: Update password in Firebase Auth
    try:
        firebase_auth.update_user(
            current_user["user_id"],
            password=request.new_password
        )
    except Exception as e:
        logger.error(f"Firebase Auth password update error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update password"
        )

    logger.info(f"Password updated successfully for user: {current_user['user_id']}")

    return {
        "message": "Password updated successfully",
        "user_id": current_user["user_id"]
    }
