"""HTTP layer: parse request -> call service -> shape response. No business logic."""

import asyncpg
from fastapi import APIRouter, Depends

from app.auth import service
from app.auth.dependencies import get_pool
from app.auth.schemas import RegisterRequest, UserResponse

auth_router = APIRouter(prefix="/v1/auth", tags=["auth"])
account_router = APIRouter(prefix="/v1", tags=["account"])


@auth_router.post("/register", status_code=201, response_model=UserResponse)
async def register(
    body: RegisterRequest, pool: asyncpg.Pool = Depends(get_pool)
) -> UserResponse:
    user = await service.register(pool, body.email, body.password)
    return UserResponse(id=user["id"], email=user["email"], created_at=user["created_at"])
