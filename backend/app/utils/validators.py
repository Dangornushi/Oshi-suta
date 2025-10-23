"""
Validation utility functions.

This module provides validation functions for various data types used in the application.
"""

import re
from datetime import datetime
from app.config.constants import (
    VALID_CLUB_IDS,
    MIN_NICKNAME_LENGTH,
    MAX_NICKNAME_LENGTH,
    MIN_PASSWORD_LENGTH,
    MAX_PASSWORD_LENGTH,
    MIN_DEVICE_SIGNATURE_LENGTH,
    MAX_DEVICE_SIGNATURE_LENGTH,
    MIN_STEPS,
    MAX_STEPS,
)


def validate_steps(steps: int) -> bool:
    """
    Validate if the steps count is within acceptable range.

    Args:
        steps: Number of steps to validate

    Returns:
        True if valid, False otherwise

    Examples:
        >>> validate_steps(10000)
        True
        >>> validate_steps(-100)
        False
        >>> validate_steps(150000)
        False
    """
    return MIN_STEPS <= steps <= MAX_STEPS


def validate_date_format(date_str: str) -> bool:
    """
    Validate if the date string is in YYYY-MM-DD format and is valid.

    Args:
        date_str: Date string to validate

    Returns:
        True if valid, False otherwise

    Examples:
        >>> validate_date_format("2025-10-10")
        True
        >>> validate_date_format("2025-13-01")
        False
        >>> validate_date_format("10-10-2025")
        False
    """
    # Check format with regex
    pattern = r"^\d{4}-\d{2}-\d{2}$"
    if not re.match(pattern, date_str):
        return False

    # Check if it's a valid date
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
        return True
    except ValueError:
        return False


def validate_date_not_future(date_str: str) -> bool:
    """
    Validate that the date is not in the future.

    Args:
        date_str: Date string in YYYY-MM-DD format

    Returns:
        True if not in future, False otherwise

    Examples:
        >>> validate_date_not_future("2020-01-01")
        True
    """
    try:
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        return date_obj.date() <= datetime.now().date()
    except ValueError:
        return False


def validate_club_id(club_id: str) -> bool:
    """
    Validate if the club ID exists in the valid clubs set.

    Args:
        club_id: Club ID to validate

    Returns:
        True if valid, False otherwise

    Examples:
        >>> validate_club_id("urawa-reds")
        True
        >>> validate_club_id("invalid-club")
        False
    """
    return club_id in VALID_CLUB_IDS


def validate_email(email: str) -> bool:
    """
    Validate email format using regex.

    Args:
        email: Email address to validate

    Returns:
        True if valid, False otherwise

    Examples:
        >>> validate_email("user@example.com")
        True
        >>> validate_email("invalid-email")
        False
    """
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    return bool(re.match(pattern, email))


def validate_password_strength(password: str) -> tuple[bool, str]:
    """
    Validate password strength.

    Args:
        password: Password to validate

    Returns:
        Tuple of (is_valid, error_message)

    Examples:
        >>> validate_password_strength("Test123!")
        (True, '')
        >>> validate_password_strength("weak")
        (False, 'Password must be at least 8 characters long')
    """
    if len(password) < MIN_PASSWORD_LENGTH:
        return False, f"Password must be at least {MIN_PASSWORD_LENGTH} characters long"

    if len(password) > MAX_PASSWORD_LENGTH:
        return False, f"Password must be less than {MAX_PASSWORD_LENGTH} characters"

    if not any(c.isupper() for c in password):
        return False, "Password must contain at least one uppercase letter"

    if not any(c.islower() for c in password):
        return False, "Password must contain at least one lowercase letter"

    if not any(c.isdigit() for c in password):
        return False, "Password must contain at least one digit"

    return True, ""


def validate_nickname(nickname: str) -> tuple[bool, str]:
    """
    Validate nickname format and length.

    Args:
        nickname: Nickname to validate

    Returns:
        Tuple of (is_valid, error_message)

    Examples:
        >>> validate_nickname("User123")
        (True, '')
        >>> validate_nickname("A")
        (False, 'Nickname must be between 2 and 50 characters')
    """
    if len(nickname) < MIN_NICKNAME_LENGTH:
        return False, f"Nickname must be between {MIN_NICKNAME_LENGTH} and {MAX_NICKNAME_LENGTH} characters"

    if len(nickname) > MAX_NICKNAME_LENGTH:
        return False, f"Nickname must be between {MIN_NICKNAME_LENGTH} and {MAX_NICKNAME_LENGTH} characters"

    # Allow alphanumeric, spaces, and common special characters
    pattern = r"^[a-zA-Z0-9\s\-_あ-んア-ン一-龥]+$"
    if not re.match(pattern, nickname):
        return False, "Nickname contains invalid characters"

    return True, ""


def validate_device_signature(signature: str) -> bool:
    """
    Validate device signature format.

    Args:
        signature: Device signature to validate

    Returns:
        True if valid, False otherwise
    """
    return MIN_DEVICE_SIGNATURE_LENGTH <= len(signature) <= MAX_DEVICE_SIGNATURE_LENGTH
