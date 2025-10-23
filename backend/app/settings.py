"""
Application configuration management.

This module handles environment variables and application settings using Pydantic Settings.
"""

import json
from typing import List, Union, Any
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field, model_validator


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Firebase Configuration
    FIREBASE_PROJECT_ID: str = Field(default="oshi-suta-battle")
    FIREBASE_CREDENTIALS_PATH: str = Field(default="./firebase-credentials.json")
    FIREBASE_WEB_API_KEY: str = Field(default="")  # Get from Firebase Console -> Project Settings -> Web API Key

    # Redis Configuration
    REDIS_HOST: str = Field(default="localhost")
    REDIS_PORT: int = Field(default=6379)
    REDIS_PASSWORD: str = Field(default="")
    REDIS_DB: int = Field(default=0)

    # Security
    SECRET_KEY: str = Field(default="your-secret-key-change-in-production")
    ALGORITHM: str = Field(default="HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30)

    # API Configuration
    API_V1_PREFIX: str = Field(default="/api/v1")
    PROJECT_NAME: str = Field(default="Oshi-Suta BATTLE API")
    VERSION: str = Field(default="0.1.0")

    # CORS Configuration (will be parsed from string in model_validator)
    CORS_ORIGINS: Any = Field(
        default=["http://localhost:3000", "http://localhost:8000", "http://127.0.0.1:3000", "http://127.0.0.1:8000"]
    )

    @model_validator(mode="before")
    @classmethod
    def parse_cors_origins(cls, values: dict) -> dict:
        """Parse CORS_ORIGINS from various formats."""
        cors = values.get("CORS_ORIGINS")
        if cors is None:
            return values

        if isinstance(cors, str):
            # Try to parse as JSON first
            try:
                parsed = json.loads(cors)
                values["CORS_ORIGINS"] = parsed if isinstance(parsed, list) else [parsed]
            except (json.JSONDecodeError, ValueError):
                # Otherwise, treat as comma-separated
                values["CORS_ORIGINS"] = [origin.strip() for origin in cors.split(",") if origin.strip()]
        elif not isinstance(cors, list):
            values["CORS_ORIGINS"] = [str(cors)]

        return values

    # Environment
    ENV: str = Field(default="development")
    DEBUG: bool = Field(default=True)

    model_config = SettingsConfigDict(
        env_file=None,  # Don't load .env file in Docker
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


# Global settings instance
settings = Settings()
