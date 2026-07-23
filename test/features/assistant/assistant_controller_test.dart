import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/features/assistant/application/assistant_controller.dart';
import 'package:recurring/features/assistant/application/assistant_state.dart';
import 'package:recurring/features/assistant/application/tool_executor.dart';
import 'package:recurring/features/assistant/data/ai_service.dart';
import 'package:recurring/features/assistant/domain/entities/ai_chat_response.dart';
import 'package:recurring/features/assistant/domain/entities/ai_message.dart';
import 'package:recurring/features/assistant/domain/entities/proposed_action.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';
import 'package:recurring/features/cards/domain/repositories/card_repository.dart';
import 'package:recurring/features/cards/presentation/controllers/card_providers.dart';
import 'package:recurring/features/money_leak/presentation/controllers/money_leak_providers.dart';
import 'package:recurring/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A model driven by a fixed script of responses, one per turn. Enough to
/// exercise the whole client loop (call → run tool → feed back → answer) and the
/// propose → confirm write flow.
class _ScriptedAi implements AiService {
  _ScriptedAi(this.script);
  final List<AiChatResponse> script;
  int turns = 0;
  final List<int> messageCountsSeen = [];

  @override
  Future<AiChatResponse> chat({
    required List<AiChatMessage> messages,
    List<AiToolDef> tools = const [],
    String? system,
    int maxTokens = 1024,
  }) async {
    messageCountsSeen.add(messages.length);
    final res = script[turns.clamp(0, script.length - 1)];
    turns++;
    return res;
  }
}

Future<void> _configure() async {
  SharedPreferences.setMockInitialValues({});
  await sl.reset();
  await configureDependencies(database: AppDatabase.memory());
}

Future<void> _useAi(AiService ai) async {
  if (sl.isRegistered<AiService>()) await sl.unregister<AiService>();
  sl.registerSingleton<AiService>(ai);
}

AiChatResponse _text(String t) =>
    AiChatResponse(text: t, stopReason: 'end_turn');
AiChatResponse _call(String id, String name, [Map<String, dynamic> args = const {}]) =>
    AiChatResponse(
      toolCalls: [AiToolCall(id: id, name: name, arguments: args)],
      stopReason: 'tool_use',
    );

