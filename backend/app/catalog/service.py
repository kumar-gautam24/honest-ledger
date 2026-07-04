"""Catalog rules. Reads are public; writes are admin-only (enforced at the router
via get_current_admin_id). Admin edits are authoritative — no LWW."""

import asyncpg

from app.catalog import repository
from app.catalog.schemas import (
    CatalogLenderPatch,
    CatalogLenderResponse,
    CatalogLenderUpsert,
)
from app.core.errors import NotFoundError


def row_to_response(row: asyncpg.Record) -> CatalogLenderResponse:
    return CatalogLenderResponse.model_validate(dict(row))


async def get_catalog(pool: asyncpg.Pool) -> tuple[list[asyncpg.Record], int]:
    rows = await repository.list_active(pool)
    version = await repository.get_version(pool)
    return rows, version


async def get_version(pool: asyncpg.Pool) -> int:
    return await repository.get_version(pool)


async def upsert_lender(
    pool: asyncpg.Pool, body: CatalogLenderUpsert
) -> asyncpg.Record:
    return await repository.upsert_lender(pool, body.model_dump())


async def patch_lender(
    pool: asyncpg.Pool, lender_id: str, body: CatalogLenderPatch
) -> asyncpg.Record:
    fields = body.model_dump(exclude_unset=True)
    if not fields:
        row = await repository.get_lender(pool, lender_id)
        if row is None or row["deleted_at"] is not None:
            raise NotFoundError("Catalog lender not found")
        return row
    row = await repository.update_lender(pool, lender_id, fields)
    if row is None:
        raise NotFoundError("Catalog lender not found")
    return row


async def delete_lender(pool: asyncpg.Pool, lender_id: str) -> None:
    outcome = await repository.tombstone_lender(pool, lender_id)
    if outcome is None:
        raise NotFoundError("Catalog lender not found")
    # "deleted" and "already" both end as 204: deletes are idempotent.
