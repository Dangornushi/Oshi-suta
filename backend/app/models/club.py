"""
Club domain model.

This module defines the Club entity representing J-League clubs.
"""

from typing import Optional


class Club:
    """Club domain model representing a J-League football club."""

    def __init__(
        self,
        club_id: str,
        name: str,
        founded_year: int,
        stadium: str,
        total_points: int = 0,
        active_members: int = 0,
        league_rank: int = 0,
        logo_url: Optional[str] = None,
    ):
        """
        Initialize a Club instance.

        Args:
            club_id: Unique identifier for the club
            name: Official club name
            founded_year: Year the club was founded
            stadium: Home stadium name
            total_points: Total points contributed by supporters
            active_members: Number of active supporter members
            league_rank: Current ranking in the league
            logo_url: URL to club logo image
        """
        self.club_id = club_id
        self.name = name
        self.founded_year = founded_year
        self.stadium = stadium
        self.total_points = total_points
        self.active_members = active_members
        self.league_rank = league_rank
        self.logo_url = logo_url

    def to_dict(self) -> dict:
        """
        Convert Club instance to dictionary.

        Returns:
            Dictionary representation of the club
        """
        return {
            "club_id": self.club_id,
            "name": self.name,
            "founded_year": self.founded_year,
            "stadium": self.stadium,
            "total_points": self.total_points,
            "active_members": self.active_members,
            "league_rank": self.league_rank,
            "logo_url": self.logo_url,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "Club":
        """
        Create Club instance from dictionary.

        Args:
            data: Dictionary containing club data

        Returns:
            Club instance
        """
        return cls(
            club_id=data["club_id"],
            name=data["name"],
            founded_year=data["founded_year"],
            stadium=data["stadium"],
            total_points=data.get("total_points", 0),
            active_members=data.get("active_members", 0),
            league_rank=data.get("league_rank", 0),
            logo_url=data.get("logo_url"),
        )

    def add_points(self, points: int) -> None:
        """
        Add points to club's total.

        Args:
            points: Number of points to add
        """
        self.total_points += points

    def increment_members(self) -> None:
        """Increment active member count."""
        self.active_members += 1

    def decrement_members(self) -> None:
        """Decrement active member count."""
        if self.active_members > 0:
            self.active_members -= 1

    def __repr__(self) -> str:
        """String representation of Club."""
        return f"Club(club_id={self.club_id}, name={self.name}, points={self.total_points})"
