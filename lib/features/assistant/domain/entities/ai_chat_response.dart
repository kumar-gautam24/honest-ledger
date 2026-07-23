import 'ai_message.dart';

/// Token accounting the provider reports back (best-effort; may be zero).
class AiUsage {
  const AiUsage({this.inputTokens = 0, this.outputTokens = 0});

  final int inputTokens;
  final int outputTokens;

  factory AiUsage.fromJson(Map<String, dynamic> j) => AiUsage(
        inputTokens: (j['input_tokens'] as int?) ?? 0,
        outputTokens: (j['output_tokens'] as int?) ?? 0,
      );
}

/// The assistant's reply for one turn: free text and/or tool calls to run.
class AiChatResponse {
  const AiChatResponse({
    this.text,
    this.toolCalls = const [],
    this.stopReason,
    this.usage,
  });

  final String? text;
  final List<AiToolCall> toolCalls;
  final String? stopReason;
  final AiUsage? usage;

  /// The model wants the client to run tools before it can answer.
  bool get hasToolCalls => toolCalls.isNotEmpty;

  factory AiChatResponse.fromJson(Map<String, dynamic> j) => AiChatResponse(
        text: j['text'] as String?,
        toolCalls: ((j['tool_calls'] as List?) ?? const [])
            .map((e) => AiToolCall.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        stopReason: j['stop_reason'] as String?,
        usage: j['usage'] == null
            ? null
            : AiUsage.fromJson((j['usage'] as Map).cast<String, dynamic>()),
      );
}
