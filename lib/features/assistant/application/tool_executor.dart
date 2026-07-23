import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../cards/domain/entities/card_account.dart';
import '../../cards/domain/entities/card_cycle.dart';
import '../../cards/domain/entities/card_statement.dart';
import '../../cards/domain/repositories/card_repository.dart';
import '../../cards/presentation/controllers/card_providers.dart';
import '../../home/domain/entities/month_plan.dart';
import '../../home/domain/entities/monthly_obligation_stats.dart';
import '../../money_leak/domain/entities/borrowing.dart';
import '../../money_leak/domain/entities/borrowing_summary.dart';
import '../../money_leak/domain/repositories/borrowing_repository.dart';
import '../../money_leak/presentation/controllers/money_leak_providers.dart';
import '../../recurring/domain/entities/recurring_item.dart';
import '../../recurring/domain/repositories/recurring_repository.dart';
import '../../recurring/presentation/controllers/recurring_providers.dart';
import '../../settings/presentation/controllers/income_controller.dart';
import '../domain/entities/ai_message.dart';
import '../domain/entities/proposed_action.dart';

const _uuid = Uuid();
const _frequencies = ['weekly', 'monthly', 'quarterly', 'yearly'];

/// The result of running one tool.
sealed class ToolOutcome {}

/// A read result (or a validation error) to feed straight back to the model.
class ToolResult extends ToolOutcome {
  ToolResult(this.json);
  final String json;
}

/// A validated write awaiting the user's confirmation. The loop pauses here.
class ProposedWrite extends ToolOutcome {
  ProposedWrite(this.action);
  final ProposedAction action;
}

/// Runs a tool the model asked for against the app's live data.
///
/// Read tools return a [ToolResult] (JSON). Write tools (`propose_*`) NEVER
/// mutate here — they validate and return a [ProposedWrite]; the actual change
/// happens only in [execute], after the user confirms. Bad arguments come back as
/// a `{"error": ...}` [ToolResult] so the model can ask a question instead of
/// failing.
class ToolExecutor {
  ToolExecutor(this._ref);

  final Ref _ref;

  Future<ToolOutcome> run(AiToolCall call) async {
    try {
      final a = call.arguments;
      switch (call.name) {
        // --- reads ---
        case 'get_finance_overview':
          return _res(await _overview());
        case 'list_emis':
          return _res(await _listEmis(a['status'] as String?));
        case 'get_emi':
          return _res(await _getEmi(a['id'] as String?));
        case 'list_subscriptions':
          return _res(await _listSubscriptions(a['active_only'] as bool? ?? true));
        case 'list_cards':
          return _res(await _listCards());
        case 'get_card':
          return _res(await _getCard(a['card'] as String?));
        case 'list_card_statements':
          return _res(await _listStatements(a['card'] as String?));
        case 'get_upcoming_dues':
          return _res(await _upcomingDues((a['within_days'] as num?)?.toInt() ?? 30));
        // --- writes (propose only) ---
        case 'propose_add_subscription':
          return _proposeAddSubscription(call.id, a);
        case 'propose_edit_subscription':
          return _proposeEditSubscription(call.id, a);
        case 'propose_delete_subscription':
          return _proposeDeleteSubscription(call.id, a);
        case 'propose_set_card_statement':
          return _proposeSetCardStatement(call.id, a);
        case 'propose_mark_statement_paid':
          return _proposeMarkStatementPaid(call.id, a);
        case 'propose_edit_card':
          return _proposeEditCard(call.id, a);
        case 'propose_edit_emi':
          return _proposeEditEmi(call.id, a);
        case 'propose_close_emi':
          return _proposeCloseEmi(call.id, a);
        default:
          return _err('Unknown tool: ${call.name}');
      }
    } catch (e) {
      return _err('Could not run ${call.name}: $e');
    }
  }

