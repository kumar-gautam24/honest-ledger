import '../domain/entities/ai_message.dart';
import '../domain/entities/proposed_action.dart';

/// Who a rendered chat entry is from. `status` is a subtle system line (e.g.
/// "Checked your cards") that shows the assistant's tool activity.
enum ChatRole { user, assistant, status }

/// One rendered line in the chat transcript.
class ChatEntry {
  const ChatEntry({required this.id, required this.role, required this.text});

  final String id;
  final ChatRole role;
  final String text;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
      };

  factory ChatEntry.fromJson(Map<String, dynamic> j) => ChatEntry(
        id: j['id'] as String? ?? '',
        role: ChatRole.values.firstWhere(
          (r) => r.name == j['role'],
          orElse: () => ChatRole.assistant,
        ),
        text: j['text'] as String? ?? '',
      );
}

/// The assistant screen's state: what's rendered ([entries]), the raw protocol
/// history re-sent to the model each turn ([wire]), and busy/error flags.
class AssistantState {
  const AssistantState({
    this.entries = const [],
    this.wire = const [],
    this.isBusy = false,
    this.error,
    this.pending,
  });

  final List<ChatEntry> entries;
  final List<AiChatMessage> wire;
  final bool isBusy;
  final String? error;

  /// A write awaiting the user's Confirm/Cancel. While set, the composer is
  /// locked and the confirm card is shown; the tool loop is paused.
  final ProposedAction? pending;

  bool get isEmpty => entries.isEmpty;

  AssistantState copyWith({
    List<ChatEntry>? entries,
    List<AiChatMessage>? wire,
    bool? isBusy,
    String? error,
    bool clearError = false,
    ProposedAction? pending,
    bool clearPending = false,
  }) {
    return AssistantState(
      entries: entries ?? this.entries,
      wire: wire ?? this.wire,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
      pending: clearPending ? null : (pending ?? this.pending),
    );
  }
}
