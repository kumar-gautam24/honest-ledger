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
