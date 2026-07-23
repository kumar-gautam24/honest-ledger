import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/api_client.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/features/assistant/data/ai_service.dart';
import 'package:recurring/features/assistant/domain/entities/ai_message.dart';

class _Tokens implements AuthTokenStore {
  @override
  String? get accessToken => 'a';
  @override
  String? get refreshToken => 'r';
  @override
  String? get email => 'a@b.com';
  @override
  bool get isSignedIn => true;
  @override
  Future<void> save({required String accessToken, required String refreshToken, required String email}) async {}
  @override
  Future<void> updateAccessToken(String accessToken) async {}
  @override
  Future<void> clear() async {}
}

/// Captures the request body sent to `/v1/ai/chat` and serves a canned reply.
class _CaptureAdapter implements HttpClientAdapter {
  Map<String, dynamic>? sentBody;
  Map<String, dynamic> reply = const {};

  @override
  Future<ResponseBody> fetch(
      RequestOptions options, Stream<Uint8List>? s, Future<void>? c) async {
    sentBody = (options.data as Map).cast<String, dynamic>();
    return ResponseBody.fromString(jsonEncode(reply), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

AiServiceDio _service(_CaptureAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  return AiServiceDio(ApiClient(_Tokens(), dio: dio, refreshDio: dio));
}

void main() {
  test('chat serializes system, messages and tools to the wire shape', () async {
    final adapter = _CaptureAdapter()
      ..reply = {'text': 'hello', 'tool_calls': const []};
    final service = _service(adapter);

    await service.chat(
      system: 'You are a finance assistant.',
      messages: const [AiChatMessage.user('what do I owe?')],
      tools: const [
        AiToolDef(name: 'get_finance_overview', description: 'overview'),
      ],
      maxTokens: 512,
    );

    final body = adapter.sentBody!;
    expect(body['system'], 'You are a finance assistant.');
    expect(body['max_tokens'], 512);
    expect((body['messages'] as List).single, {
      'role': 'user',
      'content': 'what do I owe?',
    });
    expect((body['tools'] as List).single['name'], 'get_finance_overview');
  });

  test('chat parses text + tool calls out of the response', () async {
    final adapter = _CaptureAdapter()
      ..reply = {
        'text': 'let me check',
        'tool_calls': [
          {
            'id': 'call_1',
            'name': 'get_card',
            'arguments': {'name': 'ICICI'},
          }
        ],
        'stop_reason': 'tool_use',
        'usage': {'input_tokens': 12, 'output_tokens': 3},
      };
    final service = _service(adapter);

    final res = await service.chat(
      messages: const [AiChatMessage.user('show my ICICI card')],
    );

    expect(res.text, 'let me check');
    expect(res.hasToolCalls, isTrue);
    expect(res.toolCalls.single.name, 'get_card');
    expect(res.toolCalls.single.arguments['name'], 'ICICI');
    expect(res.usage!.inputTokens, 12);
  });

  test('an assistant tool-call turn and a tool result round-trip to JSON', () {
    const assistant = AiChatMessage.assistant(
      null,
      toolCalls: [AiToolCall(id: 'c1', name: 'list_cards')],
    );
    const result =
        AiChatMessage.toolResult(toolCallId: 'c1', content: '[{"nickname":"ICICI"}]');

    expect(assistant.toJson(), {
      'role': 'assistant',
      'tool_calls': [
        {'id': 'c1', 'name': 'list_cards', 'arguments': <String, dynamic>{}},
      ],
    });
    expect(result.toJson(), {
      'role': 'tool',
      'content': '[{"nickname":"ICICI"}]',
      'tool_call_id': 'c1',
    });
  });
}
