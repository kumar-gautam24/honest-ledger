/// Wire types for the AI chat protocol (mirrors backend `app/ai/schemas.py`).
///
/// The client orchestrates the tool-calling loop, so it owns the full message
/// history and re-sends it each turn. These types are the transport shape sent to
/// (and echoed back from) `/v1/ai/chat`; the richer UI message model lives in the
/// presentation layer.
library;

/// Who a turn is from. `tool` turns carry the result of a tool the client ran.
enum AiRole { system, user, assistant, tool }

/// A model's request to run one tool, with already-parsed arguments.
class AiToolCall {
  const AiToolCall({
    required this.id,
    required this.name,
    this.arguments = const <String, dynamic>{},
  });

  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  factory AiToolCall.fromJson(Map<String, dynamic> j) => AiToolCall(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        arguments:
            (j['arguments'] as Map?)?.cast<String, dynamic>() ?? const {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'arguments': arguments,
      };
}

/// One conversation turn on the wire.
class AiChatMessage {
  const AiChatMessage({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
  });

  /// A plain user turn.
  const AiChatMessage.user(this.content)
      : role = AiRole.user,
        toolCalls = null,
        toolCallId = null;

  /// An assistant turn, optionally requesting tool calls.
  const AiChatMessage.assistant(this.content, {this.toolCalls})
      : role = AiRole.assistant,
        toolCallId = null;

  /// The result of running a tool the assistant asked for.
  const AiChatMessage.toolResult({
    required this.toolCallId,
    required this.content,
  })  : role = AiRole.tool,
        toolCalls = null;

  const AiChatMessage._({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
  });

  final AiRole role;
  final String? content;
  final List<AiToolCall>? toolCalls;
  final String? toolCallId;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        if (content != null) 'content': content,
        if (toolCalls != null && toolCalls!.isNotEmpty)
          'tool_calls': toolCalls!.map((c) => c.toJson()).toList(),
        if (toolCallId != null) 'tool_call_id': toolCallId,
      };

  /// Rebuilds a turn from its [toJson] shape — used to rehydrate persisted
  /// conversation history so a reopened chat keeps its full context.
  factory AiChatMessage.fromJson(Map<String, dynamic> j) => AiChatMessage._(
        role: AiRole.values.firstWhere(
          (r) => r.name == j['role'],
          orElse: () => AiRole.user,
        ),
        content: j['content'] as String?,
        toolCalls: (j['tool_calls'] as List?)
            ?.map((e) => AiToolCall.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        toolCallId: j['tool_call_id'] as String?,
      );
}

/// A tool the model may call. [parameters] is a JSON-Schema object.
class AiToolDef {
  const AiToolDef({
    required this.name,
    this.description = '',
    this.parameters = const {'type': 'object', 'properties': <String, dynamic>{}},
  });

  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'parameters': parameters,
      };
}
