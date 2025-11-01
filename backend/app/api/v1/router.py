"""
API v1 router.

This module aggregates all v1 API endpoints.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import health, auth, steps, clubs, players, matches

# Create main API v1 router
api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(steps.router)
api_router.include_router(clubs.router)
api_router.include_router(players.router)
api_router.include_router(matches.router)
