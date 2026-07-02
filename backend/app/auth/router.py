"""HTTP layer: parse request -> call service -> shape response. No business logic."""

import uuid

import asyncpg
from fastapi import APIRouter, Depends

from app.auth import repository, service
from app.auth.dependencies import get_current_user_id, get_pool
from app.auth.schemas import (
    LoginRequest,
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
