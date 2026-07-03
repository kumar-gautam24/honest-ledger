"""App assembly: error envelope shape and prod/dev docs toggling."""

import httpx
import pytest

from app.core.config import get_settings
from app.core.errors import AppError
from app.main import create_app


class TeapotError(AppError):
    status_code = 418
    code = "teapot"


@pytest.fixture
def fresh_settings(monkeypatch):
    get_settings.cache_clear()
    yield monkeypatch
    get_settings.cache_clear()


async def test_app_error_becomes_error_envelope():
    app = create_app()

    @app.get("/boom")
    async def boom():
        raise TeapotError("short and stout")

    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/boom")

    assert response.status_code == 418
    assert response.json() == {"error": {"code": "teapot", "message": "short and stout"}}


async def test_app_error_details_are_included():
    app = create_app()

    class DetailedError(AppError):
        status_code = 409
        code = "detailed"

    @app.get("/detail-boom")
    async def detail_boom():
        raise DetailedError("conflict", details={"current": {"x": 1}})

    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as c:
        response = await c.get("/detail-boom")

    assert response.status_code == 409
    assert response.json()["error"]["details"] == {"current": {"x": 1}}


async def test_docs_disabled_in_production(fresh_settings):
    fresh_settings.setenv("ENV", "production")
    app = create_app()
    assert app.docs_url is None
    assert app.openapi_url is None


async def test_docs_enabled_in_development(fresh_settings):
    fresh_settings.setenv("ENV", "development")
    app = create_app()
    assert app.docs_url == "/docs"
