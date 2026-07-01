import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';

Borrowing _emi({required DateTime start}) => Borrowing(
      id: 'e',
      title: 'MacBook',
      kind: BorrowingKind.fixedEmi,
      lenderName: 'ICICI',
      principal: 120000,
      interestRatePct: 15,
      tenureMonths: 12,
      startDate: start,
      createdAt: start,
    );

void main() {
  group('overdue detection', () {
    test('every unpaid installment in the past counts as overdue', () {
      // A plan that started well over a year ago with nothing logged.
      final s = BorrowingSummary.from(_emi(start: DateTime(2024, 1, 1)), const []);
      expect(s.overdueCount, 12);
      expect(s.overdueAmount, greaterThan(0));
      expect(s.overdueInstallments.first.number, 1);
    });

    test('paying an installment removes it from the overdue list', () {
      final b = _emi(start: DateTime(2024, 1, 1));
      final schedule = BorrowingSummary.from(b, const []).schedule;
      final s = BorrowingSummary.from(b, [
        Repayment(
          id: 'p1',
          borrowingId: 'e',
          amount: schedule.first.total,
          date: DateTime(2024, 2, 1),
          installmentNo: 1,
        ),
      ]);
      expect(s.paidInstallments, 1);
      expect(s.overdueCount, 11);
      expect(s.overdueInstallments.any((e) => e.number == 1), isFalse);
      expect(s.nextDueInstallment?.number, 2);
    });

    test('a future-dated plan has nothing overdue yet', () {
      final s = BorrowingSummary.from(_emi(start: DateTime(2999, 1, 1)), const []);
      expect(s.overdueCount, 0);
      expect(s.nextDueInstallment?.number, 1);
    });
  });

  group('wasted so far (EMI)', () {
    final b = _emi(start: DateTime(2024, 1, 1));

    test('is zero before any installment is paid', () {
      expect(BorrowingSummary.from(b, const []).wastedSoFar, 0);
    });

    test('counts the interest+fee portion of each installment paid', () {
      final schedule = BorrowingSummary.from(b, const []).schedule;
      final s = BorrowingSummary.from(b, [
        Repayment(
          id: 'p1',
          borrowingId: 'e',
          amount: schedule.first.total,
          date: DateTime(2024, 2, 1),
          installmentNo: 1,
        ),
      ]);
      // The first installment's non-principal portion — not (repaid − principal),
      // which would still be zero this early.
      final expected = schedule.first.total - schedule.first.principal;
      expect(s.wastedSoFar, closeTo(expected, 0.01));
      expect(s.wastedSoFar, greaterThan(0));
      expect(s.wastedSoFar, lessThan(s.projectedExtra));
    });
  });

  group('flexible loan projectedExtra', () {
    Borrowing loan({double minPayment = 2000}) => Borrowing(
          id: 'l1',
          title: 'Slice draw',
          lenderName: 'Slice',
          kind: BorrowingKind.flexibleLoan,
          principal: 10000,
          interestRatePct: 36,
          minPayment: minPayment,
          startDate: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        );

    test('projects future interest at the planned pace (more than fees alone)', () {
      final s = BorrowingSummary.from(loan(), const []);
      // Fees are zero here, so any projected extra is pure interest.
      expect(s.projectedExtra, greaterThan(0));
      expect(s.neverClears, isFalse);
    });

    test('a prepayment lowers projectedExtra and shows a saving', () {
      // Start "now" so no past interest has accrued — isolates the effect of a
      // prepayment on the forward projection.
      final now = DateTime.now();
      Borrowing freshLoan() => Borrowing(
            id: 'l2',
            title: 'Slice draw',
            lenderName: 'Slice',
            kind: BorrowingKind.flexibleLoan,
            principal: 10000,
            interestRatePct: 36,
            minPayment: 2000,
            startDate: now,
            createdAt: now,
          );
      final baseline = BorrowingSummary.from(freshLoan(), const []).projectedExtra;
      final prepaid = BorrowingSummary.from(freshLoan(), [
        Repayment(
          id: 'r1',
          borrowingId: 'l2',
          amount: 6000,
          date: now,
        ),
      ]);
      expect(prepaid.projectedExtra, lessThan(baseline));
      expect(prepaid.projectedSaved, greaterThan(0));
    });

    test('a pace that cannot cover interest never clears', () {
      // ₹50/mo on a ₹10,000 @ 36% (₹300/mo interest) balance.
      final s = BorrowingSummary.from(loan(minPayment: 50), const []);
      expect(s.neverClears, isTrue);
    });
  });

  group('fixed EMI foreclosure', () {
    Borrowing emi() => Borrowing(
          id: 'e1',
          title: 'Phone EMI',
          lenderName: 'HDFC',
          kind: BorrowingKind.fixedEmi,
          principal: 12000,
          interestRatePct: 18,
          tenureMonths: 12,
          startDate: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        );

    test('open EMI shows the full scheduled extra and no saving', () {
      final s = BorrowingSummary.from(emi(), const []);
      expect(s.projectedExtra, closeTo(s.scheduledTotal - 12000, 0.5));
      expect(s.projectedSaved, 0);
    });

    test('foreclosing after some installments drops extra and shows a saving', () {
      final open = BorrowingSummary.from(emi(), const []);
      final closed = emi().copyWith(
        status: BorrowingStatus.closed,
        foreclosureFee: 500,
      );
      final s = BorrowingSummary.from(closed, [
        Repayment(
          id: 'r1',
          borrowingId: 'e1',
          amount: 1100,
          date: DateTime(2026, 2, 1),
          installmentNo: 1,
        ),
      ]);
      expect(s.projectedExtra, lessThan(open.projectedExtra));
      expect(s.projectedSaved, greaterThan(0));
    });
  });
}
