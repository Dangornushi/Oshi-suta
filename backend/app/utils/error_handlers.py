"""
共通エラーハンドリングユーティリティ
"""

import logging
from functools import wraps
from typing import Callable, Any
from fastapi import HTTPException, status

logger = logging.getLogger(__name__)


class AppError(Exception):
    """アプリケーション基底エラー"""
    def __init__(self, message: str, status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


class ValidationError(AppError):
    """バリデーションエラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_400_BAD_REQUEST)


class NotFoundError(AppError):
    """リソース未発見エラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_404_NOT_FOUND)


class UnauthorizedError(AppError):
    """認証エラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_401_UNAUTHORIZED)


class ForbiddenError(AppError):
    """認可エラー"""
    def __init__(self, message: str):
        super().__init__(message, status.HTTP_403_FORBIDDEN)


def handle_exceptions(operation_name: str = "Operation"):
    """
    エンドポイント共通のエラーハンドリングデコレータ

    使用例:
        @router.post("/register")
        @handle_exceptions("User registration")
        async def register(request: UserRegisterRequest):
            # ビジネスロジック
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def wrapper(*args, **kwargs) -> Any:
            try:
                return await func(*args, **kwargs)
            except HTTPException:
                # FastAPIのHTTPExceptionはそのまま再送出
                raise
            except AppError as e:
                # カスタムエラーをHTTPExceptionに変換
                logger.warning(f"{operation_name} failed: {e.message}")
                raise HTTPException(
                    status_code=e.status_code,
                    detail=e.message
                )
            except ValueError as e:
                # バリデーションエラー
                logger.warning(f"{operation_name} validation error: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(e)
                )
            except Exception as e:
                # 予期しないエラー
                logger.error(f"{operation_name} unexpected error: {str(e)}", exc_info=True)
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"{operation_name} failed"
                )
        return wrapper
    return decorator


def validate_and_raise(condition: bool, error_message: str, error_class: type[AppError] = ValidationError):
    """
    条件チェック＆エラー送出ヘルパー

    使用例:
        validate_and_raise(
            validate_club_id(club_id),
            f"Invalid club ID: {club_id}"
        )
    """
    if not condition:
        raise error_class(error_message)
