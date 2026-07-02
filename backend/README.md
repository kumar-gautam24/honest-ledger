# recurring-backend

FastAPI + Postgres backend for the `recurring` app. See the design & learning docs in
[`../docs/backend/`](../docs/backend/).

## Quickstart (local dev)

Requires Docker Desktop running.

```bash
cd backend
cp .env.example .env          # defaults are fine for local dev
docker compose up --build     # builds the api image, starts Postgres + api
```

- Liveness:  `curl localhost:8000/health`  → `{"status":"ok"}`
- Readiness: `curl localhost:8000/ready`   → `{"status":"ok","db":"up"}`
- API docs:  http://localhost:8000/docs

## API (B1)

All under `/v1`. Errors always use `{"error": {"code", "message"}}`. Auth endpoints
are rate limited (10/min per IP by default).

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/v1/auth/register` | — | create account (201) |
| POST | `/v1/auth/login` | — | access JWT (15 min) + refresh token (30 d) |
| POST | `/v1/auth/refresh` | — | rotate refresh token, new pair |
| POST | `/v1/auth/logout` | — | revoke refresh token (204) |
| GET | `/v1/me` | Bearer | current user |
| POST | `/v1/me/change-password` | Bearer | change password, revoke all sessions (204) |
| DELETE | `/v1/me` | Bearer | delete account + data (204) |

```bash
curl -s -X POST localhost:8000/v1/auth/register -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"longenough1"}'
curl -s -X POST localhost:8000/v1/auth/login -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"longenough1"}'
```

## Tests

```bash
docker compose up -d db   # integration tests use a real recurring_test database
uv run pytest
```

Migrations run automatically on container start (see `entrypoint.sh`). To run them by
hand against the running DB:

```bash
docker compose exec api yoyo apply --database "$DATABASE_URL" --batch ./migrations
```

Stop the stack: `docker compose down` (add `-v` to also wipe the database volume).

## Layout

```
app/          FastAPI app (config, db pool, logging, routes)
migrations/   hand-written SQL migrations (applied by yoyo)
Dockerfile    dev image (uv-based)
docker-compose.yml   postgres + api
```
