"""
User domain model.

This module defines the User entity for the application.
"""

from datetime import datetime
from typing import Optional


class User:
    """User domain model representing a registered user in the system."""

    def __init__(
        self,
        user_id: str,
        email: str,
        nickname: str,
        club_id: str,
        total_points: int = 0,
        total_steps: int = 0,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
    ):
        """
        Initialize a User instance.

        Args:
            user_id: Unique identifier for the user
            email: User's email address
            nickname: User's display name
            club_id: ID of the club the user supports
            total_points: Total points earned by the user
            total_steps: Total steps recorded by the user
            created_at: Account creation timestamp
            updated_at: Last update timestamp
        """
        self.user_id = user_id
        self.email = email
        self.nickname = nickname
        self.club_id = club_id
        self.total_points = total_points
        self.total_steps = total_steps
        self.created_at = created_at or datetime.now()
        self.updated_at = updated_at or datetime.now()

    def to_dict(self) -> dict:
        """
        Convert User instance to dictionary.

        Returns:
            Dictionary representation of the user
        """
        return {
            "user_id": self.user_id,
            "email": self.email,
            "nickname": self.nickname,
            "club_id": self.club_id,
            "total_points": self.total_points,
            "total_steps": self.total_steps,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }

    @classmethod
    def from_dict(cls, data: dict) -> "User":
        """
        Create User instance from dictionary.

        Args:
            data: Dictionary containing user data

        Returns:
            User instance
        """
        created_at = data.get("created_at")
        updated_at = data.get("updated_at")

        if isinstance(created_at, str):
            created_at = datetime.fromisoformat(created_at)
        if isinstance(updated_at, str):
            updated_at = datetime.fromisoformat(updated_at)

        return cls(
            user_id=data["user_id"],
            email=data["email"],
            nickname=data["nickname"],
            club_id=data["club_id"],
            total_points=data.get("total_points", 0),
            total_steps=data.get("total_steps", 0),
            created_at=created_at,
            updated_at=updated_at,
        )

    def add_points(self, points: int) -> None:
        """
        Add points to user's total.

        Args:
            points: Number of points to add
        """
        self.total_points += points
        self.updated_at = datetime.now()

    def add_steps(self, steps: int) -> None:
        """
        Add steps to user's total.

        Args:
            steps: Number of steps to add
        """
        self.total_steps += steps
        self.updated_at = datetime.now()

    def __repr__(self) -> str:
        """String representation of User."""
        return f"User(user_id={self.user_id}, email={self.email}, nickname={self.nickname})"
