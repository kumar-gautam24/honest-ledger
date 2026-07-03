import '../../../../core/utils/date_x.dart';
import '../../../cards/domain/entities/card_account.dart';
import '../../../cards/domain/entities/card_cycle.dart';
import '../../../cards/domain/entities/card_statement.dart';
import '../../../money_leak/domain/entities/borrowing_summary.dart';
import '../../../recurring/domain/entities/recurring_item.dart';
import 'obligation_category.dart';

/// Where a [MonthDue] row comes from.
enum MonthDueSource { emiInstallment, flexiblePlan, recurring, cardBill }

/// One line of the current month's statement: something due this calendar
/// month, with how much of it is already settled.
class MonthDue {
  const MonthDue({
    required this.sourceId,
    required this.source,
    required this.category,
    required this.title,
    required this.amountDue,
    required this.amountPaid,
    this.dueDate,
    this.noPlan = false,
    this.installmentNo,
    this.installmentCount,
    this.foldedEmiAmount = 0,
  });

  /// Borrowing or recurring-item id — for navigation.
  final String sourceId;
  final MonthDueSource source;
  final ObligationCategory category;
  final String title;

  /// Null for a flexible loan's plan — payable any day this month.
  final DateTime? dueDate;

  final double amountDue;

  /// 0 or the full amount for EMI installments and recurring occurrences; the
  /// month's ledger sum for a flexible loan (may exceed [amountDue]).
  final double amountPaid;

  /// A flexible loan still owing but with no planned monthly payment set.
  final bool noPlan;

  /// `4` of `12` for an EMI installment row; null otherwise.
  final int? installmentNo;
  final int? installmentCount;

  /// For a card-bill row: the slice of [amountDue] that is EMI installments
  /// folded in from this card's borrowings ("incl. ₹X EMIs"). The folded
  /// installments get no rows of their own — a rupee is counted once.
  final double foldedEmiAmount;

  double get remaining =>
      (amountDue - amountPaid).clamp(0, double.infinity);

  bool get isPaid => !noPlan && amountDue > 0 && remaining <= 0.005;

  bool isOverdue(DateTime now) =>
      dueDate != null && !isPaid && dueDate!.isBefore(now.dateOnly);
}

/// The current calendar month as a statement: what's due, what's been paid,
/// what remains — plus anything overdue carried in from earlier months.
class MonthPlan {
  const MonthPlan({
    required this.month,
    required this.dues,
    required this.totalDue,
    required this.totalPaid,
    required this.remaining,
    required this.carriedOver,
  });

  /// First day of the month this plan covers.
  final DateTime month;

  /// Sorted: dated dues ascending, undated flexible plans after, noPlan last.
  final List<MonthDue> dues;

  /// Σ amountDue ([MonthDue.noPlan] rows excluded).
  final double totalDue;

  /// Σ per-row paid, capped at each row's due — progress never overshoots.
  final double totalPaid;

  final double remaining;

  /// Unpaid money from before this month: past-due EMI installments and
  /// recurring items whose due date was never advanced. A separate statement
  /// line, deliberately not mixed into [totalDue].
  final double carriedOver;

  double get progress =>
      totalDue <= 0 ? 0 : (totalPaid / totalDue).clamp(0, 1);

