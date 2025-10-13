"""
Club information endpoints.

This module handles club data retrieval and statistics.
"""

import logging
from fastapi import APIRouter, Depends, HTTPException, status, Path

from app.models.schemas import (
    ClubInfo,
    ClubListResponse,
    ClubStatsResponse,
    ErrorResponse
)
from app.dependencies import get_firestore_repository
from app.repositories.firestore_repo import FirestoreRepository

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/clubs", tags=["clubs"])


@router.get(
    "",
    response_model=ClubListResponse,
    summary="Get all clubs"
)
async def get_all_clubs(
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> ClubListResponse:
    """
    Get list of all J-League clubs.

    Returns club information including:
    - Club ID and name
    - Total points from supporters
    - Active member count
    - League ranking

    Args:
        repo: Firestore repository

    Returns:
        ClubListResponse with list of all clubs

    Raises:
        HTTPException: If retrieval fails
    """
    try:
        clubs_data = await repo.get_all_clubs()

        clubs = [
            ClubInfo(
                club_id=club.get("club_id", ""),
                name=club.get("name", ""),
                total_points=club.get("total_points", 0),
                active_members=club.get("active_members", 0),
                league_rank=club.get("league_rank", 0),
                founded_year=club.get("founded_year", 1900),
                stadium=club.get("stadium", ""),
                logo_url=club.get("logo_url")
            )
            for club in clubs_data
        ]

        # Sort by total points descending
        clubs.sort(key=lambda x: x.total_points, reverse=True)

        return ClubListResponse(
            total_clubs=len(clubs),
            clubs=clubs
        )

    except Exception as e:
        logger.error(f"Error retrieving clubs: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve clubs"
        )


@router.get(
    "/{club_id}",
    response_model=ClubInfo,
    responses={
        404: {"model": ErrorResponse, "description": "Club not found"}
    }
)
async def get_club(
    club_id: str = Path(..., description="Club identifier"),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> ClubInfo:
    """
    Get specific club information.

    Args:
        club_id: Club identifier
        repo: Firestore repository

    Returns:
        ClubInfo with club details

    Raises:
        HTTPException: If club not found
    """
    try:
        club = await repo.get_club(club_id)

        if not club:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Club {club_id} not found"
            )

        return ClubInfo(
            club_id=club_id,
            name=club.get("name", ""),
            total_points=club.get("total_points", 0),
            active_members=club.get("active_members", 0),
            league_rank=club.get("league_rank", 0),
            founded_year=club.get("founded_year", 1900),
            stadium=club.get("stadium", ""),
            logo_url=club.get("logo_url")
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving club {club_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve club"
        )


@router.get(
    "/{club_id}/stats",
    response_model=ClubStatsResponse,
    responses={
        404: {"model": ErrorResponse, "description": "Club not found"}
    }
)
async def get_club_stats(
    club_id: str = Path(..., description="Club identifier"),
    repo: FirestoreRepository = Depends(get_firestore_repository)
) -> ClubStatsResponse:
    """
    Get detailed club statistics.

    Returns comprehensive statistics including:
    - Total points and steps
    - Active member count
    - Weekly and monthly points
    - Rankings
    - Top contributors

    Args:
        club_id: Club identifier
        repo: Firestore repository

    Returns:
        ClubStatsResponse with detailed statistics

    Raises:
        HTTPException: If club not found
    """
    try:
        club = await repo.get_club(club_id)

        if not club:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Club {club_id} not found"
            )

        # Get member count
        member_count = await repo.get_club_members_count(club_id)

        # TODO: Implement weekly/monthly points calculation
        # TODO: Implement top contributors retrieval
        # For Phase 1, return basic stats

        return ClubStatsResponse(
            club_id=club_id,
            name=club.get("name", ""),
            total_points=club.get("total_points", 0),
            total_steps=club.get("total_steps", 0),
            active_members=member_count,
            weekly_points=0,  # TODO: Implement
            monthly_points=0,  # TODO: Implement
            league_rank=club.get("league_rank", 0),
            weekly_rank=0,  # TODO: Implement
            top_contributors=[]  # TODO: Implement
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving club stats for {club_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve club statistics"
        )
