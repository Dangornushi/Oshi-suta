"""
FastAPI application entry point.

This module initializes and configures the FastAPI application.
"""

import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.settings import settings
from app.api.v1.router import api_router
from app.dependencies import initialize_firebase, initialize_redis, close_redis
from app.utils.error_handlers import AppError

# Configure logging
logging.basicConfig(
    level=logging.INFO if settings.DEBUG else logging.WARNING,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager.

    Handles startup and shutdown events.
    """
    # Startup
    logger.info("Starting Oshi-Suta BATTLE API...")

    try:
        # Initialize Firebase
        initialize_firebase()
        logger.info("Firebase initialized")
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {str(e)}")

    try:
        # Initialize Redis
        await initialize_redis()
        logger.info("Redis initialized")
    except Exception as e:
        logger.error(f"Failed to initialize Redis: {str(e)}")

    logger.info("Application startup complete")

    yield

    # Shutdown
    logger.info("Shutting down Oshi-Suta BATTLE API...")

    try:
        await close_redis()
        logger.info("Redis connection closed")
    except Exception as e:
        logger.error(f"Error closing Redis: {str(e)}")

    logger.info("Application shutdown complete")


# Create FastAPI application
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Backend API for Oshi-Suta BATTLE - J-League Supporter Fitness Gamification",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Exception handlers
@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    """カスタムエラーのグローバルハンドラー"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.message,
            "error_type": exc.__class__.__name__
        }
    )


@app.exception_handler(404)
async def not_found_handler(request, exc):
    """Handle 404 errors."""
    return JSONResponse(
        status_code=404,
        content={
            "error": "Not Found",
            "detail": "The requested resource was not found"
        }
    )


@app.exception_handler(500)
async def internal_server_error_handler(request, exc):
    """Handle 500 errors."""
    logger.error(f"Internal server error: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": "An unexpected error occurred"
        }
    )


# Include API router
app.include_router(
    api_router,
    prefix=settings.API_V1_PREFIX
)


# Root endpoint
@app.get("/")
async def root():
    """
    Root endpoint.

    Returns basic API information.
    """
    return {
        "name": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "running",
        "docs": "/docs",
        "health": f"{settings.API_V1_PREFIX}/health"
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG
    )
