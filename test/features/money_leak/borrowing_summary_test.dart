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
}
