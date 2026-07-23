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

    # CORS: comma-separated allowed origins for browser clients. "*" (dev default)
    # allows any origin — fine because we authenticate with a bearer token, not
    # cookies. In production set this to your app's exact origin(s).
    cors_allow_origins: str = "*"

    # AI assistant (/v1/ai/chat). The provider key lives ONLY here on the server —
    # never in the client. `fake` (default) is a deterministic no-network stub so
    # the app runs with no key; set `anthropic` + a key to use a real model.
    llm_provider: Literal["fake", "anthropic"] = "fake"
    llm_api_key: str = ""
    llm_model: str = "claude-3-5-haiku-latest"
    # Per-user throttle on the shared paid key (defends the wallet, not just abuse).
    ai_rate_limit_max_requests: int = 30
    ai_rate_limit_window_seconds: int = 60

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.cors_allow_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    """Cached accessor so we build Settings once per process."""
    return Settings()
