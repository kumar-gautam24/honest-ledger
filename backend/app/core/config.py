"""Typed application configuration, loaded from environment variables.

12-factor principle: all config comes from the environment, not from code. This makes
the same built image run in dev and prod unchanged — only the env differs. pydantic
validates and coerces the values, so a missing/invalid setting fails loudly at startup
instead of blowing up mid-request.
"""

from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # `.env` is read for local dev; real deployments inject real env vars.
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    env: Literal["development", "production"] = "development"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"

    # Connection string shared by the app (asyncpg) and yoyo (migrations).
    database_url: str = "postgresql://recurring:recurring@db:5432/recurring"

    # Signs JWT access tokens. HS256 needs >= 32 bytes of key material; this
    # dev default satisfies that but MUST be replaced outside local dev
    # (openssl rand -hex 32).
    jwt_secret: str = "dev-only-change-me-0123456789abcdef-0123456789"

    # Auth (B1)
    access_token_ttl_minutes: int = 15
    refresh_token_ttl_days: int = 30
    auth_rate_limit_max_requests: int = 10
    auth_rate_limit_window_seconds: int = 60


@lru_cache
def get_settings() -> Settings:
    """Cached accessor so we build Settings once per process."""
    return Settings()
