import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/assistant/data/demo_ai_service.dart';
import 'package:recurring/features/assistant/domain/entities/ai_message.dart';

void main() {
  test('routes a broad question to get_finance_overview', () async {
    final res = await DemoAiService()
        .chat(messages: const [AiChatMessage.user('what do I owe this month?')]);
    expect(res.toolCalls.single.name, 'get_finance_overview');
  });

  test('routes "show my cards" to list_cards', () async {
    final res = await DemoAiService()
        .chat(messages: const [AiChatMessage.user('show my cards')]);
    expect(res.toolCalls.single.name, 'list_cards');
  });

  test('routes an add request to a proposed subscription write', () async {
    final res = await DemoAiService().chat(messages: const [
      AiChatMessage.user('Add a ₹649 monthly subscription called Netflix'),
    ]);
    final call = res.toolCalls.single;
    expect(call.name, 'propose_add_subscription');
    expect(call.arguments['title'], 'Netflix');
    expect(call.arguments['amount'], 649);
    expect(call.arguments['frequency'], 'monthly');
  });

  test('answers a saved-write tool result with a confirmation', () async {
    final res = await DemoAiService().chat(messages: const [
      AiChatMessage.toolResult(
        toolCallId: 'x',
        content: '{"status":"saved","summary":"Added \\"Netflix\\"."}',
      ),
    ]);
    expect(res.hasToolCalls, isFalse);
    expect(res.text, contains('Done'));
    expect(res.text, contains('Netflix'));
  });

  test('passes a tool error straight through as a question', () async {
    final res = await DemoAiService().chat(messages: const [
      AiChatMessage.toolResult(
        toolCallId: 'x',
        content: '{"error":"No card matches \\"foo\\"."}',
      ),
    ]);
    expect(res.text, contains('No card matches'));
  });
}
