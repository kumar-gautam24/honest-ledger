import '../../../core/utils/date_x.dart';
import '../../cards/domain/entities/card_account.dart';
import '../../cards/domain/entities/card_statement.dart';
import '../../money_leak/domain/entities/borrowing.dart';
import '../../money_leak/domain/entities/borrowing_summary.dart';
import '../../recurring/domain/entities/recurring_item.dart';
import '../domain/entities/obligation_category.dart';

export '../domain/entities/obligation_category.dart';

/// Home filter chips. [all] matches everything; the rest map 1:1 to a category.
enum ObligationFilter {
  all('All'),
  emi('EMIs'),
  loan('Loans'),
  subscription('Subs'),
  bill('Bills'),
  card('Cards');

  const ObligationFilter(this.label);
  final String label;

  bool accepts(ObligationCategory category) =>
      this == ObligationFilter.all || name == category.name;
}

/// Sort key for items with no real due date (flexible loans still owing) — after
/// everything dated, before anything settled/paused.
const double _kUndated = 500000;

/// Sort key for settled / paused items — always last.
const double _kSettled = 1000000;

/// A single row on the unified home feed. Borrowings and recurring items are
/// wrapped so they can share one sorted, filterable list while each still
/// renders with its own widget (pattern-matched on the concrete type).
sealed class ObligationView {
  const ObligationView();

  ObligationCategory get category;

  /// Lower sorts first: overdue and soonest-due bubble to the top.
  double get sortKey;
}

class BorrowingObligation extends ObligationView {
  const BorrowingObligation(this.summary);

  final BorrowingSummary summary;

  @override
  ObligationCategory get category =>
      summary.borrowing.kind == BorrowingKind.fixedEmi
          ? ObligationCategory.emi
          : ObligationCategory.loan;

  @override
  double get sortKey {
    if (summary.borrowing.isClosed) return _kSettled;
    final next = summary.nextDueInstallment;
    if (next != null) return next.dueDate.daysFromNow.toDouble();
    // Flexible loan (or fully-scheduled EMI): urgent while it still owes.
    return summary.outstanding > 0 ? _kUndated : _kSettled;
  }
}

/// An unpaid card bill riding the feed until it's settled.
class CardBillObligation extends ObligationView {
  const CardBillObligation({required this.card, required this.statement});

  final CardAccount card;
  final CardStatement statement;

  @override
  ObligationCategory get category => ObligationCategory.card;

  @override
  double get sortKey => statement.isPaid
      ? _kSettled
      : statement.dueDate.daysFromNow.toDouble();
}

class RecurringObligation extends ObligationView {
  const RecurringObligation(this.item);

  final RecurringItem item;

  @override
  ObligationCategory get category => item.type.obligationCategory;

  @override
  double get sortKey =>
      item.isActive ? item.nextDueDate.daysFromNow.toDouble() : _kSettled;
}
