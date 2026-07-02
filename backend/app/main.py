"""FastAPI application entry point.

Exposes:
  GET /health  -> liveness  ("is the process up?")   — no dependencies
  GET /ready   -> readiness ("can it serve traffic?") — checks the DB

The app is built by a factory (`create_app`) so tests can build a fresh instance.
The asyncpg pool is opened on startup and closed on shutdown via a lifespan handler.
"""

from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from app.core import db
from app.core.config import get_settings
from app.core.errors import AppError
from app.core.logging import configure_logging, get_logger


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    configure_logging(settings.log_level)
    log = get_logger("app.lifespan")

    app.state.pool = await db.create_pool(settings.database_url)
    log.info("app.startup", env=settings.env)
    try:
        yield
    finally:
        await db.close_pool(app.state.pool)
        log.info("app.shutdown")


def create_app() -> FastAPI:
    # Disable the interactive API docs (Swagger /docs, ReDoc, and the OpenAPI schema)
    # in production so we don't publish a map of the whole API surface. On in dev.
    is_prod = get_settings().env == "production"
    if is_prod:
        docs_url = None
        redoc_url = None
        openapi_url = None
    else:
        docs_url = "/docs"
        redoc_url = "/redoc"
        openapi_url = "/openapi.json"

    app = FastAPI(
        title="recurring-backend",
        version="0.0.0",
        lifespan=lifespan,
        docs_url=docs_url,
        redoc_url=redoc_url,
        openapi_url=openapi_url,
    )

    @app.exception_handler(AppError)
    async def handle_app_error(request: Request, exc: AppError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": {"code": exc.code, "message": exc.message}},
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(
        request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        # Same envelope for bad request bodies, so clients parse ONE error shape.
        return JSONResponse(
            status_code=422,
            content={
                "error": {
                    "code": "validation_error",
                    "message": "Request body failed validation",
                    "details": exc.errors(),
                }
            },
        )

    @app.get("/health", tags=["ops"])
    async def health() -> dict[str, str]:
        # Liveness: intentionally does nothing but confirm the process responds.
        return {"status": "ok"}

    @app.get("/ready", tags=["ops"])
    async def ready() -> JSONResponse:
        # Readiness: only "ok" if the database is actually reachable.
        try:
            await db.ping(app.state.pool)
        except Exception:
            return JSONResponse(
                status_code=503, content={"status": "unavailable", "db": "down"}
            )
        return JSONResponse(status_code=200, content={"status": "ok", "db": "up"})

    return app


app = create_app()
