"""Provider-agnostic chat shapes for the /v1/ai/chat proxy.

The CLIENT orchestrates the tool-calling loop, so this endpoint is stateless: the
client sends the full message history + tool schemas on every turn, and we forward
to whichever provider is configured and return the assistant's reply (text and/or
tool calls). The client executes tools locally and sends the results back as `tool`
messages on the next turn. Nothing here is persisted.
"""

from typing import Any, Literal

from pydantic import BaseModel, Field


class ToolCall(BaseModel):
    """A model's request to run one tool, with parsed arguments."""

    id: str
    name: str = Field(min_length=1, max_length=64)
    arguments: dict[str, Any] = Field(default_factory=dict)


class ChatMessage(BaseModel):
    """One turn. `assistant` turns may carry `tool_calls`; `tool` turns carry a
    result plus the `tool_call_id` they answer."""

    role: Literal["system", "user", "assistant", "tool"]
    content: str | None = Field(default=None, max_length=100_000)
    tool_calls: list[ToolCall] | None = None
    tool_call_id: str | None = None


class ToolDef(BaseModel):
    """A tool the model may call. `parameters` is a JSON Schema object."""

    name: str = Field(min_length=1, max_length=64)
    description: str = Field(default="", max_length=4000)
    parameters: dict[str, Any] = Field(default_factory=dict)


class ChatRequest(BaseModel):
    # Bounded so a malformed/abusive client can't push an unbounded prompt at the
    # paid provider key.
    messages: list[ChatMessage] = Field(min_length=1, max_length=200)
    tools: list[ToolDef] = Field(default_factory=list, max_length=64)
    system: str | None = Field(default=None, max_length=40_000)
    max_tokens: int = Field(default=1024, ge=1, le=4096)


class Usage(BaseModel):
    input_tokens: int = 0
    output_tokens: int = 0


class ChatResponse(BaseModel):
    text: str | None = None
    tool_calls: list[ToolCall] = Field(default_factory=list)
    stop_reason: str | None = None
    usage: Usage | None = None
