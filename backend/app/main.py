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

from app.auth.router import account_router, auth_router
from app.borrowings.router import borrowings_router, repayments_router
from app.cards.router import cards_router, statements_router
from app.catalog.router import catalog_router
from app.lenders.router import lenders_router
from app.recurring.router import recurring_router
from app.settings.router import settings_router
from app.summary.router import summary_router
from app.sync.router import sync_router
from app.core import db
from app.core.config import get_settings
from app.core.errors import AppError
from app.core.logging import configure_logging, get_logger
from app.core.rate_limit import SlidingWindowRateLimiter


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
    settings = get_settings()

    # Disable the interactive API docs (Swagger /docs, ReDoc, and the OpenAPI schema)
    # in production so we don't publish a map of the whole API surface. On in dev.
    is_prod = settings.env == "production"
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
        error_body = {"code": exc.code, "message": exc.message}
        if exc.details is not None:
            error_body["details"] = exc.details
        return JSONResponse(status_code=exc.status_code, content={"error": error_body})

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

    # One limiter instance per app process, shared by all auth routes.
    app.state.auth_limiter = SlidingWindowRateLimiter(
        max_requests=settings.auth_rate_limit_max_requests,
        window_seconds=settings.auth_rate_limit_window_seconds,
    )

    app.include_router(auth_router)
    app.include_router(account_router)
    app.include_router(borrowings_router)
    app.include_router(repayments_router)
    app.include_router(lenders_router)
    app.include_router(recurring_router)
    app.include_router(cards_router)
    app.include_router(statements_router)
    app.include_router(summary_router)
    app.include_router(catalog_router)
    app.include_router(settings_router)
    app.include_router(sync_router)

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
