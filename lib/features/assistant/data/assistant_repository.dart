import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../application/assistant_state.dart';
import '../domain/entities/ai_message.dart';

/// Persists the assistant conversation so reopening the chat restores it.
///
/// Both the rendered transcript ([ChatEntry]s) and the raw [AiChatMessage] wire
/// history are stored, so a reopened chat keeps its full model context — not
/// just the visible bubbles. Writes are best-effort: a failure never blocks the
/// chat (the transcript simply isn't restored next time).
class AssistantRepository {
  AssistantRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'assistant_conversation_v1';

  /// Loads the saved conversation, or `null` if there is none / it's unreadable.
  ({List<ChatEntry> entries, List<AiChatMessage> wire})? load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
      final entries = (map['entries'] as List? ?? const [])
          .map((e) => ChatEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      final wire = (map['wire'] as List? ?? const [])
          .map((e) => AiChatMessage.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      if (entries.isEmpty) return null;
      return (entries: entries, wire: wire);
    } catch (_) {
      return null;
    }
  }

  /// Saves the conversation. Best-effort — swallows any storage error.
  Future<void> save({
    required List<ChatEntry> entries,
    required List<AiChatMessage> wire,
  }) async {
    try {
      final payload = jsonEncode({
        'entries': entries.map((e) => e.toJson()).toList(),
        'wire': wire.map((m) => m.toJson()).toList(),
      });
      await _prefs.setString(_key, payload);
    } catch (_) {
      // Persistence is a nicety, never a blocker.
    }
  }

  /// Forgets the saved conversation (the "new chat" action).
  Future<void> clear() async {
    try {
      await _prefs.remove(_key);
    } catch (_) {}
  }
}
