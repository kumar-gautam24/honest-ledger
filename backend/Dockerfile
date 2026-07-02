# Dev image for the FastAPI backend.
# We use uv to install dependencies fast and reproducibly (from uv.lock).
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# uv: a single static binary copied from the official image.
COPY --from=ghcr.io/astral-sh/uv:0.11 /uv /uvx /bin/

WORKDIR /app

# Install deps first (cached layer) using only the manifest + lock.
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# uv installs into a project virtualenv; put it on PATH so `uvicorn`/`yoyo` resolve.
ENV PATH="/app/.venv/bin:$PATH"

# App source, migrations, entrypoint.
COPY . .
RUN chmod +x entrypoint.sh

EXPOSE 8000
CMD ["bash", "entrypoint.sh"]