  /// Applies a confirmed (possibly user-edited) action. [edited] holds the
  /// current field values from the confirm card. Returns a JSON result to feed
  /// back to the model.
  Future<String> execute(ProposedAction a, Map<String, String> edited) async {
    String raw(String key) => edited[key] ?? a.field(key)?.value ?? '';
    double amt(String key) => _num(raw(key)) ?? 0;
    DateTime date(String key) => DateTime.parse(raw(key));
    final ctx = a.context;

    switch (a.kind) {
      case ProposedActionKind.addSubscription:
        final item = RecurringItem(
          id: _uuid.v4(),
          title: raw('title'),
          amount: amt('amount'),
          frequency: _freq(raw('frequency')),
          nextDueDate: date('next_due'),
          createdAt: DateTime.now(),
          category: ctx['category'] as String?,
          cardId: ctx['card_id'] as String?,
        );
        await _recurring.upsert(item);
        return _ok('Added "${item.title}".');

      case ProposedActionKind.editSubscription:
        final existing =
            (await _subs()).firstWhereOrNull((s) => s.id == ctx['id']);
        if (existing == null) return _fail('That subscription no longer exists.');
        var updated = existing;
        if (a.field('title') != null) updated = updated.copyWith(title: raw('title'));
        if (a.field('amount') != null) updated = updated.copyWith(amount: amt('amount'));
        if (a.field('frequency') != null) {
          updated = updated.copyWith(frequency: _freq(raw('frequency')));
        }
        if (a.field('next_due') != null) {
          updated = updated.copyWith(nextDueDate: date('next_due'));
        }
        if (ctx['is_active'] is bool) {
          updated = updated.copyWith(isActive: ctx['is_active'] as bool);
        }
        await _recurring.upsert(updated);
        return _ok('Updated "${updated.title}".');

      case ProposedActionKind.deleteSubscription:
        await _recurring.delete(ctx['id'] as String);
        return _ok('Deleted "${ctx['title']}".');

      case ProposedActionKind.setCardStatement:
        final cardId = ctx['cardId'] as String;
        final cycle = DateTime.parse(ctx['cycleMonth'] as String);
        final amount = amt('statement_amount');
        final due = date('due_date');
        final statementId = ctx['statementId'] as String?;
        if (statementId != null) {
          final existing = (await _statements())
              .firstWhereOrNull((s) => s.id == statementId);
          final base = existing ??
              CardStatement(
                id: statementId,
                cardId: cardId,
                cycleMonth: cycle,
                statementAmount: amount,
                dueDate: due,
              );
          await _cards.upsertStatement(
              base.copyWith(statementAmount: amount, dueDate: due));
        } else {
          await _cards.upsertStatement(CardStatement(
            id: _uuid.v4(),
            cardId: cardId,
            cycleMonth: cycle,
            statementAmount: amount,
            dueDate: due,
          ));
        }
        return _ok('Set ${ctx['cardName']} statement to ₹${_r(amount)}.');

      case ProposedActionKind.markStatementPaid:
        final st = (await _statements())
            .firstWhereOrNull((s) => s.id == ctx['statementId']);
        if (st == null) return _fail('That statement no longer exists.');
        await _cards.upsertStatement(
          st.copyWith(paidAmount: amt('paid_amount'), paidDate: DateTime.now()),
        );
        return _ok('Marked ₹${_r(amt('paid_amount'))} paid on ${ctx['cardName']}.');

      case ProposedActionKind.editCard:
        final card =
            (await _cardList()).firstWhereOrNull((c) => c.id == ctx['cardId']);
        if (card == null) return _fail('That card no longer exists.');
        var updated = card;
        if (a.field('nickname') != null) {
          updated = updated.copyWith(nickname: raw('nickname'));
        }
        if (a.field('credit_limit') != null) {
          updated = updated.copyWith(creditLimit: amt('credit_limit'));
        }
        if (a.field('statement_day') != null) {
          updated = updated.copyWith(statementDay: int.parse(raw('statement_day')));
        }
        if (a.field('due_day') != null) {
          updated = updated.copyWith(dueDay: int.parse(raw('due_day')));
        }
        await _cards.upsertCard(updated);
        return _ok('Updated ${updated.name}.');

      case ProposedActionKind.editEmi:
        final b = (await _borrowings())
            .firstWhereOrNull((s) => s.borrowing.id == ctx['id'])
            ?.borrowing;
        if (b == null) return _fail('That EMI no longer exists.');
        var updated = b;
        if (a.field('min_payment') != null) {
          updated = updated.copyWith(minPayment: amt('min_payment'));
        }
        if (a.field('status') != null) {
          updated = updated.copyWith(
            status: raw('status') == 'closed'
                ? BorrowingStatus.closed
                : BorrowingStatus.active,
          );
        }
        if (a.field('notes') != null) updated = updated.copyWith(notes: raw('notes'));
        await _borrowingRepo.upsertBorrowing(updated);
        return _ok('Updated "${updated.title}".');

      case ProposedActionKind.closeEmi:
        final b = (await _borrowings())
            .firstWhereOrNull((s) => s.borrowing.id == ctx['id'])
            ?.borrowing;
        if (b == null) return _fail('That EMI no longer exists.');
        await _borrowingRepo
            .upsertBorrowing(b.copyWith(status: BorrowingStatus.closed));
        return _ok('Closed "${b.title}".');
    }
  }

