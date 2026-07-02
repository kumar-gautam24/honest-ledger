import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/home/domain/entities/monthly_obligation_stats.dart';
import 'package:recurring/features/home/domain/entities/obligation_category.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';

import 'fixtures.dart';

void main() {
  final start = DateTime(2026, 6, 1);

  group('MonthlyObligationStats', () {
    test('fixed EMI contributes the next unpaid installment total', () {
      // ₹12,000 @ 0% × 12 → every installment exactly ₹1,000.
      final s = emiSummary(startDate: start);
      final stats = MonthlyObligationStats.from([s], const []);
      expect(stats.byCategory[ObligationCategory.emi], closeTo(1000, 0.001));
      expect(stats.total, closeTo(1000, 0.001));
    });

    test('after paying installment 1 it still contributes the next one', () {
      final s = emiSummary(
        startDate: start,
        principal: 120000,
        ratePct: 15,
        paidInstallments: 1,
      );
      final expected = FinanceMath.reducingEmi(120000, 15, 12);
      final stats = MonthlyObligationStats.from([s], const []);
      expect(stats.byCategory[ObligationCategory.emi], closeTo(expected, 0.01));
    });

    test('flexible loan contributes its planned monthly payment', () {
      final s = loanSummary(startDate: start, minPayment: 5000);
      final stats = MonthlyObligationStats.from([s], const []);
      expect(stats.byCategory[ObligationCategory.loan], 5000);
      expect(stats.unplannedLoanCount, 0);
    });

    test('a never-clearing loan still counts its planned payment', () {
      // ₹10,000 @ 36% accrues ₹300/mo; paying ₹300 never amortises.
      final s = loanSummary(
        startDate: start,
        ratePct: 36,
        minPayment: 300,
      );
      final stats = MonthlyObligationStats.from([s], const []);
      expect(stats.byCategory[ObligationCategory.loan], 300);
    });

    test('a loan with no planned payment counts zero but is surfaced', () {
      final s = loanSummary(startDate: start, minPayment: 0);
      final stats = MonthlyObligationStats.from([s], const []);
      expect(stats.byCategory[ObligationCategory.loan] ?? 0, 0);
      expect(stats.unplannedLoanCount, 1);
    });

    test('recurring items normalise to monthly (₹499 monthly + ₹1,200 yearly)', () {
      final items = [
        recurringItem(nextDueDate: DateTime(2026, 8, 5)),
        recurringItem(
          id: 'rec-2',
          amount: 1200,
          frequency: Frequency.yearly,
          nextDueDate: DateTime(2027, 1, 1),
        ),
      ];
      final stats = MonthlyObligationStats.from(const [], items);
      expect(
        stats.byCategory[ObligationCategory.subscription],
        closeTo(599, 0.001),
      );
    });

    test('legacy recurring EMI type counts as a bill', () {
      final items = [
        recurringItem(
          type: RecurringType.emi,
          amount: 900,
          nextDueDate: DateTime(2026, 8, 5),
        ),
      ];
      final stats = MonthlyObligationStats.from(const [], items);
      expect(stats.byCategory[ObligationCategory.bill], closeTo(900, 0.001));
    });

    test('closed borrowings and inactive items contribute nothing', () {
      final closedEmi = emiSummary(
        startDate: start,
        status: BorrowingStatus.closed,
      );
      final closedLoan = loanSummary(
        id: 'loan-2',
        startDate: start,
        status: BorrowingStatus.closed,
      );
      final inactive = recurringItem(
        isActive: false,
        nextDueDate: DateTime(2026, 8, 5),
      );
      final stats =
          MonthlyObligationStats.from([closedEmi, closedLoan], [inactive]);
      expect(stats.total, 0);
      expect(stats.byCategory, isEmpty);
    });

    test('total is the sum across categories', () {
      final stats = MonthlyObligationStats.from(
        [
          emiSummary(startDate: start),
          loanSummary(startDate: start, minPayment: 2000),
        ],
        [recurringItem(nextDueDate: DateTime(2026, 8, 5))],
      );
      expect(stats.total, closeTo(1000 + 2000 + 499, 0.001));
    });
  });
}
