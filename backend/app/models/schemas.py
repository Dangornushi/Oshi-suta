"""
Pydantic models for request/response validation.

This module defines all API request and response schemas using Pydantic models.
"""

from datetime import datetime
from typing import Literal, Optional, List
from pydantic import BaseModel, Field, EmailStr, field_validator


# ========== Authentication Schemas ==========

class UserRegisterRequest(BaseModel):
    """User registration request schema."""
    email: EmailStr
    password: str = Field(min_length=8, max_length=100)
    club_id: str = Field(min_length=1, max_length=50)
    nickname: str = Field(min_length=2, max_length=50)

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Validate password strength."""
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not any(c.islower() for c in v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one digit")
        return v


class UserLoginRequest(BaseModel):
    """User login request schema."""
    email: EmailStr
    password: str


class UserLoginResponse(BaseModel):
    """User login response schema."""
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
    nickname: str
    club_id: str


class UserProfileResponse(BaseModel):
    """User profile response schema."""
    user_id: str
    email: str
    nickname: str
    club_id: str
    total_points: int
    created_at: datetime
    updated_at: datetime


class UserProfileUpdateRequest(BaseModel):
    """User profile update request schema."""
    nickname: Optional[str] = Field(None, min_length=2, max_length=50)
    club_id: Optional[str] = Field(None, min_length=1, max_length=50)


class EmailUpdateRequest(BaseModel):
    """Email update request schema."""
    new_email: EmailStr
    password: str = Field(min_length=1, description="Current password for verification")


class PasswordChangeRequest(BaseModel):
    """Password change request schema."""
    current_password: str = Field(min_length=1, description="Current password")
    new_password: str = Field(min_length=8, max_length=100, description="New password")

    @field_validator("new_password")
    @classmethod
    def validate_new_password(cls, v: str) -> str:
        """Validate new password strength."""
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not any(c.islower() for c in v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one digit")
        return v


# ========== Steps Schemas ==========

class StepSyncRequest(BaseModel):
    """Step data synchronization request schema."""
    steps: int = Field(ge=0, le=100000, description="Number of steps taken")
    date: str = Field(pattern=r"^\d{4}-\d{2}-\d{2}$", description="Date in YYYY-MM-DD format")
    source: Literal["healthkit", "googlefit"] = Field(description="Data source")
    device_signature: str = Field(min_length=1, max_length=200, description="Device identifier")

    @field_validator("date")
    @classmethod
    def validate_date(cls, v: str) -> str:
        """Validate date format and ensure it's not in the future."""
        try:
            date_obj = datetime.strptime(v, "%Y-%m-%d")
            if date_obj.date() > datetime.now().date():
                raise ValueError("Date cannot be in the future")
        except ValueError as e:
            raise ValueError(f"Invalid date format: {str(e)}")
        return v


class StepSyncResponse(BaseModel):
    """Step data synchronization response schema."""
    points_earned: int = Field(description="Points earned from this sync")
    total_points: int = Field(description="User's total points")
    club_contribution: str = Field(description="Contribution message")
    is_verified: bool = Field(default=True, description="Whether the data is verified")
    synced_at: datetime = Field(default_factory=datetime.now)


class StepHistoryItem(BaseModel):
    """Single step history item schema."""
    date: str
    steps: int
    points: int
    source: str
    created_at: datetime


class StepHistoryResponse(BaseModel):
    """Step history response schema."""
    user_id: str
    total_records: int
    history: List[StepHistoryItem]


class StepStatsResponse(BaseModel):
    """Step statistics response schema."""
    user_id: str
    total_steps: int
    total_points: int
    average_daily_steps: float
    max_daily_steps: int
    active_days: int
    current_streak: int
    longest_streak: int


# ========== Club Schemas ==========

class ClubInfo(BaseModel):
    """Club information schema."""
    club_id: str
    name: str
    total_points: int
    active_members: int
    league_rank: int
    founded_year: int
    stadium: str
    logo_url: Optional[str] = None


class ClubListResponse(BaseModel):
    """Club list response schema."""
    total_clubs: int
    clubs: List[ClubInfo]


class ClubStatsResponse(BaseModel):
    """Club statistics response schema."""
    club_id: str
    name: str
    total_points: int
    total_steps: int
    active_members: int
    weekly_points: int
    monthly_points: int
    league_rank: int
    weekly_rank: int
    top_contributors: List[dict]


# ========== Health Check Schema ==========

class HealthCheckResponse(BaseModel):
    """Health check response schema."""
    status: str
    timestamp: datetime = Field(default_factory=datetime.now)
    version: str
    services: dict


# ========== Error Schemas ==========

class ErrorResponse(BaseModel):
    """Standard error response schema."""
    error: str
    detail: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.now)
