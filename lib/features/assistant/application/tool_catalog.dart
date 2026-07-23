import '../domain/entities/ai_message.dart';

/// The read-only tools the assistant may call (Phase 2). Each maps onto data the
/// app already computes; none of them writes. The JSON-Schema `parameters` tell
/// the model exactly what arguments are valid.
///
/// Write tools (propose_*) are added in Phase 3 and are the only ones that can
/// change data — and only after an explicit on-screen confirmation.
const List<AiToolDef> kReadTools = [
  AiToolDef(
    name: 'get_finance_overview',
    description:
        'A snapshot of the user\'s whole month: total committed monthly outgo '
        'split by kind, what is due vs paid vs remaining this calendar month, '
        'monthly income if set, and counts of EMIs/subscriptions/cards. Use this '
        'for broad questions like "what do I owe?" or "how am I doing this month?".',
    parameters: {'type': 'object', 'properties': <String, dynamic>{}},
  ),
  AiToolDef(
    name: 'list_emis',
    description:
        'List the user\'s EMIs and loans with outstanding, next installment and '
        'status. Use for questions about loans/EMIs.',
    parameters: {
      'type': 'object',
      'properties': {
        'status': {
          'type': 'string',
          'enum': ['active', 'closed', 'all'],
          'description': 'Which to include. Defaults to active.',
        },
      },
    },
  ),
  AiToolDef(
    name: 'get_emi',
    description: 'Full detail for one EMI/loan by its id (from list_emis).',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string', 'description': 'The borrowing id.'},
      },
      'required': ['id'],
    },
  ),
  AiToolDef(
    name: 'list_subscriptions',
    description:
        'List recurring subscriptions and bills with amount, frequency, monthly '
        'equivalent and next due date.',
    parameters: {
      'type': 'object',
      'properties': {
        'active_only': {
          'type': 'boolean',
          'description': 'Only active items. Defaults to true.',
        },
      },
    },
  ),
  AiToolDef(
    name: 'list_cards',
    description:
        'List the user\'s credit cards with credit limit, current outstanding '
        'and utilization. Use for "my cards" questions.',
    parameters: {'type': 'object', 'properties': <String, dynamic>{}},
  ),
  AiToolDef(
    name: 'get_card',
    description:
        'Detail for one card by id or name (e.g. "ICICI"): its latest statement '
        '(outstanding, due date, paid), credit limit and utilization.',
    parameters: {
      'type': 'object',
      'properties': {
        'card': {
          'type': 'string',
          'description': 'Card id or a name/nickname to match.',
        },
      },
      'required': ['card'],
    },
  ),
  AiToolDef(
    name: 'list_card_statements',
    description: 'The statement history for one card (by id or name).',
    parameters: {
      'type': 'object',
      'properties': {
        'card': {
          'type': 'string',
          'description': 'Card id or a name/nickname to match.',
        },
      },
      'required': ['card'],
    },
  ),
  AiToolDef(
    name: 'get_upcoming_dues',
    description:
        'What is due soon: EMI installments, loan plans, subscriptions and card '
        'bills with due dates, within a number of days from today.',
    parameters: {
      'type': 'object',
      'properties': {
        'within_days': {
          'type': 'integer',
          'description': 'Horizon in days. Defaults to 30.',
        },
      },
    },
  ),
];

