import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';

/// The user's real slice SFB personal loan (`docs/slice/kfs-*.pdf`), modelled
/// the way the app should: `principal` is the ₹77,000 that reached the bank
/// account, and the ₹3,634 fee is financed on top — so the ₹80,634 the lender
/// charges interest on is derived, never typed.
Borrowing _slice() => Borrowing(
      id: 'slice-1',
      title: 'slice personal loan',
      kind: BorrowingKind.fixedEmi,
      lenderName: 'slice',
      principal: 77000,
      processingFee: 3079.66,
      gstOnFee: 554.34,
      feeFinanced: true,
      interestRatePct: 31.15,
      tenureMonths: 12,
      dayCount: DayCountConvention.actual365,
      startDate: DateTime(2026, 1, 31),
      firstDueDate: DateTime(2026, 3, 5),
      firstPeriodDays: 34,
      createdAt: DateTime(2026, 1, 31),
    );

void main() {
  group('a financed-fee EMI on actual/365 (the slice KFS)', () {
    test('the interest-bearing balance is derived, not the typed principal', () {
      expect(_slice().financedPrincipal, closeTo(80634, 0.01));
    });

    test('bills the 12 installments of 7936.53 the KFS states', () {
      final s = BorrowingSummary.from(_slice(), const []);
      expect(s.schedule, hasLength(12));
      expect(s.schedule.first.total, closeTo(7936.53, 0.01));
      expect(s.schedule.first.interest, closeTo(2339.71, 0.01));
      expect(s.schedule.last.total, closeTo(7936.47, 0.01));
    });

    test('the financed fee is never billed as an installment line', () {
      final s = BorrowingSummary.from(_slice(), const []);
      expect(s.schedule.first.fee, 0);
      expect(s.schedule.first.gstOnFee, 0);
    });

    test('scheduled total is 95238.30', () {
      final s = BorrowingSummary.from(_slice(), const []);
      expect(s.scheduledTotal, closeTo(95238.30, 0.10));
    });

    test('projected waste against cash-in-hand is 18238.30', () {
      final s = BorrowingSummary.from(_slice(), const []);
      expect(s.projectedExtra, closeTo(18238.30, 0.10));
    });

    test('the fee is already spent, so it is wasted from day one', () {
      final s = BorrowingSummary.from(_slice(), const []);
      expect(s.wastedSoFar, closeTo(3634.00, 0.01));
    });
  });

  group('prepayment recalculates the waste', () {
    test('20k extra on the June installment saves 3939.06', () {
      final b = _slice();
      final schedule = BorrowingSummary.from(b, const []).schedule;
      // Pay installments 1-3 normally, then 4 (due 5 Jun) with 20k on top.
      final repayments = [
        for (var i = 0; i < 3; i++)
          Repayment(
            id: 'p$i',
            borrowingId: b.id,
            amount: schedule[i].total,
            date: schedule[i].dueDate,
            installmentNo: i + 1,
          ),
        Repayment(
          id: 'p3',
          borrowingId: b.id,
          amount: schedule[3].total + 20000,
          date: schedule[3].dueDate,
          installmentNo: 4,
        ),
      ];
      final s = BorrowingSummary.from(b, repayments);
      expect(s.schedule, hasLength(9));
      expect(s.scheduledTotal, closeTo(91299.24, 0.10));
      expect(s.projectedExtra, closeTo(14299.24, 0.10));
      expect(s.projectedSaved, closeTo(3939.06, 0.10));
    });
  });

  group('manual charges', () {
    test('a logged fine is waste, and clears no principal', () {
      final b = _slice();
      final clean = BorrowingSummary.from(b, const []);
      final withFine = BorrowingSummary.from(b, [
        Repayment(
          id: 'fine',
          borrowingId: b.id,
          amount: 500,
          date: DateTime(2026, 4, 6),
          kind: RepaymentKind.charge,
          note: 'late payment penal charge',
        ),
      ]);
      // The schedule is untouched: a fine retires no principal.
      expect(withFine.schedule, hasLength(12));
      expect(withFine.paidInstallments, 0);
      expect(withFine.scheduledTotal, closeTo(clean.scheduledTotal, 0.01));
      // But it is real money gone.
      expect(withFine.projectedExtra, closeTo(clean.projectedExtra + 500, 0.10));
      expect(withFine.wastedSoFar, closeTo(clean.wastedSoFar + 500, 0.01));
    });
  });

  group('regression: existing card EMIs are untouched', () {
    test('a monthlyUniform EMI still uses the closed-form schedule', () {
      final b = Borrowing(
        id: 'card',
        title: 'MacBook',
        kind: BorrowingKind.fixedEmi,
        lenderName: 'ICICI',
        principal: 120000,
        interestRatePct: 15,
        tenureMonths: 12,
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );
      final s = BorrowingSummary.from(b, const []);
      expect(s.schedule, hasLength(12));
      expect(
        s.schedule.first.total,
        closeTo(FinanceMath.reducingEmi(120000, 15, 12), 0.01),
      );
      expect(b.financedPrincipal, closeTo(120000, 0.01));
    });
  });
}
