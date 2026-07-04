"""HTTP layer for the global lender catalog.

Reads are PUBLIC (no auth) — the catalog is non-sensitive reference data the app
needs. Writes require an admin (get_current_admin_id) so you can tune the catalog
live without shipping a new app build.
"""

import uuid

import asyncpg
from fastapi import APIRouter, Depends

from app.catalog import service
from app.catalog.schemas import (
    CatalogLenderPatch,
    CatalogLenderResponse,
    CatalogLenderUpsert,
    CatalogResponse,
    CatalogVersionResponse,
)
from app.core.dependencies import get_current_admin_id, get_pool

catalog_router = APIRouter(prefix="/v1/catalog", tags=["catalog"])


@catalog_router.get("/lenders", response_model=CatalogResponse)
async def get_catalog(
    pool: asyncpg.Pool = Depends(get_pool),
) -> CatalogResponse:
    rows, version = await service.get_catalog(pool)
    return CatalogResponse(
        version=version,
        items=[service.row_to_response(row) for row in rows],
    )


@catalog_router.get("/version", response_model=CatalogVersionResponse)
async def get_catalog_version(
    pool: asyncpg.Pool = Depends(get_pool),
) -> CatalogVersionResponse:
    return CatalogVersionResponse(version=await service.get_version(pool))


@catalog_router.post("/lenders", response_model=CatalogLenderResponse)
async def upsert_catalog_lender(
    body: CatalogLenderUpsert,
    admin_id: uuid.UUID = Depends(get_current_admin_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> CatalogLenderResponse:
    row = await service.upsert_lender(pool, body)
    return service.row_to_response(row)


@catalog_router.patch("/lenders/{lender_id}", response_model=CatalogLenderResponse)
async def patch_catalog_lender(
    lender_id: str,
    body: CatalogLenderPatch,
    admin_id: uuid.UUID = Depends(get_current_admin_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> CatalogLenderResponse:
    row = await service.patch_lender(pool, lender_id, body)
    return service.row_to_response(row)


@catalog_router.delete("/lenders/{lender_id}", status_code=204)
async def delete_catalog_lender(
    lender_id: str,
    admin_id: uuid.UUID = Depends(get_current_admin_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_lender(pool, lender_id)
