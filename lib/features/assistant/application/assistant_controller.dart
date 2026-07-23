import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/injector.dart';
import '../data/ai_service.dart';
import '../domain/entities/ai_message.dart';
import '../domain/entities/proposed_action.dart';
import 'assistant_prompt.dart';
import 'assistant_state.dart';
import 'tool_catalog.dart';
import 'tool_executor.dart';

part 'assistant_controller.g.dart';

/// Drives the client-side tool-calling loop.
///
/// Each `send` re-sends the whole conversation + tool schemas to the backend
/// proxy. When the model asks for a (read) tool, we run it locally, feed the
/// result back, and loop until the model answers in plain text or we hit the
/// iteration cap. The provider key never touches the client — only the proxy
/// does (see [AiService]).
@riverpod
class AssistantController extends _$AssistantController {
  /// Guards against a runaway read→call→read loop.
  static const _maxIterations = 6;

  @override
  AssistantState build() => const AssistantState();

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isBusy || state.pending != null) return;

    final entries = [
      ...state.entries,
      _entry(ChatRole.user, trimmed),
    ];
    final wire = [...state.wire, AiChatMessage.user(trimmed)];
    state = state.copyWith(
      entries: entries,
      wire: wire,
      isBusy: true,
      clearError: true,
    );
    await _run();
  }

  /// Retry after an error without re-sending a new user message.
  Future<void> retry() async {
    if (state.isBusy || state.wire.isEmpty || state.pending != null) return;
    state = state.copyWith(isBusy: true, clearError: true);
    await _run();
  }

  /// User approved the pending write (with any edits from the confirm card).
  Future<void> confirm(Map<String, String> edited) async {
    final action = state.pending;
    if (action == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearPending: true, clearError: true);

    final executor = ToolExecutor(ref);
    String result;
    try {
      result = await executor.execute(action, edited);
      _append(_entry(ChatRole.status, 'Saved.'), state.wire);
    } catch (_) {
      // Keep the wire valid (the tool call must be answered) and surface an error.
      result = '{"status":"error","note":"Save failed."}';
      state = state.copyWith(error: 'Could not save. Please try again.');
    }
    final wire = [
      ...state.wire,
      AiChatMessage.toolResult(toolCallId: action.toolCallId, content: result),
    ];
    state = state.copyWith(wire: wire);
    await _run();
  }

  /// User declined the pending write.
  Future<void> cancel() async {
    final action = state.pending;
    if (action == null) return;
    final wire = [
      ...state.wire,
      AiChatMessage.toolResult(
        toolCallId: action.toolCallId,
        content: '{"status":"declined","note":"User declined the change."}',
      ),
    ];
    state = state.copyWith(clearPending: true, isBusy: true, wire: wire);
    _append(_entry(ChatRole.status, 'Cancelled.'), wire);
    await _run();
  }

  Future<void> _run() async {
    final service = sl<AiService>();
    final executor = ToolExecutor(ref);
    var wire = state.wire;

    try {
      for (var i = 0; i < _maxIterations; i++) {
        final res = await service.chat(
          system: assistantSystemPrompt,
          messages: wire,
          tools: kAllTools,
        );

        wire = [
          ...wire,
          AiChatMessage.assistant(
            res.text,
            toolCalls: res.hasToolCalls ? res.toolCalls : null,
          ),
        ];

        final answer = res.text?.trim() ?? '';
        if (answer.isNotEmpty) {
          _append(_entry(ChatRole.assistant, answer), wire);
        }

        if (!res.hasToolCalls) {
          state = state.copyWith(wire: wire, isBusy: false);
          return;
        }

        final label = _activityLabel(res.toolCalls);
        if (label != null) _append(_entry(ChatRole.status, label), wire);

        // Run tools. A read yields a result to feed back; a valid write pauses
        // the loop for confirmation. Only one write is proposed at a time.
        ProposedAction? paused;
        for (final call in res.toolCalls) {
          if (paused != null) {
            wire = [
              ...wire,
              AiChatMessage.toolResult(
                toolCallId: call.id,
                content: '{"error":"Confirm one action at a time."}',
              ),
            ];
            continue;
          }
          final outcome = await executor.run(call);
          switch (outcome) {
            case ToolResult(:final json):
              wire = [
                ...wire,
                AiChatMessage.toolResult(toolCallId: call.id, content: json),
              ];
            case ProposedWrite(:final action):
              paused = action;
          }
        }

        if (paused != null) {
          // Wait for confirm()/cancel(); the write's tool call is unanswered.
          state = state.copyWith(wire: wire, pending: paused, isBusy: false);
          return;
        }
        state = state.copyWith(wire: wire);
      }

      // Fell out of the loop still wanting tools — stop and be honest.
      state = state.copyWith(
        wire: wire,
        isBusy: false,
        error: 'That took too many steps. Try rephrasing.',
      );
    } on DioException catch (e) {
      state = state.copyWith(wire: wire, isBusy: false, error: _friendly(e));
    } catch (_) {
      state = state.copyWith(
        wire: wire,
        isBusy: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  void _append(ChatEntry entry, List<AiChatMessage> wire) {
    state = state.copyWith(entries: [...state.entries, entry], wire: wire);
  }

  ChatEntry _entry(ChatRole role, String text) => ChatEntry(
        id: '${DateTime.now().microsecondsSinceEpoch}_${role.name}',
        role: role,
        text: text,
      );

  /// A "Checked …" line for the read tools in a turn, or null when the turn is
  /// only a write proposal (the confirm card speaks for itself).
  String? _activityLabel(List<AiToolCall> calls) {
    const friendly = {
      'get_finance_overview': 'your month',
      'list_emis': 'your EMIs',
      'get_emi': 'that EMI',
      'list_subscriptions': 'your subscriptions',
      'list_cards': 'your cards',
      'get_card': 'that card',
      'list_card_statements': 'the statement history',
      'get_upcoming_dues': 'upcoming dues',
    };
    final names = calls
        .where((c) => friendly.containsKey(c.name))
        .map((c) => friendly[c.name]!)
        .toSet()
        .toList();
    if (names.isEmpty) return null;
    return 'Checked ${names.join(', ')}…';
  }

  String _friendly(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return 'Sign in to use the assistant.';
      case 429:
        return "You're going a bit fast — give it a moment.";
      case 502:
      case 503:
        return 'The assistant is unavailable right now.';
      default:
        return 'Could not reach the assistant. Check your connection.';
    }
  }
}
