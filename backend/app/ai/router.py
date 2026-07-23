"""HTTP layer for the AI assistant proxy.

Stateless, auth-gated pass-through: hold the provider key server-side, forward one
normalized chat turn to the configured model, return its reply. The tool-calling
loop itself runs on the client.
"""

import uuid

from fastapi import APIRouter, Depends

from app.ai.dependencies import check_ai_rate_limit
from app.ai.provider import get_provider
from app.ai.schemas import ChatRequest, ChatResponse
from app.core.config import Settings, get_settings

ai_router = APIRouter(prefix="/v1/ai", tags=["ai"])


@ai_router.post("/chat", response_model=ChatResponse)
async def chat(
    body: ChatRequest,
    # Depends chain: get_current_user_id (auth) -> per-user rate limit.
    _user_id: uuid.UUID = Depends(check_ai_rate_limit),
    settings: Settings = Depends(get_settings),
) -> ChatResponse:
    provider = get_provider(settings)
    return await provider.chat(body)
