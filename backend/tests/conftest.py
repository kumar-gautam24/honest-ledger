"""Shared test fixtures.

Integration tests run against a REAL Postgres (the compose `db` service),
in a dedicated `recurring_test` database so dev data is never touched.
Run `docker compose up -d db` before `uv run pytest`.

Pure unit tests (security, rate limiter, app setup) never request `pool`,
so they run with no database at all.
"""

import os

import asyncpg
import httpx
import pytest
from yoyo import get_backend, read_migrations

from app.main import create_app

TEST_DATABASE_URL = os.environ.get(
    "TEST_DATABASE_URL",
    "postgresql://recurring:recurring@localhost:5432/recurring_test",
)
ADMIN_DATABASE_URL = os.environ.get(
    "ADMIN_DATABASE_URL",
    "postgresql://recurring:recurring@localhost:5432/recurring",
)


@pytest.fixture(scope="session")
async def session_pool():
    """Created once per test run: test DB exists, migrated, pooled."""
    # 1. Ensure the test database exists (CREATE DATABASE can't be parameterized;
    #    the name is a constant, not user input).
    admin = await asyncpg.connect(ADMIN_DATABASE_URL)
    exists = await admin.fetchval(
        "SELECT 1 FROM pg_database WHERE datname = 'recurring_test'"
    )
    if not exists:
        await admin.execute("CREATE DATABASE recurring_test")
    await admin.close()

    # 2. Bring its schema up to date with the same migrations prod uses.
    backend = get_backend(TEST_DATABASE_URL)
    migrations = read_migrations("migrations")
    with backend.lock():
        backend.apply_migrations(backend.to_apply(migrations))

    # 3. Hand tests a pool.
    pool = await asyncpg.create_pool(TEST_DATABASE_URL, min_size=1, max_size=5)
    yield pool
    await pool.close()


@pytest.fixture
async def pool(session_pool):
    """Per-test view of the pool: tables are emptied first, so every test
    starts from a clean, migrated database."""
    await session_pool.execute("TRUNCATE users CASCADE")
    return session_pool


@pytest.fixture
async def client(pool):
    app = create_app()
    app.state.pool = pool  # inject instead of running the lifespan
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


async def _register_and_login(client, email: str) -> dict:
    credentials = {"email": email, "password": "longenough1"}
    await client.post("/v1/auth/register", json=credentials)
    response = await client.post("/v1/auth/login", json=credentials)
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


@pytest.fixture
async def auth_headers(client):
    return await _register_and_login(client, "sync@example.com")


@pytest.fixture
async def other_auth_headers(client):
    return await _register_and_login(client, "other@example.com")


@pytest.fixture
async def admin_auth_headers(client, pool):
    """A logged-in user promoted to admin (catalog write access)."""
    email = "admin@example.com"
    credentials = {"email": email, "password": "longenough1"}
    await client.post("/v1/auth/register", json=credentials)
    await pool.execute("UPDATE users SET is_admin = true WHERE email = $1", email)
    response = await client.post("/v1/auth/login", json=credentials)
    return {"Authorization": f"Bearer {response.json()['access_token']}"}
