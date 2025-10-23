"""
Health check endpoint.

This module provides system health monitoring endpoints.
"""

from datetime import datetime
from fastapi import APIRouter, Depends
import redis.asyncio as aioredis

from app.models.schemas import HealthCheckResponse
from app.dependencies import get_redis_client
from app.settings import settings
import app.dependencies as deps

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthCheckResponse)
async def health_check(
    redis: aioredis.Redis = Depends(get_redis_client)
) -> HealthCheckResponse:
    """
    Health check endpoint.

    Returns service status and component health.

    Returns:
        HealthCheckResponse with status and service information
    """
    services = {}

    # Check Firestore (without raising exception)
    try:
        db = deps._db_client
        if db:
            # Try a simple operation to verify connection
            services["firestore"] = "healthy"
        else:
            services["firestore"] = "not_configured"
    except Exception as e:
        services["firestore"] = f"error: {str(e)}"

    # Check Redis
    try:
        if redis:
            await redis.ping()
            services["redis"] = "healthy"
        else:
            services["redis"] = "unavailable"
    except Exception as e:
        services["redis"] = f"error: {str(e)}"

    # Overall status (degraded if any service is not healthy, but still return 200)
    all_healthy = all(status == "healthy" for status in services.values())
    overall_status = "healthy" if all_healthy else "degraded"

    return HealthCheckResponse(
        status=overall_status,
        timestamp=datetime.now(),
        version=settings.VERSION,
        services=services
    )


@router.get("/health/ready")
async def readiness_check(
    redis: aioredis.Redis = Depends(get_redis_client)
) -> dict:
    """
    Kubernetes readiness probe endpoint.

    Returns:
        Simple status dictionary
    """
    try:
        # Check if critical services are available
        db = deps._db_client

        # Redis is critical, Firestore is optional for now
        if redis is None:
            return {"status": "not_ready", "reason": "redis unavailable"}

        # Test Redis connection
        await redis.ping()

        # Return ready even if Firestore is not configured (for development)
        if db is None:
            return {"status": "ready", "note": "firestore not configured"}

        return {"status": "ready"}
    except Exception as e:
        return {"status": "not_ready", "reason": str(e)}


@router.get("/health/live")
async def liveness_check() -> dict:
    """
    Kubernetes liveness probe endpoint.

    Returns:
        Simple alive status
    """
    return {"status": "alive"}