void main() {
  test('send runs the read-tool loop then shows the model answer', () async {
    await _configure();
    final ai = _ScriptedAi([
      _call('c1', 'get_finance_overview'),
      _text('You have nothing due this month.'),
    ]);
    await _useAi(ai);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(assistantControllerProvider, (_, _) {});

    await container
        .read(assistantControllerProvider.notifier)
        .send('what do I owe?');

    final state = container.read(assistantControllerProvider);
    expect(ai.turns, 2, reason: 'one tool round-trip, then the answer');
    expect(state.isBusy, isFalse);
    expect(state.error, isNull);

    final roles = state.entries.map((e) => e.role).toList();
    expect(roles.first, ChatRole.user);
    expect(roles, contains(ChatRole.status)); // tool-activity line
    expect(state.entries.last.role, ChatRole.assistant);
    expect(state.entries.last.text, 'You have nothing due this month.');
    expect(ai.messageCountsSeen[1], greaterThan(ai.messageCountsSeen[0]));
  });

  test('a proposed write pauses for confirmation, then persists on confirm',
      () async {
    await _configure();
    await sl<CardRepository>().upsertCard(CardAccount(
      id: 'c1',
      lenderId: 'l1',
      name: 'ICICI Amazon',
      nickname: 'ICICI Amazon',
      statementDay: 15,
      dueDay: 3,
      creditLimit: 6000,
      createdAt: DateTime(2026, 1, 1),
    ));
    final ai = _ScriptedAi([
      _call('w1', 'propose_set_card_statement', {
        'card': 'ICICI',
        'statement_amount': 2500,
        'due_date': '2026-08-03',
      }),
      _text('Done — set your ICICI statement to ₹2,500.'),
    ]);
    await _useAi(ai);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(assistantControllerProvider, (_, _) {});
    final notifier = container.read(assistantControllerProvider.notifier);

    // 1) Propose → pause, nothing written yet.
    await notifier.send('set my ICICI outstanding to 2500, due Aug 3');
    var state = container.read(assistantControllerProvider);
    expect(state.pending, isNotNull);
    expect(state.pending!.kind, ProposedActionKind.setCardStatement);
    expect(state.pending!.field('statement_amount')!.value, '2500');
    expect(state.isBusy, isFalse);
    expect(
      (await sl<CardRepository>().watchAllStatements().first),
      isEmpty,
      reason: 'nothing is written before confirmation',
    );

    // 2) Confirm → write persists and the loop resumes to a final answer.
    await notifier.confirm(const {});
    state = container.read(assistantControllerProvider);
    expect(state.pending, isNull);
    expect(state.isBusy, isFalse);
    expect(state.entries.last.role, ChatRole.assistant);

    final statements = await sl<CardRepository>().watchAllStatements().first;
    expect(statements, hasLength(1));
    expect(statements.single.statementAmount, 2500);
    expect(statements.single.cardId, 'c1');
  });

  test('cancel declines a proposed write without writing anything', () async {
    await _configure();
    await sl<CardRepository>().upsertCard(CardAccount(
      id: 'c1',
      lenderId: 'l1',
      name: 'ICICI',
      nickname: 'ICICI',
      statementDay: 15,
      dueDay: 3,
      createdAt: DateTime(2026, 1, 1),
    ));
    final ai = _ScriptedAi([
      _call('w1', 'propose_set_card_statement',
          {'card': 'ICICI', 'statement_amount': 999}),
      _text('No problem, I left it unchanged.'),
    ]);
    await _useAi(ai);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(assistantControllerProvider, (_, _) {});
    final notifier = container.read(assistantControllerProvider.notifier);

    await notifier.send('set ICICI to 999');
    expect(container.read(assistantControllerProvider).pending, isNotNull);

    await notifier.cancel();
    expect(container.read(assistantControllerProvider).pending, isNull);
    expect(await sl<CardRepository>().watchAllStatements().first, isEmpty);
  });

  test('get_card tool serializes outstanding + derived utilization', () async {
    await _configure();

    final cards = sl<CardRepository>();
    await cards.upsertCard(CardAccount(
      id: 'c1',
      lenderId: 'l1',
      name: 'ICICI Amazon',
      nickname: 'ICICI Amazon',
      statementDay: 15,
      dueDay: 20,
      creditLimit: 6000,
      createdAt: DateTime(2026, 1, 1),
    ));
    await cards.upsertStatement(CardStatement(
      id: 's1',
      cardId: 'c1',
      cycleMonth: DateTime(2026, 7, 1),
      statementAmount: 2000,
      dueDate: DateTime(2026, 7, 20),
    ));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(cardsProvider, (_, _) {});
    container.listen(allCardStatementsProvider, (_, _) {});
    container.listen(borrowingSummariesProvider, (_, _) {});
    container.listen(recurringItemsProvider, (_, _) {});
    await container.read(cardsProvider.future);
    await container.read(allCardStatementsProvider.future);

    final exec = container.read(Provider((ref) => ToolExecutor(ref)));
    final outcome = await exec.run(
      const AiToolCall(id: 'x', name: 'get_card', arguments: {'card': 'ICICI'}),
    );
    final out = jsonDecode((outcome as ToolResult).json) as Map<String, dynamic>;

    expect(out['name'], 'ICICI Amazon');
    expect(out['credit_limit'], 6000);
    expect(out['current_outstanding'], 2000);
    expect(out['utilization_pct'], 33); // 2000 / 6000
    expect((out['latest_statement'] as Map)['due_date'], '2026-07-20');
  });

  test('unknown tool returns a recoverable error payload', () async {
    await _configure();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final exec = container.read(Provider((ref) => ToolExecutor(ref)));

    final outcome = await exec.run(const AiToolCall(id: 'x', name: 'nope'));
    final out = jsonDecode((outcome as ToolResult).json) as Map<String, dynamic>;
    expect(out['error'], contains('Unknown tool'));
  });
}