  // --- repositories & snapshots ---------------------------------------------

  RecurringRepository get _recurring => _ref.read(recurringRepositoryProvider);
  CardRepository get _cards => _ref.read(cardRepositoryProvider);
  BorrowingRepository get _borrowingRepo =>
      _ref.read(borrowingRepositoryProvider);

  // One-shot snapshots straight from the repositories. We deliberately do NOT
  // read the auto-dispose stream providers here: the assistant screen doesn't
  // keep them alive, so `provider.future` can be disposed mid-load. Taking the
  // first value of a fresh repo stream is robust and gives the current data.
  Future<List<BorrowingSummary>> _borrowings() =>
      _borrowingRepo.watchSummaries().first;
  Future<List<RecurringItem>> _subs() => _recurring.watchAll().first;
  Future<List<CardAccount>> _cardList() => _cards.watchCards().first;
  Future<List<CardStatement>> _statements() =>
      _cards.watchAllStatements().first;

  // --- write proposals (validate -> ProposedWrite, or an error) -------------

  Future<ToolOutcome> _proposeAddSubscription(
      String callId, Map<String, dynamic> a) async {
    final title = (a['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) return _err('What should the subscription be called?');
    final amount = _num(a['amount']);
    if (amount == null || amount <= 0) return _err('What amount, in rupees?');
    final freq = _freqName(a['frequency']);
    if (freq == null) return _err('Frequency must be weekly/monthly/quarterly/yearly.');
    final due = a['next_due_date'] == null
        ? DateTime.now()
        : _date(a['next_due_date']);
    if (due == null) return _err('The next due date should be yyyy-MM-dd.');

    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.addSubscription,
      title: 'Add subscription',
      summary: '$title · ₹${_r(amount)} / $freq',
      fields: [
        ActionField(key: 'title', label: 'Name', type: ActionFieldType.text, value: title),
        ActionField(key: 'amount', label: 'Amount', type: ActionFieldType.amount, value: _amtStr(amount)),
        ActionField(key: 'frequency', label: 'Frequency', type: ActionFieldType.choice, value: freq, choices: _frequencies),
        ActionField(key: 'next_due', label: 'Next due', type: ActionFieldType.date, value: _d(due)),
      ],
      context: {'category': a['category'], 'card_id': a['card_id']},
    ));
  }

