/// A validated, NOT-yet-applied write the assistant wants to make. The model
/// emits a `propose_*` tool call; the executor validates it into one of these;
/// the UI renders it as an editable confirm card; only an explicit Confirm tap
/// runs it. Nothing here touches data — it is a description of an intended change.
///
/// Pure Dart (no Flutter) so it stays in the domain layer; the widget maps
/// [kind] to an icon/colour.
library;

enum ProposedActionKind {
  addSubscription,
  editSubscription,
  deleteSubscription,
  setCardStatement,
  markStatementPaid,
  editCard,
  editEmi,
  closeEmi,
}

/// How a field is edited in the confirm card.
enum ActionFieldType { text, amount, date, choice }

/// One editable line of a [ProposedAction]. For an edit, [oldValue] carries the
/// current value so the card can show an old → new diff.
class ActionField {
  const ActionField({
    required this.key,
    required this.label,
    required this.type,
    required this.value,
    this.oldValue,
    this.editable = true,
    this.choices = const [],
  });

  final String key;
  final String label;
  final ActionFieldType type;

  /// Amounts: a plain number string ("649"). Dates: `yyyy-MM-dd`. Choices: the
  /// selected option. Text: the text.
  final String value;

  /// The pre-change value for edits; null for creates. Drives the diff.
  final String? oldValue;
  final bool editable;

  /// Options for [ActionFieldType.choice].
  final List<String> choices;

  bool get changed => oldValue != null && oldValue != value;
}

class ProposedAction {
  const ProposedAction({
    required this.toolCallId,
    required this.kind,
    required this.title,
    required this.summary,
    this.fields = const [],
    this.warning,
    this.destructive = false,
    this.context = const {},
  });

  /// The tool call this answers — the confirm/cancel result is sent back under it.
  final String toolCallId;
  final ProposedActionKind kind;

  /// Card heading, e.g. "Add subscription".
  final String title;

  /// One-line human summary, e.g. "Netflix · ₹649 / monthly".
  final String summary;

  /// Editable fields shown on the card.
  final List<ActionField> fields;

  /// A caution shown prominently (deletes, closing an EMI).
  final String? warning;

  /// Renders the confirm affordance as destructive (delete).
  final bool destructive;

  /// Non-editable data the executor needs to apply the change (ids, cycle month…).
  final Map<String, dynamic> context;

  ActionField? field(String key) {
    for (final f in fields) {
      if (f.key == key) return f;
    }
    return null;
  }
}
