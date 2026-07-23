import 'dart:convert';

import '../../../core/utils/money_formatter.dart';
import '../domain/entities/ai_chat_response.dart';
import '../domain/entities/ai_message.dart';
import 'ai_service.dart';

/// A local, no-network stand-in for a real model, used while no LLM is wired
/// (see [kAssistantDemoMode]). It plays the same tool-calling protocol a real
/// model would: on a user message it picks a tool to call; once the tool result
/// comes back (real data, run by the ToolExecutor) it writes a short answer.
///
/// It is intentionally simple keyword routing — good enough to *feel* the flow
/// (real read answers, a real confirm card for writes), not a real assistant.
class DemoAiService implements AiService {
  int _n = 0;

  @override
  Future<AiChatResponse> chat({
    required List<AiChatMessage> messages,
    List<AiToolDef> tools = const [],
    String? system,
    int maxTokens = 1024,
  }) async {
    // A tiny delay so the "Thinking…" state is visible, like a real call.
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final last = messages.isEmpty ? null : messages.last;
    if (last?.role == AiRole.tool) {
      return AiChatResponse(text: _answer(last!.content), stopReason: 'end_turn');
    }

    final userText = messages.lastWhere(
      (m) => m.role == AiRole.user,
      orElse: () => const AiChatMessage.user(''),
    ).content ??
        '';
    return AiChatResponse(
      toolCalls: [_route(userText)],
      stopReason: 'tool_use',
    );
  }

  // --- routing: user message -> a tool call ---------------------------------

  AiToolCall _route(String text) {
    final lower = text.toLowerCase();
    final id = 'demo_${_n++}';

    // Writes first (more specific).
    if (_has(lower, ['add', 'create']) &&
        (lower.contains('subscription') || lower.contains('subscribe') ||
            _amount(text) != null)) {
      return AiToolCall(id: id, name: 'propose_add_subscription', arguments: {
        'title': _titleFor(text),
        'amount': _amount(text) ?? 0,
        'frequency': _frequency(lower),
      });
    }
    if (_has(lower, ['set', 'update']) &&
        (lower.contains('statement') || lower.contains('outstanding'))) {
      return AiToolCall(id: id, name: 'propose_set_card_statement', arguments: {
        'card': _cardToken(text) ?? '',
        'statement_amount': _amount(text) ?? 0,
      });
    }

    // Reads.
    if (lower.contains('card')) {
      final card = _cardToken(text);
      if (card != null) {
        return AiToolCall(id: id, name: 'get_card', arguments: {'card': card});
      }
      return AiToolCall(id: id, name: 'list_cards');
    }
    if (lower.contains('subscription') || lower.contains('subs')) {
      return AiToolCall(id: id, name: 'list_subscriptions');
    }
    if (lower.contains('emi') || lower.contains('loan')) {
      return AiToolCall(id: id, name: 'list_emis');
    }
    if (lower.contains('due') || lower.contains('upcoming') || lower.contains('soon')) {
      return AiToolCall(id: id, name: 'get_upcoming_dues', arguments: {'within_days': 30});
    }
    return AiToolCall(id: id, name: 'get_finance_overview');
  }

  // --- answering: tool result -> a short reply ------------------------------

  String _answer(String? resultJson) {
    final Map<String, dynamic> d;
    try {
      d = (jsonDecode(resultJson ?? '{}') as Map).cast<String, dynamic>();
    } catch (_) {
      return 'Done.';
    }

    // Write outcomes.
    if (d['status'] == 'saved') {
      return 'Done — ${d['summary'] ?? 'saved'}';
    }
    if (d['status'] == 'declined') return 'No problem — I left it unchanged.';
    if (d['status'] == 'error') return "That didn't save — please try again.";
    if (d['error'] is String) return d['error'] as String;
    if (d['ambiguous'] == true) {
      final names = ((d['matches'] as List?) ?? [])
          .map((m) => (m as Map)['name'])
          .join(', ');
      return 'You have more than one card matching that — $names. Which one?';
    }

    // Read shapes.
    if (d.containsKey('this_month')) return _overview(d);
    if (d.containsKey('cards')) return _cards(d['cards'] as List);
    if (d.containsKey('subscriptions')) {
      return _subs(d['subscriptions'] as List, d['total_monthly']);
    }
    if (d.containsKey('emis')) return _emis(d['emis'] as List);
    if (d.containsKey('dues')) return _dues(d);
    if (d.containsKey('latest_statement')) return _card(d);
    return 'Here you go.';
  }

