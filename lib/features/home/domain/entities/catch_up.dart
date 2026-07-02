import '../../../../core/utils/date_x.dart';
import '../../../money_leak/domain/entities/borrowing_summary.dart';
import '../../../recurring/domain/entities/recurring_item.dart';

/// Where a missed occurrence comes from.
enum CatchUpSource { emiInstallment, recurring }

/// One payment that went past before this month without being logged.
class CatchUpItem {
  const CatchUpItem({
    required this.sourceId,
    required this.source,
    required this.title,
    required this.dueDate,
    required this.amount,
    this.installmentNo,
  });

  /// Borrowing or recurring-item id.
  final String sourceId;
  final CatchUpSource source;
  final String title;
  final DateTime dueDate;
  final double amount;

  /// Set for EMI installments — needed to log the repayment against the row.
  final int? installmentNo;
}

/// Everything that went past before the current month while the app wasn't
/// told: unpaid EMI installments and recurring cycles never advanced. Drives
/// the "while you were away" card — payments here are manual, so the ledger
/// must offer a one-tap way back to the truth.
///
/// Flexible loans are deliberately absent: they have no fixed schedule, so
/// there is no objective "missed" occurrence to confirm.
class CatchUp {
  const CatchUp({
    required this.items,
    required this.total,
    required this.emiCount,
    required this.recurringCount,
  });

  /// Oldest first.
  final List<CatchUpItem> items;
  final double total;
  final int emiCount;
  final int recurringCount;

  bool get isEmpty => items.isEmpty;

  factory CatchUp.from({
    required List<BorrowingSummary> summaries,
    required List<RecurringItem> items,
    required DateTime now,
  }) {
    final monthStart = now.monthStart;
    final found = <CatchUpItem>[];

    for (final s in summaries) {
      if (!s.isEmi || s.borrowing.isClosed) continue;
      for (final e in s.schedule) {
        if (s.isInstallmentPaid(e.number)) continue;
        if (!e.dueDate.isBefore(monthStart)) continue;
        found.add(CatchUpItem(
          sourceId: s.borrowing.id,
          source: CatchUpSource.emiInstallment,
          title: s.borrowing.title,
          dueDate: e.dueDate,
          amount: e.total,
          installmentNo: e.number,
        ));
      }
    }

    for (final i in items) {
      if (!i.isActive) continue;
      var d = i.nextDueDate;
      while (d.isBefore(monthStart)) {
        found.add(CatchUpItem(
          sourceId: i.id,
          source: CatchUpSource.recurring,
          title: i.title,
          dueDate: d,
          amount: i.amount,
        ));
        d = i.frequency.advance(d);
      }
    }

    found.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    var emi = 0, recurring = 0;
    for (final item in found) {
      if (item.source == CatchUpSource.emiInstallment) {
        emi++;
      } else {
        recurring++;
      }
    }
    return CatchUp(
      items: List.unmodifiable(found),
      total: found.fold(0, (s, i) => s + i.amount),
      emiCount: emi,
      recurringCount: recurring,
    );
  }
}
