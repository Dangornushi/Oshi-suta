"""
Point calculation service.

This module handles the conversion of steps to points and related calculations.
"""

import logging
from app.config.constants import STEPS_PER_POINT, MAX_DAILY_STEPS

logger = logging.getLogger(__name__)


class PointCalculator:
    """Service for calculating points from steps and managing point-related logic."""

    def __init__(self, steps_per_point: int = None):
        """
        Initialize PointCalculator.

        Args:
            steps_per_point: Number of steps required for one point.
                           Defaults to STEPS_PER_POINT (1000)
        """
        self.steps_per_point = steps_per_point or STEPS_PER_POINT

    def calculate_points(self, steps: int) -> int:
        """
        Calculate points from steps.

        Args:
            steps: Number of steps

        Returns:
            Number of points earned

        Examples:
            >>> calc = PointCalculator(steps_per_point=1000)
            >>> calc.calculate_points(5432)
            5
            >>> calc.calculate_points(999)
            0
        """
        if steps < 0:
            logger.warning(f"Negative steps provided: {steps}")
            return 0

        points = steps // self.steps_per_point
        logger.info(f"Calculated {points} points from {steps} steps")
        return points

    def calculate_steps_for_next_point(self, current_steps: int) -> int:
        """
        Calculate how many more steps needed for the next point.

        Args:
            current_steps: Current number of steps

        Returns:
            Number of steps needed for next point

        Examples:
            >>> calc = PointCalculator(steps_per_point=1000)
            >>> calc.calculate_steps_for_next_point(8543)
            457
        """
        remainder = current_steps % self.steps_per_point
        return self.steps_per_point - remainder

    def calculate_bonus_points(self, steps: int, is_weekend: bool = False) -> int:
        """
        Calculate bonus points based on special conditions.

        Future implementation for weekend bonuses, milestones, etc.

        Args:
            steps: Number of steps
            is_weekend: Whether it's a weekend day

        Returns:
            Bonus points earned
        """
        bonus = 0

        # Weekend bonus: 10% extra points
        if is_weekend:
            base_points = self.calculate_points(steps)
            bonus += int(base_points * 0.1)

        # Milestone bonus: extra points for every 10,000 steps
        if steps >= 10000:
            milestones = steps // 10000
            bonus += milestones * 5

        logger.info(f"Calculated {bonus} bonus points for {steps} steps")
        return bonus

    def calculate_club_contribution(self, points: int, club_total_points: int) -> str:
        """
        Generate a contribution message based on points earned.

        Args:
            points: Points earned in this sync
            club_total_points: Club's total points

        Returns:
            Encouragement message string
        """
        if points == 0:
            return "Every step counts! Keep walking for your club!"

        if points >= 10:
            return f"Amazing! You've earned {points} points for your club!"
        elif points >= 5:
            return f"Great job! {points} points added to your club's total!"
        else:
            return f"Nice work! {points} points contributed to your club!"

    def validate_daily_limit(self, steps: int) -> bool:
        """
        Check if steps are within the daily limit.

        Args:
            steps: Number of steps to validate

        Returns:
            True if within limit, False otherwise
        """
        if steps > MAX_DAILY_STEPS:
            logger.warning(f"Steps {steps} exceeds daily limit {MAX_DAILY_STEPS}")
            return False
        return True
