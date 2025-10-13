"""
Step tracking endpoints.

This module handles step data synchronization, history, and statistics.
"""

import logging
from fastapi import APIRouter, Depends, HTTPException, status, Query

from app.models.schemas import (
    StepSyncRequest,
    StepSyncResponse,
    StepHistoryResponse,
    StepHistoryItem,
    StepStatsResponse,
    ErrorResponse
)
from app.dependencies import get_firestore_repository, get_current_user
from app.repositories.firestore_repo import FirestoreRepository
from app.services.step_service import StepService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/steps", tags=["steps"])


@router.post(
    "/sync",
    response_model=StepSyncResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Invalid input"},
        401: {"model": ErrorResponse, "description": "Unauthorized"}
    }
)
async def sync_steps(
    request: StepSyncRequest,
    current_user: dict = Depends(get_current_user),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> StepSyncResponse:
    """
    Synchronize step data for the authenticated user.

    This endpoint:
    - Validates step data
    - Calculates points (1,000 steps = 1 point)
    - Saves to Firestore
    - Updates user and club totals
    - Returns sync results

    Args:
        request: Step sync request data
        current_user: Authenticated user
        repo: Firestore repository

    Returns:
        StepSyncResponse with points earned and totals

    Raises:
        HTTPException: If sync fails
    """
    try:
        user_id = current_user["user_id"]
        step_service = StepService(repo)

        result = await step_service.sync_steps(
            user_id=user_id,
            steps=request.steps,
            date=request.date,
            source=request.source,
            device_signature=request.device_signature
        )

        return StepSyncResponse(
            points_earned=result["points_earned"],
            total_points=result["total_points"],
            club_contribution=result["club_contribution"],
            is_verified=result.get("is_verified", True)
        )

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Step sync error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to sync steps"
        )


@router.get(
    "/history",
    response_model=StepHistoryResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"}
    }
)
async def get_step_history(
    days: int = Query(default=30, ge=1, le=365, description="Number of days to retrieve"),
    current_user: dict = Depends(get_current_user),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> StepHistoryResponse:
    """
    Get step history for the authenticated user.

    Args:
        days: Number of days to retrieve (1-365)
        current_user: Authenticated user
        repo: Firestore repository

    Returns:
        StepHistoryResponse with step history

    Raises:
        HTTPException: If retrieval fails
    """
    try:
        user_id = current_user["user_id"]
        step_service = StepService(repo)

        history = await step_service.get_user_history(user_id, days)

        # Convert to StepHistoryItem objects
        history_items = [
            StepHistoryItem(
                date=log.get("date", ""),
                steps=log.get("steps", 0),
                points=log.get("points", 0),
                source=log.get("source", ""),
                created_at=log.get("created_at")
            )
            for log in history
        ]

        return StepHistoryResponse(
            user_id=user_id,
            total_records=len(history_items),
            history=history_items
        )

    except Exception as e:
        logger.error(f"History retrieval error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve step history"
        )


@router.get(
    "/stats",
    response_model=StepStatsResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"}
    }
)
async def get_step_stats(
    current_user: dict = Depends(get_current_user),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> StepStatsResponse:
    """
    Get step statistics for the authenticated user.

    Returns comprehensive statistics including:
    - Total steps and points
    - Average daily steps
    - Maximum daily steps
    - Active days count
    - Current and longest streaks

    Args:
        current_user: Authenticated user
        repo: Firestore repository

    Returns:
        StepStatsResponse with user statistics

    Raises:
        HTTPException: If retrieval fails
    """
    try:
        user_id = current_user["user_id"]
        step_service = StepService(repo)

        stats = await step_service.get_user_stats(user_id)

        return StepStatsResponse(**stats)

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Stats retrieval error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve statistics"
        )
