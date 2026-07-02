import '../../../money_leak/domain/entities/borrowing_summary.dart';
import 'card_account.dart';

/// Pure billing-cycle math for statement-level cards. No I/O, fully tested.
abstract final class CardCycle {
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
  /// borrowings (matched by lender id) due inside the cycle window. This is
  /// what makes "other spends" derivable from one entered number.
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
      if (!s.isEmi || s.borrowing.lenderId != card.lenderId) continue;
      for (final e in s.schedule) {
        if (e.dueDate.isAfter(start) && !e.dueDate.isAfter(end)) {
          total += e.total;
        }
      }
    }
    return total;
  }

  /// What the statement holds beyond EMIs. Never negative.
  static double otherSpends(double statementAmount, double emiPortion) {
    final spends = statementAmount - emiPortion;
    return spends < 0 ? 0 : spends;
  }
}
