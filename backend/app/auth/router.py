"""HTTP layer: parse request -> call service -> shape response. No business logic."""

import asyncpg
from fastapi import APIRouter, Depends

from app.auth import service
from app.auth.dependencies import get_pool
from app.auth.schemas import (
    LoginRequest,
    RegisterRequest,
    TokenPairResponse,
    UserResponse,
)
from app.core.config import Settings, get_settings

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
