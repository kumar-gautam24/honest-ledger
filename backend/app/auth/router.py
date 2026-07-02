"""HTTP layer: parse request -> call service -> shape response. No business logic."""

import uuid

import asyncpg
from fastapi import APIRouter, Depends

from app.auth import repository, service
from app.auth.dependencies import get_current_user_id, get_pool
from app.auth.schemas import (
    ChangePasswordRequest,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    TokenPairResponse,
    UserResponse,
)
from app.core.config import Settings, get_settings
from app.core.errors import InvalidTokenError

auth_router = APIRouter(prefix="/v1/auth", tags=["auth"])
account_router = APIRouter(prefix="/v1", tags=["account"])


@auth_router.post("/register", status_code=201, response_model=UserResponse)
async def register(
    body: RegisterRequest, pool: asyncpg.Pool = Depends(get_pool)
) -> UserResponse:
    user = await service.register(pool, body.email, body.password)
    return UserResponse(id=user["id"], email=user["email"], created_at=user["created_at"])


@auth_router.post("/login", response_model=TokenPairResponse)
async def login(
    body: LoginRequest,
    pool: asyncpg.Pool = Depends(get_pool),
    settings: Settings = Depends(get_settings),
) -> TokenPairResponse:
    access_token, refresh_token = await service.login(
        pool, settings, body.email, body.password
    )
    return TokenPairResponse(access_token=access_token, refresh_token=refresh_token)


@auth_router.post("/refresh", response_model=TokenPairResponse)
async def refresh(
    body: RefreshRequest,
    pool: asyncpg.Pool = Depends(get_pool),
    settings: Settings = Depends(get_settings),
) -> TokenPairResponse:
    access_token, refresh_token = await service.refresh(
        pool, settings, body.refresh_token
    )
    return TokenPairResponse(access_token=access_token, refresh_token=refresh_token)


@auth_router.post("/logout", status_code=204)
async def logout(body: RefreshRequest, pool: asyncpg.Pool = Depends(get_pool)) -> None:
    await service.logout(pool, body.refresh_token)


@account_router.get("/me", response_model=UserResponse)
async def me(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> UserResponse:
    user = await repository.get_user_by_id(pool, user_id)
    if user is None:
        # Valid signature but the account is gone (deleted) -> token is dead.
        raise InvalidTokenError("Account no longer exists")
    return UserResponse(id=user["id"], email=user["email"], created_at=user["created_at"])


@account_router.post("/me/change-password", status_code=204)
async def change_password(
    body: ChangePasswordRequest,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.change_password(
        pool, user_id, body.current_password, body.new_password
    )


@account_router.delete("/me", status_code=204)
async def delete_account(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_account(pool, user_id)
