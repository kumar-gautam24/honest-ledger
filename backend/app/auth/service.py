"""Auth business rules. Knows nothing about HTTP; SQL only via repository."""

import asyncpg

from app.auth import repository
from app.core.errors import EmailTakenError
from app.core.security import hash_password


async def register(pool: asyncpg.Pool, email: str, password: str) -> asyncpg.Record:
    try:
        return await repository.create_user(pool, email, hash_password(password))
    except asyncpg.UniqueViolationError:
        # Let the DB's unique index be the referee: checking first then inserting
        # would race against a concurrent register with the same email.
        raise EmailTakenError("An account with this email already exists")
