import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../money_leak/domain/entities/borrowing_summary.dart';
import '../../../recurring/domain/entities/recurring_item.dart';
import 'obligation_category.dart';

/// A moment the monthly outflow permanently drops: an EMI's last installment
/// clears or a flexible loan amortises to zero.
class ProjectionEvent {
  const ProjectionEvent({
    required this.freedFrom,
    required this.title,
    required this.monthlyFreed,
    required this.category,
  });

  /// First month that no longer carries the payment.
  final DateTime freedFrom;
  final String title;

  /// The monthly amount released.
  final double monthlyFreed;
  final ObligationCategory category;
}

/// One future month's projected outflow.
class MonthProjection {
  const MonthProjection({
    required this.month,
    required this.byCategory,
    required this.total,
  });

  final DateTime month;
  final Map<ObligationCategory, double> byCategory;
  final double total;
}

/// Month-by-month outflow over the coming horizon: remaining EMI installments,
/// flexible-loan plans until they amortise, and recurring items assumed to
/// continue — with the moments money frees up called out as [events].
class OutflowProjection {
  const OutflowProjection({
    required this.months,
    required this.events,
    required this.maxMonthTotal,
  });

  /// Bucket 0 is the current month.
  final List<MonthProjection> months;

  /// Sorted by [ProjectionEvent.freedFrom].
  final List<ProjectionEvent> events;

  /// Largest bucket total — for scaling the timeline bars.
  final double maxMonthTotal;

  factory OutflowProjection.from({
    required List<BorrowingSummary> summaries,
    required List<RecurringItem> items,
    required DateTime now,
    int horizonMonths = AppConstants.projectionHorizonMonths,
  }) {
    final start = now.monthStart;
    final buckets = List.generate(
      horizonMonths,
      (i) => <ObligationCategory, double>{},
    );
    final events = <ProjectionEvent>[];

    /// Bucket index for [date], or null when outside the horizon.
    int? bucketOf(DateTime date) {
      final i =
          (date.year - start.year) * 12 + (date.month - start.month);
      return i >= 0 && i < horizonMonths ? i : null;
    }

    void add(int bucket, ObligationCategory category, double amount) {
      if (amount <= 0) return;
      buckets[bucket]
          .update(category, (v) => v + amount, ifAbsent: () => amount);
    }

    for (final s in summaries) {
      final b = s.borrowing;
      if (b.isClosed) continue;
      if (s.isEmi) {
        // Past-due unpaid installments stay carry-over, not future outflow.
        for (final e in s.schedule) {
          if (s.isInstallmentPaid(e.number)) continue;
          final i = bucketOf(e.dueDate);
          if (i != null) add(i, ObligationCategory.emi, e.total);
        }
        final last = s.schedule.last;
        if (!s.isInstallmentPaid(last.number)) {
          final i = bucketOf(last.dueDate);
          if (i != null && i + 1 < horizonMonths) {
            events.add(ProjectionEvent(
              freedFrom: start.addMonths(i + 1),
              title: b.title,
              monthlyFreed: last.total,
              category: ObligationCategory.emi,
            ));
          }
        }
      } else if (s.outstanding > 0 && b.minPayment > 0) {
        final plan = FinanceMath.flexiblePaymentPlan(
          principal: s.outstanding,
          annualRatePct: b.interestRatePct,
          monthlyPayment: b.minPayment,
        );
        if (plan == null) {
          // Never amortises — the payment is a fixture of every month.
          for (var i = 0; i < horizonMonths; i++) {
            add(i, ObligationCategory.loan, b.minPayment);
          }
        } else {
          for (var k = 0; k < plan.length && k < horizonMonths; k++) {
            add(k, ObligationCategory.loan, plan[k]);
          }
          if (plan.length < horizonMonths) {
            events.add(ProjectionEvent(
              freedFrom: start.addMonths(plan.length),
              title: b.title,
              monthlyFreed: b.minPayment,
              category: ObligationCategory.loan,
            ));
          }
        }
      }
    }

    final horizonEnd = start.addMonths(horizonMonths);
    for (final item in items) {
      if (!item.isActive) continue;
      var d = item.nextDueDate;
      while (d.isBefore(horizonEnd)) {
        final i = bucketOf(d);
        if (i != null) add(i, item.type.obligationCategory, item.amount);
        d = item.frequency.advance(d);
      }
    }

    events.sort((a, b) => a.freedFrom.compareTo(b.freedFrom));
    final months = [
      for (var i = 0; i < horizonMonths; i++)
        MonthProjection(
          month: start.addMonths(i),
          byCategory: Map.unmodifiable(buckets[i]),
          total: buckets[i].values.fold(0, (s, v) => s + v),
        ),
    ];
    var max = 0.0;
    for (final m in months) {
      if (m.total > max) max = m.total;
    }
    return OutflowProjection(
      months: List.unmodifiable(months),
      events: List.unmodifiable(events),
      maxMonthTotal: max,
    );
  }
}
