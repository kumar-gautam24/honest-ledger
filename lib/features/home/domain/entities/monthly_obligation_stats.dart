import '../../../money_leak/domain/entities/borrowing_summary.dart';
import '../../../recurring/domain/entities/recurring_item.dart';
import 'obligation_category.dart';

/// The true committed monthly outgo across every obligation: fixed-EMI
/// installments, flexible-loan planned payments, and recurring items normalised
/// to a monthly figure. Drives the home "PER MONTH" statement line.
class MonthlyObligationStats {
  const MonthlyObligationStats({
    required this.byCategory,
    required this.total,
    required this.unplannedLoanCount,
  });

  /// Monthly outgo split by kind. Categories with nothing owing are absent.
  final Map<ObligationCategory, double> byCategory;

  /// Sum across [byCategory].
  final double total;

  /// Flexible loans still owing but with no planned monthly payment set — they
  /// contribute nothing to [total], so the UI should surface them.
  final int unplannedLoanCount;

  static const empty = MonthlyObligationStats(
    byCategory: {},
    total: 0,
    unplannedLoanCount: 0,
  );

  factory MonthlyObligationStats.from(
    List<BorrowingSummary> summaries,
    List<RecurringItem> items,
  ) {
    final byCategory = <ObligationCategory, double>{};
    var unplanned = 0;

    void add(ObligationCategory category, double amount) {
      if (amount <= 0) return;
      byCategory.update(category, (v) => v + amount, ifAbsent: () => amount);
    }

    for (final s in summaries) {
      if (s.borrowing.isClosed) continue;
      if (s.isEmi) {
        // The exact next charge, not a schedule average.
        final next = s.nextDueInstallment;
        if (next != null) add(ObligationCategory.emi, next.total);
      } else if (s.outstanding > 0) {
        if (s.borrowing.minPayment > 0) {
          add(ObligationCategory.loan, s.borrowing.minPayment);
        } else {
          unplanned++;
        }
      }
    }

    for (final i in items) {
      if (!i.isActive) continue;
      add(i.type.obligationCategory, i.monthlyAmount);
    }

    return MonthlyObligationStats(
      byCategory: byCategory,
      total: byCategory.values.fold(0, (s, v) => s + v),
      unplannedLoanCount: unplanned,
    );
  }
}
