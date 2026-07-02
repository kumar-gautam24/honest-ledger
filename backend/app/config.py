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

    # Used from B1 onward to sign JWTs. Present now so the shape is stable.
    jwt_secret: str = "dev-only-change-me"


@lru_cache
def get_settings() -> Settings:
    """Cached accessor so we build Settings once per process."""
    return Settings()