  String _overview(Map<String, dynamic> d) {
    final m = (d['this_month'] as Map).cast<String, dynamic>();
    final total = _money(d['monthly_committed_total']);
    final remaining = _money(m['remaining']);
    final due = _money(m['due']);
    return 'This month: $due due, $remaining still to pay. '
        'You commit about $total a month across your obligations.';
  }

  String _cards(List cards) {
    if (cards.isEmpty) return "You don't have any cards yet.";
    final lines = cards.map((c) {
      final m = (c as Map).cast<String, dynamic>();
      final out = m['current_outstanding'];
      final util = m['utilization_pct'];
      final tail = out == null
          ? 'no statement yet'
          : '${_money(out)} outstanding${util == null ? '' : ' ($util%)'}';
      return '• ${m['name']} — $tail';
    }).join('\n');
    return 'You have ${cards.length} card${cards.length == 1 ? '' : 's'}:\n$lines';
  }

  String _card(Map<String, dynamic> d) {
    final name = d['name'];
    final out = d['current_outstanding'];
    final util = d['utilization_pct'];
    if (out == null) return '$name has no statement entered yet.';
    final st = d['latest_statement'] as Map?;
    final due = st?['due_date'];
    return '$name: ${_money(out)} outstanding'
        '${util == null ? '' : ' ($util% of your limit)'}'
        '${due == null ? '' : ', due $due'}.';
  }

  String _subs(List subs, Object? totalMonthly) {
    if (subs.isEmpty) return "You don't have any active subscriptions.";
    final names = subs.map((s) => (s as Map)['title']).join(', ');
    return '${subs.length} active subscription${subs.length == 1 ? '' : 's'} '
        '— about ${_money(totalMonthly)} a month: $names.';
  }

  String _emis(List emis) {
    if (emis.isEmpty) return "You don't have any EMIs or loans.";
    final lines = emis.map((e) {
      final m = (e as Map).cast<String, dynamic>();
      return '• ${m['title']} — ${_money(m['outstanding'])} outstanding';
    }).join('\n');
    return 'Your EMIs & loans:\n$lines';
  }

  String _dues(Map<String, dynamic> d) {
    final rows = (d['dues'] as List?) ?? [];
    if (rows.isEmpty) return 'Nothing due in the next ${d['within_days']} days.';
    final lines = rows.map((r) {
      final m = (r as Map).cast<String, dynamic>();
      return '• ${m['title']} — ${_money(m['amount'])} on ${m['due']}';
    }).join('\n');
    return 'Due soon (${_money(d['total'])} total):\n$lines';
  }

  // --- small helpers ---------------------------------------------------------

  bool _has(String text, List<String> anyOf) =>
      anyOf.any((w) => text.contains(w));

  double? _amount(String text) {
    final m = RegExp(r'(\d[\d,]*(?:\.\d+)?)').firstMatch(text);
    if (m == null) return null;
    return double.tryParse(m.group(1)!.replaceAll(',', ''));
  }

  String _frequency(String lower) {
    if (lower.contains('week')) return 'weekly';
    if (lower.contains('year') || lower.contains('annual')) return 'yearly';
    if (lower.contains('quarter')) return 'quarterly';
    return 'monthly';
  }

  /// The subscription name — the word(s) after "called"/"for", else a default.
  String _titleFor(String text) {
    for (final kw in ['called ', 'for ', 'named ']) {
      final i = text.toLowerCase().indexOf(kw);
      if (i >= 0) {
        final rest = text.substring(i + kw.length).trim();
        final word = rest.split(RegExp(r'[\s,.]')).firstWhere(
              (w) => w.isNotEmpty,
              orElse: () => '',
            );
        if (word.isNotEmpty && double.tryParse(word) == null) return word;
      }
    }
    return 'New subscription';
  }

  /// A card name/token — the capitalised word before "card"/"statement", or the
  /// word after "my". Null falls back to listing cards.
  String? _cardToken(String text) {
    final words = text.split(RegExp(r'\s+'));
    for (var i = 0; i < words.length; i++) {
      final w = words[i].replaceAll(RegExp(r'[^A-Za-z]'), '');
      if (w.isEmpty) continue;
      final next = i + 1 < words.length ? words[i + 1].toLowerCase() : '';
      if ((next.startsWith('card') || next.startsWith('statement')) &&
          w[0] == w[0].toUpperCase()) {
        return w;
      }
      if (words[i].toLowerCase() == 'my' && i + 1 < words.length) {
        final cand = words[i + 1].replaceAll(RegExp(r'[^A-Za-z]'), '');
        if (cand.isNotEmpty && cand[0] == cand[0].toUpperCase()) return cand;
      }
    }
    return null;
  }

  String _money(Object? v) {
    final n = v is num ? v : num.tryParse('$v') ?? 0;
    return Money.format(n);
  }
}
