"""
Step service for handling step-related business logic.

This module manages step synchronization, validation, and statistics.
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional

from app.repositories.firestore_repo import FirestoreRepository
from app.services.point_calculator import PointCalculator
from app.utils.validators import validate_steps, validate_date_format, validate_date_not_future

logger = logging.getLogger(__name__)


class StepService:
    """Service for managing step data and calculations."""

    def __init__(self, repository: FirestoreRepository):
        """
        Initialize StepService.

        Args:
            repository: Firestore repository instance
        """
        self.repository = repository
        self.point_calculator = PointCalculator()

    async def sync_steps(
        self,
        user_id: str,
        steps: int,
        date: str,
        source: str,
        device_signature: str
    ) -> Dict[str, Any]:
        """
        Synchronize step data for a user.

        This method:
        1. Validates the step data
        2. Checks for duplicates
        3. Calculates points
        4. Saves to Firestore
        5. Updates user and club totals

        Args:
            user_id: User identifier
            steps: Number of steps
            date: Date string (YYYY-MM-DD)
            source: Data source (healthkit/googlefit)
            device_signature: Device identifier

        Returns:
            Dictionary with sync results

        Raises:
            ValueError: If validation fails
        """
        # 1. Validate input
        if not validate_steps(steps):
            raise ValueError(f"Invalid steps count: {steps}")

        if not validate_date_format(date):
            raise ValueError(f"Invalid date format: {date}")

        if not validate_date_not_future(date):
            raise ValueError("Date cannot be in the future")

        # 2. Check for duplicate
        existing_log = await self.repository.get_step_log(user_id, date)
        if existing_log:
            logger.info(f"Step log already exists for user {user_id} on {date}")
            # Return existing data instead of raising error
            user = await self.repository.get_user(user_id)
            return {
                "points_earned": existing_log.get("points", 0),
                "total_points": user.get("total_points", 0) if user else 0,
                "club_contribution": "Data already synced for this date",
                "is_verified": True,
                "is_duplicate": True
            }

        # 3. Calculate points
        points = self.point_calculator.calculate_points(steps)
        logger.info(f"Calculated {points} points from {steps} steps")

        # 4. Save step log
        await self.repository.save_step_log(
            user_id=user_id,
            date=date,
            steps=steps,
            points=points,
            source=source,
            device_signature=device_signature
        )

        # 5. Update user points
        await self.repository.increment_user_points(user_id, points)

        # 6. Get user data to find club
        user = await self.repository.get_user(user_id)
        if not user:
            raise ValueError(f"User {user_id} not found")

        club_id = user.get("club_id")

        # 7. Update club points
        if club_id:
            await self.repository.increment_club_points(club_id, points)

        # 8. Get updated user data
        updated_user = await self.repository.get_user(user_id)
        total_points = updated_user.get("total_points", 0) if updated_user else 0

        # 9. Generate contribution message
        club = await self.repository.get_club(club_id) if club_id else None
        club_total = club.get("total_points", 0) if club else 0
        contribution_message = self.point_calculator.calculate_club_contribution(
            points, club_total
        )

        return {
            "points_earned": points,
            "total_points": total_points,
            "club_contribution": contribution_message,
            "is_verified": True,
            "is_duplicate": False
        }

    async def get_user_history(
        self,
        user_id: str,
        days: int = 30
    ) -> List[Dict[str, Any]]:
        """
        Get user's step history.

        Args:
            user_id: User identifier
            days: Number of days to retrieve (default 30)

        Returns:
            List of step history records
        """
        history = await self.repository.get_user_step_history(user_id, limit=days)
        return history

    async def get_user_stats(self, user_id: str) -> Dict[str, Any]:
        """
        Calculate user statistics.

        Args:
            user_id: User identifier

        Returns:
            Dictionary with user statistics
        """
        # Get user data
        user = await self.repository.get_user(user_id)
        if not user:
            raise ValueError(f"User {user_id} not found")

        # Get step history
        history = await self.repository.get_user_step_history(user_id, limit=365)

        if not history:
            return {
                "user_id": user_id,
                "total_steps": 0,
                "total_points": user.get("total_points", 0),
                "average_daily_steps": 0.0,
                "max_daily_steps": 0,
                "active_days": 0,
                "current_streak": 0,
                "longest_streak": 0
            }

        # Calculate statistics
        total_steps = sum(log.get("steps", 0) for log in history)
        max_steps = max(log.get("steps", 0) for log in history)
        active_days = len(history)
        average_steps = total_steps / active_days if active_days > 0 else 0.0

        # Calculate streaks
        current_streak = self._calculate_current_streak(history)
        longest_streak = self._calculate_longest_streak(history)

        return {
            "user_id": user_id,
            "total_steps": total_steps,
            "total_points": user.get("total_points", 0),
            "average_daily_steps": round(average_steps, 2),
            "max_daily_steps": max_steps,
            "active_days": active_days,
            "current_streak": current_streak,
            "longest_streak": longest_streak
        }

    def _calculate_current_streak(self, history: List[Dict[str, Any]]) -> int:
        """
        Calculate current consecutive days streak.

        Args:
            history: List of step logs ordered by date descending

        Returns:
            Current streak count
        """
        if not history:
            return 0

        streak = 0
        expected_date = datetime.now().date()

        for log in history:
            log_date_str = log.get("date")
            if not log_date_str:
                continue

            log_date = datetime.strptime(log_date_str, "%Y-%m-%d").date()

            if log_date == expected_date:
                streak += 1
                expected_date -= timedelta(days=1)
            else:
                break

        return streak

    def _calculate_longest_streak(self, history: List[Dict[str, Any]]) -> int:
        """
        Calculate longest consecutive days streak.

        Args:
            history: List of step logs

        Returns:
            Longest streak count
        """
        if not history:
            return 0

        # Sort by date
        sorted_history = sorted(
            history,
            key=lambda x: datetime.strptime(x.get("date", "1900-01-01"), "%Y-%m-%d")
        )

        max_streak = 1
        current_streak = 1

        for i in range(1, len(sorted_history)):
            prev_date = datetime.strptime(
                sorted_history[i-1].get("date", "1900-01-01"),
                "%Y-%m-%d"
            ).date()
            curr_date = datetime.strptime(
                sorted_history[i].get("date", "1900-01-01"),
                "%Y-%m-%d"
            ).date()

            if (curr_date - prev_date).days == 1:
                current_streak += 1
                max_streak = max(max_streak, current_streak)
            else:
                current_streak = 1

        return max_streak
