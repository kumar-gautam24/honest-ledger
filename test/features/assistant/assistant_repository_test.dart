import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/assistant/application/assistant_state.dart';
import 'package:recurring/features/assistant/data/assistant_repository.dart';
import 'package:recurring/features/assistant/domain/entities/ai_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AssistantRepository> repo() async =>
      AssistantRepository(await SharedPreferences.getInstance());

  test('returns null when nothing is saved', () async {
    expect((await repo()).load(), isNull);
  });

  test('round-trips transcript and wire, including a tool-call turn', () async {
    final entries = [
      const ChatEntry(id: '1', role: ChatRole.user, text: 'show my cards'),
      const ChatEntry(id: '2', role: ChatRole.status, text: 'Checked your cards…'),
      const ChatEntry(id: '3', role: ChatRole.assistant, text: 'You have 2 cards.'),
    ];
    final wire = [
      const AiChatMessage.user('show my cards'),
      const AiChatMessage.assistant(
        null,
        toolCalls: [AiToolCall(id: 'call_1', name: 'list_cards')],
      ),
      const AiChatMessage.toolResult(
        toolCallId: 'call_1',
        content: '{"cards":[]}',
      ),
      const AiChatMessage.assistant('You have 2 cards.'),
    ];

    final r = await repo();
    await r.save(entries: entries, wire: wire);

    // A fresh repository over the same store reads it back.
    final loaded = (await repo()).load();
    expect(loaded, isNotNull);
    expect(loaded!.entries.map((e) => e.role).toList(),
        [ChatRole.user, ChatRole.status, ChatRole.assistant]);
    expect(loaded.entries.last.text, 'You have 2 cards.');

    expect(loaded.wire.length, 4);
    expect(loaded.wire[1].role, AiRole.assistant);
    expect(loaded.wire[1].toolCalls!.single.name, 'list_cards');
    expect(loaded.wire[2].role, AiRole.tool);
    expect(loaded.wire[2].toolCallId, 'call_1');
  });

  test('clear forgets the saved conversation', () async {
    final r = await repo();
    await r.save(
      entries: [const ChatEntry(id: '1', role: ChatRole.user, text: 'hi')],
      wire: [const AiChatMessage.user('hi')],
    );
    await r.clear();
    expect((await repo()).load(), isNull);
  });
}