  factory MonthPlan.from({
    required List<BorrowingSummary> summaries,
    required List<RecurringItem> items,
    required DateTime now,
    List<CardAccount> cards = const [],
    List<CardStatement> statements = const [],
  }) {
    final monthStart = now.monthStart;
    final monthEnd = monthStart.addMonths(1);
    bool inMonth(DateTime d) =>
        !d.isBefore(monthStart) && d.isBefore(monthEnd);

    final dues = <MonthDue>[];
    var carriedOver = 0.0;

    // Cycle windows of every entered statement, keyed by the card's lender:
    // an EMI installment billed inside a window is paid through that card's
    // bill, so it never gets a row of its own.
    final cardById = {for (final c in cards) c.id: c};
    final windowsByLender = <String, List<(DateTime, DateTime)>>{};
    for (final st in statements) {
      final card = cardById[st.cardId];
      if (card == null) continue;
      windowsByLender.putIfAbsent(card.lenderId, () => []).add(
            CardCycle.window(
              cycleMonth: st.cycleMonth,
              statementDay: card.statementDay,
            ),
          );
    }
    bool billedOnACard(String? lenderId, DateTime dueDate) {
      final windows = windowsByLender[lenderId];
      if (windows == null) return false;
      return windows.any(
        (w) => dueDate.isAfter(w.$1) && !dueDate.isAfter(w.$2),
      );
    }

    for (final st in statements) {
      final card = cardById[st.cardId];
      if (card == null || !inMonth(st.dueDate)) continue;
      dues.add(MonthDue(
        sourceId: card.id,
        source: MonthDueSource.cardBill,
        category: ObligationCategory.card,
        title: card.name,
        dueDate: st.dueDate,
        amountDue: st.statementAmount,
        amountPaid: st.paidAmount,
        foldedEmiAmount: CardCycle.emiPortion(
          card: card,
          cycleMonth: st.cycleMonth,
          summaries: summaries,
        ),
      ));
    }

    for (final s in summaries) {
      final b = s.borrowing;
      if (s.isEmi) {
        for (final e in s.schedule) {
          final paid = s.isInstallmentPaid(e.number);
          if (billedOnACard(b.lenderId, e.dueDate)) continue;
          if (inMonth(e.dueDate)) {
            // A closed (foreclosed) EMI keeps what was actually paid this
            // month but owes nothing further.
            if (b.isClosed && !paid) continue;
            dues.add(MonthDue(
              sourceId: b.id,
              source: MonthDueSource.emiInstallment,
              category: ObligationCategory.emi,
              title: b.title,
              dueDate: e.dueDate,
              amountDue: e.total,
              amountPaid: paid ? e.total : 0,
              installmentNo: e.number,
              installmentCount: s.totalInstallments,
            ));
          } else if (!b.isClosed && !paid && e.dueDate.isBefore(monthStart)) {
            carriedOver += e.total;
          }
        }
      } else if (!b.isClosed && s.outstanding > 0) {
        final paidThisMonth = s.repayments
            .where((r) => inMonth(r.date))
            .fold<double>(0, (sum, r) => sum + r.amount);
        dues.add(MonthDue(
          sourceId: b.id,
          source: MonthDueSource.flexiblePlan,
          category: ObligationCategory.loan,
          title: b.title,
          amountDue: b.minPayment,
          amountPaid: paidThisMonth,
          noPlan: b.minPayment <= 0,
        ));
      }
    }

    for (final i in items) {
      if (!i.isActive) continue;
      MonthDue occurrence(DateTime date, {required bool paid}) => MonthDue(
            sourceId: i.id,
            source: MonthDueSource.recurring,
            category: i.type.obligationCategory,
            title: i.title,
            dueDate: date,
            amountDue: i.amount,
            amountPaid: paid ? i.amount : 0,
          );

      if (i.nextDueDate.isBefore(monthStart)) {
        // Never advanced past an earlier month — the whole item is in arrears.
        carriedOver += i.amount;
        continue;
      }
      // Upcoming occurrences that land inside this month.
      var d = i.nextDueDate;
      while (d.isBefore(monthEnd)) {
        if (inMonth(d)) dues.add(occurrence(d, paid: false));
        d = i.frequency.advance(d);
      }
      // Occurrences already rolled past = paid this month (inferred), bounded
      // by when the item was created.
      var prev = i.frequency.retreat(i.nextDueDate);
      while (inMonth(prev) && !prev.isBefore(i.createdAt.dateOnly)) {
        dues.add(occurrence(prev, paid: true));
        prev = i.frequency.retreat(prev);
      }
    }

    dues.sort((a, b) {
      int rank(MonthDue d) => d.noPlan ? 2 : (d.dueDate == null ? 1 : 0);
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      if (a.dueDate == null || b.dueDate == null) return 0;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    var totalDue = 0.0, totalPaid = 0.0;
    for (final d in dues) {
      if (d.noPlan) continue;
      totalDue += d.amountDue;
      totalPaid += d.amountPaid > d.amountDue ? d.amountDue : d.amountPaid;
    }

    return MonthPlan(
      month: monthStart,
      dues: List.unmodifiable(dues),
      totalDue: totalDue,
      totalPaid: totalPaid,
      remaining: (totalDue - totalPaid).clamp(0, double.infinity),
      carriedOver: carriedOver,
    );
  }
}
