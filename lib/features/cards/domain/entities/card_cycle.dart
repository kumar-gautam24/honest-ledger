import '../../../money_leak/domain/entities/borrowing_summary.dart';
import '../../../recurring/domain/entities/recurring_item.dart';
import 'card_account.dart';

/// Pure billing-cycle math for statement-level cards. No I/O, fully tested.
abstract final class CardCycle {
  /// Whether an obligation carrying [itemCardId] / [itemLenderId] belongs to
  /// [card]. An explicit card link wins; otherwise fall back to matching the
  /// lender (the pre-link behaviour — keeps existing borrowings folding). A
  /// null [itemLenderId] with no card link never matches (recurring items have
  /// no lender, so they fold only when explicitly linked).
  static bool linksTo(
    CardAccount card, {
    String? itemCardId,
    String? itemLenderId,
  }) {
    if (itemCardId != null) return itemCardId == card.id;
    return itemLenderId != null && itemLenderId == card.lenderId;
  }
  /// [day] in [year]/[month], clamped to the month's last day (a "31st"
  /// statement lands on the 28th/29th of February).
  static DateTime _clamped(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, lastDay));
  }

  /// The spend window billed on the statement generated in [cycleMonth]:
  /// `(previous statement date, this statement date]`.
  static (DateTime, DateTime) window({
    required DateTime cycleMonth,
    required int statementDay,
  }) {
    final end = _clamped(cycleMonth.year, cycleMonth.month, statementDay);
    final start =
        _clamped(cycleMonth.year, cycleMonth.month - 1, statementDay);
    return (start, end);
  }

  /// When the bill for [cycleMonth]'s statement is due: the first occurrence
  /// of [dueDay] strictly after the statement date.
  static DateTime dueDateFor({
    required DateTime cycleMonth,
    required int statementDay,
    required int dueDay,
  }) {
    final statementDate =
        _clamped(cycleMonth.year, cycleMonth.month, statementDay);
    final sameMonth = _clamped(cycleMonth.year, cycleMonth.month, dueDay);
    if (sameMonth.isAfter(statementDate)) return sameMonth;
    return _clamped(cycleMonth.year, cycleMonth.month + 1, dueDay);
  }

  /// The EMI part of a statement: installment totals of this card's
  /// borrowings (linked by card id, else lender id) due inside the cycle
  /// window. This is what makes "other spends" derivable from one entered
  /// number.
  static double emiPortion({
    required CardAccount card,
    required DateTime cycleMonth,
    required List<BorrowingSummary> summaries,
  }) {
    final (start, end) = window(
      cycleMonth: cycleMonth,
      statementDay: card.statementDay,
    );
    var total = 0.0;
    for (final s in summaries) {
      if (!s.isEmi) continue;
      if (!linksTo(
        card,
        itemCardId: s.borrowing.cardId,
        itemLenderId: s.borrowing.lenderId,
      )) {
        continue;
      }
      for (final e in s.schedule) {
        if (e.dueDate.isAfter(start) && !e.dueDate.isAfter(end)) {
          total += e.total;
        }
      }
    }
    return total;
  }

  /// The subscription/bill part of a statement: amounts of recurring items
  /// explicitly linked to this card whose occurrences fall inside the cycle
  /// window. Recurring items carry no lender, so only an explicit link folds.
  static double recurringPortion({
    required CardAccount card,
    required DateTime cycleMonth,
    required List<RecurringItem> items,
  }) {
    final (start, end) = window(
      cycleMonth: cycleMonth,
      statementDay: card.statementDay,
    );
    var total = 0.0;
    for (final i in items) {
      if (!i.isActive) continue;
      if (!linksTo(card, itemCardId: i.cardId)) continue;
      total += i.amount * _occurrencesIn(i, start, end);
    }
    return total;
  }

  /// How many occurrences of [i] fall inside `(start, end]`. Walks back to at
  /// or before [start], then steps forward counting hits. Guarded against a
  /// runaway loop.
  static int _occurrencesIn(RecurringItem i, DateTime start, DateTime end) {
    var d = i.nextDueDate;
    var guard = 0;
    while (d.isAfter(start) && guard++ < 10000) {
      d = i.frequency.retreat(d);
    }
    var count = 0;
    guard = 0;
    while (guard++ < 10000) {
      d = i.frequency.advance(d);
      if (d.isAfter(end)) break;
      if (d.isAfter(start)) count++;
    }
    return count;
  }

  /// What the statement holds beyond EMIs. Never negative.
  static double otherSpends(double statementAmount, double emiPortion) {
    final spends = statementAmount - emiPortion;
    return spends < 0 ? 0 : spends;
  }

  /// The cycle whose statement is the latest one already generated as of
  /// [now]: this month once the statement day has passed, else last month.
  static DateTime cycleFor({
    required DateTime now,
    required int statementDay,
  }) {
    final thisMonths = _clamped(now.year, now.month, statementDay);
    if (now.isBefore(thisMonths)) return DateTime(now.year, now.month - 1);
    return DateTime(now.year, now.month);
  }
}
