import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/date_x.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/home/domain/entities/obligation_category.dart';
import 'package:recurring/features/home/domain/entities/outflow_projection.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';

import 'fixtures.dart';

void main() {
  final now = DateTime(2026, 7, 15);

  group('OutflowProjection — fixed EMIs', () {
    test('remaining installments fill their buckets and free up after the last', () {
      // Started 1 Apr, 12k @ 0% × 12 → last three unpaid: 1 Jul, 1 Aug, 1 Sep.
      final s = emiSummary(
        startDate: DateTime(2025, 9, 1),
        paidInstallments: 9,
      );
      final p = OutflowProjection.from(
        summaries: [s],
        items: const [],
        now: now,
      );
      expect(p.months, hasLength(12));
      expect(p.months[0].month, DateTime(2026, 7));
      // Unpaid #10 (1 Jul), #11 (1 Aug), #12 (1 Sep).
      expect(p.months[0].total, closeTo(1000, 0.001));
      expect(p.months[1].total, closeTo(1000, 0.001));
      expect(p.months[2].total, closeTo(1000, 0.001));
      expect(p.months[3].total, 0);
      expect(p.events, hasLength(1));
      final e = p.events.single;
      expect(e.freedFrom, DateTime(2026, 10));
      expect(e.monthlyFreed, closeTo(1000, 0.001));
      expect(e.category, ObligationCategory.emi);
    });

    test('installments overdue from before the horizon are not rescheduled forward', () {
      // Started 1 Mar 2026, nothing paid: #1–#4 due Apr–Jul. Only #4 (1 Jul)
      // through #12 (1 Mar 2027) land in buckets; Apr–Jun stay carry-over.
      final s = emiSummary(startDate: DateTime(2026, 3, 1));
      final p = OutflowProjection.from(
        summaries: [s],
        items: const [],
        now: now,
      );
      final total = p.months.fold<double>(0, (sum, m) => sum + m.total);
      expect(total, closeTo(9000, 0.001)); // #4..#12 only
      expect(p.months[0].total, closeTo(1000, 0.001));
    });
  });

  group('OutflowProjection — flexible loans', () {
    test('a clearing loan fills buckets until payoff with a residual last month', () {
      final s = loanSummary(
        startDate: DateTime(2026, 7, 1),
        principal: 10000,
        ratePct: 30,
        minPayment: 2000,
      );
      final plan = FinanceMath.flexiblePaymentPlan(
        principal: s.outstanding,
        annualRatePct: 30,
        monthlyPayment: 2000,
      )!;
      final p = OutflowProjection.from(
        summaries: [s],
        items: const [],
        now: now,
      );
      for (var i = 0; i < plan.length; i++) {
        expect(p.months[i].total, closeTo(plan[i], 0.001));
      }
      expect(p.months[plan.length].total, 0);
      expect(p.events, hasLength(1));
      expect(p.events.single.freedFrom, DateTime(2026, 7).addMonths(plan.length));
      expect(p.events.single.monthlyFreed, 2000);
      expect(p.events.single.category, ObligationCategory.loan);
    });

    test('a never-clearing loan fills every bucket and emits no event', () {
      final s = loanSummary(
        startDate: DateTime(2026, 7, 1),
        principal: 10000,
        ratePct: 36,
        minPayment: 300,
      );
      final p = OutflowProjection.from(
        summaries: [s],
        items: const [],
        now: now,
      );
      for (final m in p.months) {
        expect(m.total, 300);
      }
      expect(p.events, isEmpty);
    });

    test('a loan without a planned payment contributes nothing', () {
      final s = loanSummary(startDate: DateTime(2026, 7, 1), minPayment: 0);
      final p = OutflowProjection.from(
        summaries: [s],
        items: const [],
        now: now,
      );
      expect(p.months.every((m) => m.total == 0), isTrue);
    });
  });

  group('OutflowProjection — recurring items', () {
    test('a monthly item lands in every bucket at its actual amount', () {
      final item = recurringItem(nextDueDate: DateTime(2026, 7, 20));
      final p = OutflowProjection.from(
        summaries: const [],
        items: [item],
        now: now,
      );
      for (final m in p.months) {
        expect(m.total, closeTo(499, 0.001));
        expect(m.byCategory[ObligationCategory.subscription], closeTo(499, 0.001));
      }
    });

    test('a yearly item spikes exactly its month', () {
      final item = recurringItem(
        amount: 12000,
        frequency: Frequency.yearly,
        nextDueDate: DateTime(2026, 11, 10),
      );
      final p = OutflowProjection.from(
        summaries: const [],
        items: [item],
        now: now,
      );
      expect(p.months[4].month, DateTime(2026, 11));
      expect(p.months[4].total, 12000);
      final others = [...p.months]..removeAt(4);
      expect(others.every((m) => m.total == 0), isTrue);
    });

    test('occurrences before the current month are skipped, not rescheduled', () {
      final item = recurringItem(nextDueDate: DateTime(2026, 6, 10));
      final p = OutflowProjection.from(
        summaries: const [],
        items: [item],
        now: now,
      );
      // June's missed occurrence is carry-over territory; buckets start July.
      expect(p.months[0].total, closeTo(499, 0.001));
      final total = p.months.fold<double>(0, (sum, m) => sum + m.total);
      expect(total, closeTo(499.0 * 12, 0.001));
    });
  });

  test('maxMonthTotal is the largest bucket', () {
    final p = OutflowProjection.from(
      summaries: const [],
      items: [
        recurringItem(nextDueDate: DateTime(2026, 7, 20)),
        recurringItem(
          id: 'rec-2',
          amount: 12000,
          frequency: Frequency.yearly,
          nextDueDate: DateTime(2026, 11, 10),
        ),
      ],
      now: now,
    );
    expect(p.maxMonthTotal, closeTo(12499, 0.001));
  });
}
