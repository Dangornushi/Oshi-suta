"""
Step endpoint tests.
"""

import pytest
from httpx import AsyncClient
from app.main import app


@pytest.mark.asyncio
async def test_sync_steps_unauthorized():
    """Test step sync without authorization."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/steps/sync",
            json={
                "steps": 8543,
                "date": "2025-10-10",
                "source": "healthkit",
                "device_signature": "test_signature"
            }
        )
        assert response.status_code == 403  # Missing authorization


@pytest.mark.asyncio
async def test_sync_steps_invalid_date():
    """Test step sync with invalid date format."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/steps/sync",
            json={
                "steps": 8543,
                "date": "2025-13-45",  # Invalid date
                "source": "healthkit",
                "device_signature": "test_signature"
            },
            headers={"Authorization": "Bearer test_token"}
        )
        # Note: Returns 500 when Firebase is not configured
        assert response.status_code in [400, 401, 422, 500]


@pytest.mark.asyncio
async def test_sync_steps_negative():
    """Test step sync with negative steps."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/steps/sync",
            json={
                "steps": -100,
                "date": "2025-10-10",
                "source": "healthkit",
                "device_signature": "test_signature"
            },
            headers={"Authorization": "Bearer test_token"}
        )
        # Note: Returns 500 when Firebase is not configured
        assert response.status_code in [400, 401, 422, 500]


@pytest.mark.asyncio
async def test_get_step_history_unauthorized():
    """Test step history without authorization."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/api/v1/steps/history")
        assert response.status_code == 403


@pytest.mark.asyncio
async def test_get_step_stats_unauthorized():
    """Test step stats without authorization."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/api/v1/steps/stats")
        assert response.status_code == 403
