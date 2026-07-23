"""LLM provider adapters behind one small interface.

The proxy is provider-agnostic: `LlmProvider.chat` takes our normalized
`ChatRequest` and returns a normalized `ChatResponse`. Swapping Gemini/Claude/etc.
is a config change (`LLM_PROVIDER` + `LLM_API_KEY` + `LLM_MODEL`), not a code change
at the call site.

The default is `FakeProvider` — deterministic, no network, no key — so the app runs
and the full request/response contract is testable before any real model is wired.
"""

from __future__ import annotations

from typing import Any, Protocol

import httpx

from app.ai.schemas import ChatRequest, ChatResponse, ToolCall, Usage
from app.core.config import Settings
from app.core.errors import AppError


class ProviderError(AppError):
    """Upstream model call failed or the provider isn't configured."""

    status_code = 502
    code = "ai_provider_error"


class LlmProvider(Protocol):
    async def chat(self, request: ChatRequest) -> ChatResponse: ...


class FakeProvider:
    """Deterministic stand-in used in dev/tests. Echoes the latest user turn so the
    proxy contract can be exercised end-to-end without a real model or API key."""

    async def chat(self, request: ChatRequest) -> ChatResponse:
        last_user = next(
            (m for m in reversed(request.messages) if m.role == "user"), None
        )
        said = (last_user.content if last_user else "") or ""
        return ChatResponse(
            text=f"(fake model) You said: {said}",
            tool_calls=[],
            stop_reason="end_turn",
            usage=Usage(),
        )


class AnthropicProvider:
    """Adapter for Anthropic's Messages API (tool use). Only reached when
    LLM_PROVIDER=anthropic and a key is set."""

    _URL = "https://api.anthropic.com/v1/messages"
    _VERSION = "2023-06-01"

    def __init__(self, api_key: str, model: str):
        self._api_key = api_key
        self._model = model

    async def chat(self, request: ChatRequest) -> ChatResponse:
        payload = _to_anthropic(request, self._model)
        try:
            async with httpx.AsyncClient(timeout=60.0) as http:
                resp = await http.post(
                    self._URL,
                    headers={
                        "x-api-key": self._api_key,
                        "anthropic-version": self._VERSION,
                        "content-type": "application/json",
                    },
                    json=payload,
                )
        except httpx.HTTPError as exc:
            raise ProviderError("Could not reach the AI provider") from exc

        if resp.status_code >= 400:
            # Don't leak the upstream body (may echo the key/prompt); log-friendly code only.
            raise ProviderError(
                "AI provider returned an error",
                details={"upstream_status": resp.status_code},
            )
        return _from_anthropic(resp.json())


def get_provider(settings: Settings) -> LlmProvider:
    """Pick the provider from config. Unknown/unconfigured -> FakeProvider, so a
    missing key degrades to a safe no-network stub instead of a 500."""
    if settings.llm_provider == "anthropic":
        if not settings.llm_api_key:
            raise ProviderError("AI provider 'anthropic' has no API key configured")
        return AnthropicProvider(settings.llm_api_key, settings.llm_model)
    return FakeProvider()


# --- Anthropic mapping -------------------------------------------------------


def _to_anthropic(request: ChatRequest, model: str) -> dict[str, Any]:
    """Normalized request -> Anthropic Messages body.

    Anthropic only knows user/assistant roles; tool calls are `tool_use` content
    blocks on an assistant turn and tool results are `tool_result` blocks on a
    following user turn. Consecutive tool results are merged into one user turn,
    which the API requires.
    """
    system_parts: list[str] = []
    if request.system:
        system_parts.append(request.system)

    messages: list[dict[str, Any]] = []
    for msg in request.messages:
        if msg.role == "system":
            if msg.content:
                system_parts.append(msg.content)
        elif msg.role == "user":
            messages.append({"role": "user", "content": msg.content or ""})
        elif msg.role == "assistant":
            blocks: list[dict[str, Any]] = []
            if msg.content:
                blocks.append({"type": "text", "text": msg.content})
            for call in msg.tool_calls or []:
                blocks.append(
                    {
                        "type": "tool_use",
                        "id": call.id,
                        "name": call.name,
                        "input": call.arguments,
                    }
                )
            messages.append({"role": "assistant", "content": blocks})
        elif msg.role == "tool":
            block = {
                "type": "tool_result",
                "tool_use_id": msg.tool_call_id or "",
                "content": msg.content or "",
            }
            # Merge into the previous user turn if it, too, is tool results.
            if (
                messages
                and messages[-1]["role"] == "user"
                and isinstance(messages[-1]["content"], list)
            ):
                messages[-1]["content"].append(block)
            else:
                messages.append({"role": "user", "content": [block]})

    body: dict[str, Any] = {
        "model": model,
        "max_tokens": request.max_tokens,
        "messages": messages,
    }
    if system_parts:
        body["system"] = "\n\n".join(system_parts)
    if request.tools:
        body["tools"] = [
            {
                "name": t.name,
                "description": t.description,
                "input_schema": t.parameters or {"type": "object", "properties": {}},
            }
            for t in request.tools
        ]
    return body


def _from_anthropic(data: dict[str, Any]) -> ChatResponse:
    """Anthropic Messages response -> normalized ChatResponse."""
    text_parts: list[str] = []
    tool_calls: list[ToolCall] = []
    for block in data.get("content", []):
        btype = block.get("type")
        if btype == "text":
            text_parts.append(block.get("text", ""))
        elif btype == "tool_use":
            tool_calls.append(
                ToolCall(
                    id=block.get("id", ""),
                    name=block.get("name", ""),
                    arguments=block.get("input", {}) or {},
                )
            )
    usage_raw = data.get("usage") or {}
    return ChatResponse(
        text="".join(text_parts) or None,
        tool_calls=tool_calls,
        stop_reason=data.get("stop_reason"),
        usage=Usage(
            input_tokens=usage_raw.get("input_tokens", 0),
            output_tokens=usage_raw.get("output_tokens", 0),
        ),
    )