/// Write tools (Phase 3). A `propose_*` call NEVER changes data directly — it
/// produces a confirmation card the user must approve. Always propose ONE action
/// at a time. Prefer reading first (e.g. list_cards) to get real ids/names.
const List<AiToolDef> kWriteTools = [
  AiToolDef(
    name: 'propose_add_subscription',
    description:
        'Propose adding a recurring subscription or bill. Use for "add my '
        'Netflix at 649 a month".',
    parameters: {
      'type': 'object',
      'properties': {
        'title': {'type': 'string', 'description': 'Name, e.g. "Netflix".'},
        'amount': {'type': 'number', 'description': 'Amount in rupees, > 0.'},
        'frequency': {
          'type': 'string',
          'enum': ['weekly', 'monthly', 'quarterly', 'yearly'],
          'description': 'Defaults to monthly.',
        },
        'next_due_date': {
          'type': 'string',
          'description': 'yyyy-MM-dd. Defaults to today.',
        },
        'category': {'type': 'string'},
        'card_id': {
          'type': 'string',
          'description': 'Card id if billed on a specific card.',
        },
      },
      'required': ['title', 'amount'],
    },
  ),
  AiToolDef(
    name: 'propose_edit_subscription',
    description:
        'Propose editing an existing subscription by id (from list_subscriptions). '
        'Include only the fields to change.',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'title': {'type': 'string'},
        'amount': {'type': 'number'},
        'frequency': {
          'type': 'string',
          'enum': ['weekly', 'monthly', 'quarterly', 'yearly'],
        },
        'next_due_date': {'type': 'string', 'description': 'yyyy-MM-dd'},
        'is_active': {'type': 'boolean', 'description': 'Pause/resume.'},
      },
      'required': ['id'],
    },
  ),
  AiToolDef(
    name: 'propose_delete_subscription',
    description: 'Propose deleting a subscription by id. This is permanent.',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
      },
      'required': ['id'],
    },
  ),
  AiToolDef(
    name: 'propose_set_card_statement',
    description:
        'Propose setting (or updating) a card\'s statement outstanding for the '
        'current cycle. Use for "my ICICI outstanding is 2000, due the 3rd".',
    parameters: {
      'type': 'object',
      'properties': {
        'card': {'type': 'string', 'description': 'Card id or name.'},
        'statement_amount': {
          'type': 'number',
          'description': 'Outstanding, in rupees, > 0.',
        },
        'due_date': {
          'type': 'string',
          'description': 'yyyy-MM-dd. Defaults to the computed due date.',
        },
        'cycle_month': {
          'type': 'string',
          'description': 'yyyy-MM-dd (any day in the cycle month). Defaults to '
              'the latest cycle.',
        },
      },
      'required': ['card', 'statement_amount'],
    },
  ),
  AiToolDef(
    name: 'propose_mark_statement_paid',
    description:
        'Propose marking a card\'s latest statement as paid (fully, or a part).',
    parameters: {
      'type': 'object',
      'properties': {
        'card': {'type': 'string', 'description': 'Card id or name.'},
        'paid_amount': {
          'type': 'number',
          'description': 'Defaults to the full statement amount.',
        },
      },
      'required': ['card'],
    },
  ),
  AiToolDef(
    name: 'propose_edit_card',
    description:
        'Propose editing a card\'s nickname, credit limit, statement day or due '
        'day. Include only the fields to change.',
    parameters: {
      'type': 'object',
      'properties': {
        'card': {'type': 'string', 'description': 'Card id or name.'},
        'nickname': {'type': 'string'},
        'credit_limit': {'type': 'number'},
        'statement_day': {'type': 'integer', 'description': '1–31'},
        'due_day': {'type': 'integer', 'description': '1–31'},
      },
      'required': ['card'],
    },
  ),
  AiToolDef(
    name: 'propose_edit_emi',
    description:
        'Propose editing an EMI/loan by id: its minimum payment, status or notes.',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'min_payment': {'type': 'number'},
        'status': {
          'type': 'string',
          'enum': ['active', 'closed'],
        },
        'notes': {'type': 'string'},
      },
      'required': ['id'],
    },
  ),
  AiToolDef(
    name: 'propose_close_emi',
    description: 'Propose marking an EMI/loan as closed (paid off).',
    parameters: {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
      },
      'required': ['id'],
    },
  ),
];

/// Everything the model may call: reads + writes.
const List<AiToolDef> kAllTools = [...kReadTools, ...kWriteTools];