  Future<ToolOutcome> _proposeEditSubscription(
      String callId, Map<String, dynamic> a) async {
    final id = a['id'] as String?;
    final existing = (await _subs()).firstWhereOrNull((s) => s.id == id);
    if (existing == null) return _err('No subscription with id "$id".');

    final fields = <ActionField>[];
    if (a['title'] != null) {
      fields.add(ActionField(key: 'title', label: 'Name', type: ActionFieldType.text, value: (a['title'] as String).trim(), oldValue: existing.title));
    }
    if (a['amount'] != null) {
      final v = _num(a['amount']);
      if (v == null || v <= 0) return _err('Amount must be a number > 0.');
      fields.add(ActionField(key: 'amount', label: 'Amount', type: ActionFieldType.amount, value: _amtStr(v), oldValue: _amtStr(existing.amount)));
    }
    if (a['frequency'] != null) {
      final f = _freqName(a['frequency']);
      if (f == null) return _err('Frequency must be weekly/monthly/quarterly/yearly.');
      fields.add(ActionField(key: 'frequency', label: 'Frequency', type: ActionFieldType.choice, value: f, oldValue: existing.frequency.name, choices: _frequencies));
    }
    if (a['next_due_date'] != null) {
      final d = _date(a['next_due_date']);
      if (d == null) return _err('The next due date should be yyyy-MM-dd.');
      fields.add(ActionField(key: 'next_due', label: 'Next due', type: ActionFieldType.date, value: _d(d), oldValue: _d(existing.nextDueDate)));
    }
    final isActive = a['is_active'] as bool?;
    if (fields.isEmpty && isActive == null) {
      return _err('Nothing to change — specify a field.');
    }

    final activeNote = isActive == null ? '' : (isActive ? ' · resume' : ' · pause');
    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.editSubscription,
      title: 'Edit subscription',
      summary: '${existing.title}$activeNote',
      fields: fields,
      context: {'id': existing.id, 'is_active': ?isActive},
    ));
  }

  Future<ToolOutcome> _proposeDeleteSubscription(
      String callId, Map<String, dynamic> a) async {
    final id = a['id'] as String?;
    final existing = (await _subs()).firstWhereOrNull((s) => s.id == id);
    if (existing == null) return _err('No subscription with id "$id".');
    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.deleteSubscription,
      title: 'Delete subscription',
      summary: existing.title,
      destructive: true,
      warning: 'This permanently removes "${existing.title}".',
      context: {'id': existing.id, 'title': existing.title},
    ));
  }

  Future<ToolOutcome> _proposeSetCardStatement(
      String callId, Map<String, dynamic> a) async {
    final card = await _resolveCard(a['card'] as String?);
    if (card is ToolResult) return card; // error / ambiguous
    final c = (card as _CardHit).card;

    final amount = _num(a['statement_amount']);
    if (amount == null || amount <= 0) return _err('Statement amount must be > 0.');

    final cycle = a['cycle_month'] == null
        ? CardCycle.cycleFor(now: DateTime.now(), statementDay: c.statementDay)
        : _firstOfMonth(_date(a['cycle_month']));
    if (cycle == null) return _err('cycle_month should be yyyy-MM-dd.');

    final due = a['due_date'] == null
        ? CardCycle.dueDateFor(
            cycleMonth: cycle, statementDay: c.statementDay, dueDay: c.dueDay)
        : _date(a['due_date']);
    if (due == null) return _err('due_date should be yyyy-MM-dd.');

    final existing = (await _statements()).firstWhereOrNull((s) =>
        s.cardId == c.id &&
        s.cycleMonth.year == cycle.year &&
        s.cycleMonth.month == cycle.month);

    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.setCardStatement,
      title: existing == null ? 'Add card statement' : 'Update card statement',
      summary: '${c.name} · ₹${_r(amount)}',
      fields: [
        ActionField(key: 'statement_amount', label: 'Outstanding', type: ActionFieldType.amount, value: _amtStr(amount), oldValue: existing == null ? null : _amtStr(existing.statementAmount)),
        ActionField(key: 'due_date', label: 'Due date', type: ActionFieldType.date, value: _d(due), oldValue: existing == null ? null : _d(existing.dueDate)),
      ],
      context: {
        'cardId': c.id,
        'cardName': c.name,
        'cycleMonth': _d(cycle),
        'statementId': existing?.id,
      },
    ));
  }

  Future<ToolOutcome> _proposeMarkStatementPaid(
      String callId, Map<String, dynamic> a) async {
    final card = await _resolveCard(a['card'] as String?);
    if (card is ToolResult) return card;
    final c = (card as _CardHit).card;
    final latest = _latestStatement(c.id, await _statements());
    if (latest == null) return _err('${c.name} has no statement to mark paid.');
    final amount = a['paid_amount'] == null
        ? latest.statementAmount
        : _num(a['paid_amount']);
    if (amount == null || amount < 0) return _err('Paid amount must be ≥ 0.');
    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.markStatementPaid,
      title: 'Mark statement paid',
      summary: '${c.name} · ₹${_r(amount)} paid',
      fields: [
        ActionField(key: 'paid_amount', label: 'Paid amount', type: ActionFieldType.amount, value: _amtStr(amount)),
      ],
      context: {'statementId': latest.id, 'cardName': c.name},
    ));
  }

  Future<ToolOutcome> _proposeEditCard(
      String callId, Map<String, dynamic> a) async {
    final card = await _resolveCard(a['card'] as String?);
    if (card is ToolResult) return card;
    final c = (card as _CardHit).card;

    final fields = <ActionField>[];
    if (a['nickname'] != null) {
      fields.add(ActionField(key: 'nickname', label: 'Nickname', type: ActionFieldType.text, value: (a['nickname'] as String).trim(), oldValue: c.nickname ?? c.name));
    }
    if (a['credit_limit'] != null) {
      final v = _num(a['credit_limit']);
      if (v == null || v <= 0) return _err('Credit limit must be > 0.');
      fields.add(ActionField(key: 'credit_limit', label: 'Credit limit', type: ActionFieldType.amount, value: _amtStr(v), oldValue: c.creditLimit == null ? null : _amtStr(c.creditLimit!)));
    }
    if (a['statement_day'] != null) {
      final v = (a['statement_day'] as num).toInt();
      if (v < 1 || v > 31) return _err('statement_day must be 1–31.');
      fields.add(ActionField(key: 'statement_day', label: 'Statement day', type: ActionFieldType.text, value: '$v', oldValue: '${c.statementDay}'));
    }
    if (a['due_day'] != null) {
      final v = (a['due_day'] as num).toInt();
      if (v < 1 || v > 31) return _err('due_day must be 1–31.');
      fields.add(ActionField(key: 'due_day', label: 'Due day', type: ActionFieldType.text, value: '$v', oldValue: '${c.dueDay}'));
    }
    if (fields.isEmpty) return _err('Nothing to change — specify a field.');

    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.editCard,
      title: 'Edit card',
      summary: c.name,
      fields: fields,
      context: {'cardId': c.id},
    ));
  }

  Future<ToolOutcome> _proposeEditEmi(
      String callId, Map<String, dynamic> a) async {
    final id = a['id'] as String?;
    final b = (await _borrowings())
        .firstWhereOrNull((s) => s.borrowing.id == id)
        ?.borrowing;
    if (b == null) return _err('No EMI/loan with id "$id".');

    final fields = <ActionField>[];
    if (a['min_payment'] != null) {
      final v = _num(a['min_payment']);
      if (v == null || v < 0) return _err('Minimum payment must be ≥ 0.');
      fields.add(ActionField(key: 'min_payment', label: 'Min payment', type: ActionFieldType.amount, value: _amtStr(v), oldValue: _amtStr(b.minPayment)));
    }
    if (a['status'] != null) {
      final s = (a['status'] as String).toLowerCase();
      if (s != 'active' && s != 'closed') return _err('status must be active or closed.');
      fields.add(ActionField(key: 'status', label: 'Status', type: ActionFieldType.choice, value: s, oldValue: b.status.name, choices: const ['active', 'closed']));
    }
    if (a['notes'] != null) {
      fields.add(ActionField(key: 'notes', label: 'Notes', type: ActionFieldType.text, value: (a['notes'] as String).trim(), oldValue: b.notes ?? ''));
    }
    if (fields.isEmpty) return _err('Nothing to change — specify a field.');

    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.editEmi,
      title: 'Edit EMI',
      summary: b.title,
      fields: fields,
      context: {'id': b.id},
    ));
  }

  Future<ToolOutcome> _proposeCloseEmi(
      String callId, Map<String, dynamic> a) async {
    final id = a['id'] as String?;
    final b = (await _borrowings())
        .firstWhereOrNull((s) => s.borrowing.id == id)
        ?.borrowing;
    if (b == null) return _err('No EMI/loan with id "$id".');
    if (b.isClosed) return _err('"${b.title}" is already closed.');
    return ProposedWrite(ProposedAction(
      toolCallId: callId,
      kind: ProposedActionKind.closeEmi,
      title: 'Close EMI',
      summary: b.title,
      warning: 'Marks "${b.title}" as closed (paid off).',
      context: {'id': b.id},
    ));
  }

  // --- card resolution -------------------------------------------------------

  Future<Object> _resolveCard(String? query) async {
    if (query == null || query.trim().isEmpty) {
      return ToolResult(jsonEncode({'error': 'Provide a card id or name.'}));
    }
    final matches = _matchCards(await _cardList(), query);
    if (matches.isEmpty) {
      return ToolResult(jsonEncode({'error': 'No card matches "$query".'}));
    }
    if (matches.length > 1) {
      return ToolResult(jsonEncode({
        'ambiguous': true,
        'message': 'More than one card matches "$query" — ask which.',
        'matches': [for (final c in matches) {'id': c.id, 'name': c.name}],
      }));
    }
    return _CardHit(matches.single);
  }

  // ==========================================================================
  // Read tools (return Map; wrapped in ToolResult by run()).
  // ==========================================================================

  Future<Map<String, dynamic>> _overview() async {
    final borrowings = await _borrowings();
    final subs = await _subs();
    final cards = await _cardList();
    final statements = await _statements();
    final income = _ref.read(incomeControllerProvider);

    final stats = MonthlyObligationStats.from(borrowings, subs);
    final plan = MonthPlan.from(
      summaries: borrowings,
      items: subs,
      now: DateTime.now(),
      cards: cards,
      statements: statements,
    );

    return {
      'monthly_income': income == null ? null : _r(income),
      'monthly_committed_total': _r(stats.total),
      'monthly_by_category': {
        for (final e in stats.byCategory.entries) e.key.name: _r(e.value),
      },
      'this_month': {
        'due': _r(plan.totalDue),
        'paid': _r(plan.totalPaid),
        'remaining': _r(plan.remaining),
        'carried_over_from_earlier': _r(plan.carriedOver),
      },
      'counts': {
        'active_emis_and_loans':
            borrowings.where((b) => !b.borrowing.isClosed).length,
        'active_subscriptions': subs.where((s) => s.isActive).length,
        'cards': cards.length,
      },
    };
  }

  Future<Map<String, dynamic>> _listEmis(String? status) async {
    final borrowings = await _borrowings();
    final want = (status ?? 'active').toLowerCase();
    final filtered = borrowings.where((s) {
      if (want == 'all') return true;
      if (want == 'closed') return s.borrowing.isClosed;
      return !s.borrowing.isClosed;
    });
    return {'emis': [for (final s in filtered) _emiBrief(s)]};
  }

  Future<Map<String, dynamic>> _getEmi(String? id) async {
    if (id == null || id.isEmpty) return {'error': 'Provide an EMI id.'};
    final match =
        (await _borrowings()).firstWhereOrNull((s) => s.borrowing.id == id);
    if (match == null) return {'error': 'No EMI/loan with id "$id".'};
    final b = match.borrowing;
    return {
      ..._emiBrief(match),
      'interest_rate_pct': b.interestRatePct,
      'tenure_months': b.tenureMonths,
      'total_repaid': _r(match.totalRepaid),
      'scheduled_total': _r(match.scheduledTotal),
      'wasted_so_far': _r(match.wastedSoFar),
      'projected_extra': _r(match.projectedExtra),
      if (b.notes != null) 'notes': b.notes,
    };
  }

  Map<String, dynamic> _emiBrief(BorrowingSummary s) {
    final b = s.borrowing;
    final next = s.nextDueInstallment;
    return {
      'id': b.id,
      'title': b.title,
      'lender': b.lenderName,
      'type': s.isEmi ? 'emi' : 'loan',
      'principal': _r(b.principal),
      'outstanding': _r(s.outstanding),
      'status': b.status.name,
      if (b.cardId != null) 'card_id': b.cardId,
      if (s.isEmi) ...{
        'installments_paid': s.paidInstallments,
        'installments_total': s.totalInstallments,
        'next_installment': next == null
            ? null
            : {'number': next.number, 'amount': _r(next.total), 'due': _d(next.dueDate)},
        if (s.overdueCount > 0) 'overdue_installments': s.overdueCount,
      },
      if (!s.isEmi) 'min_payment': _r(b.minPayment),
    };
  }

  Future<Map<String, dynamic>> _listSubscriptions(bool activeOnly) async {
    final subs = (await _subs()).where((s) => !activeOnly || s.isActive);
    return {
      'subscriptions': [for (final i in subs) _subBrief(i)],
      'total_monthly': _r(subs.fold<double>(
          0, (t, i) => t + (i.isActive ? i.monthlyAmount : 0))),
    };
  }

  Map<String, dynamic> _subBrief(RecurringItem i) => {
        'id': i.id,
        'title': i.title,
        'type': i.type.name,
        'amount': _r(i.amount),
        'frequency': i.frequency.name,
        'monthly_equivalent': _r(i.monthlyAmount),
        'next_due': _d(i.nextDueDate),
        'category': i.category,
        'card_id': i.cardId,
        'active': i.isActive,
      };

  Future<Map<String, dynamic>> _listCards() async {
    final cards = await _cardList();
    final statements = await _statements();
    return {'cards': [for (final c in cards) _cardBrief(c, statements)]};
  }

  Future<Map<String, dynamic>> _getCard(String? query) async {
    final resolved = await _resolveCard(query);
    if (resolved is ToolResult) {
      return jsonDecode(resolved.json) as Map<String, dynamic>;
    }
    final card = (resolved as _CardHit).card;
    final statements = await _statements();
    final borrowings = await _borrowings();
    final subs = await _subs();
    final latest = _latestStatement(card.id, statements);

    final linkedEmis = borrowings.where((s) =>
        s.isEmi &&
        CardCycle.linksTo(card,
            itemCardId: s.borrowing.cardId, itemLenderId: s.borrowing.lenderId));
    final linkedSubs = subs.where((i) => i.cardId == card.id);

    return {
      ..._cardBrief(card, statements),
      'latest_statement': latest == null
          ? null
          : {
              'cycle_month': _d(latest.cycleMonth),
              'statement_amount': _r(latest.statementAmount),
              'outstanding': _r(latest.remaining),
              'paid': _r(latest.paidAmount),
              'due_date': _d(latest.dueDate),
              'is_paid': latest.isPaid,
            },
      'linked_emis': [
        for (final s in linkedEmis) {'id': s.borrowing.id, 'title': s.borrowing.title},
      ],
      'linked_subscriptions': [
        for (final i in linkedSubs) {'id': i.id, 'title': i.title},
      ],
    };
  }

  Future<Map<String, dynamic>> _listStatements(String? query) async {
    final resolved = await _resolveCard(query);
    if (resolved is ToolResult) {
      return jsonDecode(resolved.json) as Map<String, dynamic>;
    }
    final card = (resolved as _CardHit).card;
    final statements = (await _statements())
        .where((st) => st.cardId == card.id)
        .toList()
      ..sort((a, b) => b.cycleMonth.compareTo(a.cycleMonth));
    return {
      'card': {'id': card.id, 'name': card.name},
      'statements': [
        for (final st in statements)
          {
            'cycle_month': _d(st.cycleMonth),
            'statement_amount': _r(st.statementAmount),
            'outstanding': _r(st.remaining),
            'paid': _r(st.paidAmount),
            'due_date': _d(st.dueDate),
            'is_paid': st.isPaid,
          },
      ],
    };
  }

  Future<Map<String, dynamic>> _upcomingDues(int withinDays) async {
    final borrowings = await _borrowings();
    final subs = await _subs();
    final cards = await _cardList();
    final statements = await _statements();
    final now = DateTime.now();
    final horizon = now.add(Duration(days: withinDays.clamp(1, 120)));

    final plan = MonthPlan.from(
      summaries: borrowings,
      items: subs,
      now: now,
      cards: cards,
      statements: statements,
    );

    final rows = [
      for (final d in plan.dues)
        if (!d.isPaid && d.dueDate != null && !d.dueDate!.isAfter(horizon))
          {
            'title': d.title,
            'kind': d.category.name,
            'amount': _r(d.remaining),
            'due': _d(d.dueDate!),
            'overdue': d.isOverdue(now),
          },
    ]..sort((a, b) => (a['due']! as String).compareTo(b['due']! as String));

    return {
      'within_days': withinDays,
      'as_of': _d(now),
      'dues': rows,
      'total': _r(rows.fold<double>(0, (t, r) => t + (r['amount']! as num))),
    };
  }

  // --- shared helpers --------------------------------------------------------

  Map<String, dynamic> _cardBrief(CardAccount c, List<CardStatement> statements) {
    final latest = _latestStatement(c.id, statements);
    final outstanding = latest?.remaining;
    final utilization =
        (c.creditLimit == null || c.creditLimit == 0 || outstanding == null)
            ? null
            : ((outstanding / c.creditLimit!) * 100).round();
    return {
      'id': c.id,
      'name': c.name,
      'nickname': c.nickname,
      'credit_limit': c.creditLimit == null ? null : _r(c.creditLimit!),
      'current_outstanding': outstanding == null ? null : _r(outstanding),
      'utilization_pct': utilization,
      'statement_day': c.statementDay,
      'due_day': c.dueDay,
      'active': c.isActive,
    };
  }

  CardStatement? _latestStatement(String cardId, List<CardStatement> all) {
    CardStatement? latest;
    for (final st in all) {
      if (st.cardId != cardId) continue;
      if (latest == null || st.cycleMonth.isAfter(latest.cycleMonth)) latest = st;
    }
    return latest;
  }

  List<CardAccount> _matchCards(List<CardAccount> cards, String query) {
    final q = query.trim().toLowerCase();
    final byId = cards.where((c) => c.id == query).toList();
    if (byId.isNotEmpty) return byId;
    return cards
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.nickname?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  ToolResult _res(Map<String, dynamic> m) => ToolResult(jsonEncode(m));
  ToolResult _err(String message) => ToolResult(jsonEncode({'error': message}));
  String _ok(String summary) => jsonEncode({'status': 'saved', 'summary': summary});
  String _fail(String note) => jsonEncode({'status': 'error', 'note': note});

  num _r(double v) => v.round();
  double? _num(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '').trim());
    return null;
  }

  String _amtStr(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Frequency _freq(String? name) =>
      Frequency.values.firstWhere((f) => f.name == name,
          orElse: () => Frequency.monthly);
  String? _freqName(dynamic v) {
    if (v == null) return 'monthly';
    final s = v.toString().toLowerCase();
    return _frequencies.contains(s) ? s : null;
  }

  DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
  DateTime? _firstOfMonth(DateTime? d) => d == null ? null : DateTime(d.year, d.month);

  String _d(DateTime x) =>
      '${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
}

/// A resolved single card match (internal to card resolution).
class _CardHit {
  _CardHit(this.card);
  final CardAccount card;
}
