import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../domain/entities/ai_chat_response.dart';
import '../domain/entities/ai_message.dart';

/// Talks to the backend AI proxy at `/v1/ai/chat`.
///
/// This is the ONLY path from the app to a model — the provider key lives on the
/// server, never in the client. One request = one turn: the client sends the whole
/// history + tool schemas and gets back the assistant's reply (text and/or tool
/// calls). The tool-calling loop is driven client-side by the assistant controller.
abstract interface class AiService {
  Future<AiChatResponse> chat({
    required List<AiChatMessage> messages,
    List<AiToolDef> tools = const [],
    String? system,
    int maxTokens = 1024,
  });
}

class AiServiceDio implements AiService {
  AiServiceDio(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  @override
  Future<AiChatResponse> chat({
    required List<AiChatMessage> messages,
    List<AiToolDef> tools = const [],
    String? system,
    int maxTokens = 1024,
  }) async {
    final response = await _dio.post<dynamic>(
      '/v1/ai/chat',
      data: {
        if (system != null && system.isNotEmpty) 'system': system,
        'messages': messages.map((m) => m.toJson()).toList(),
        if (tools.isNotEmpty) 'tools': tools.map((t) => t.toJson()).toList(),
        'max_tokens': maxTokens,
      },
    );
    return AiChatResponse.fromJson((response.data as Map).cast<String, dynamic>());
  }
}
