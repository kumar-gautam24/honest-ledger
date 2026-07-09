import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/lenders/domain/entities/lender.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/foreclosure.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';

const _slice = Lender(
  id: 'slice',
  name: 'slice',
  type: LenderType.bnpl,
  typicalRatePct: 31.15,
  foreclosurePct: 0,
  foreclosureGst: false,
  foreclosureExtraInterestDays: 1,
);

const _hdfc = Lender(
  id: 'hdfc-card-emi',
  name: 'HDFC Card EMI',
  type: LenderType.card,
  typicalRatePct: 16.05,
  foreclosurePct: 3,
  foreclosureFreeWindowDays: 30,
);

Borrowing _sliceLoan() => Borrowing(
      id: 'slice-1',
      title: 'slice personal loan',
      kind: BorrowingKind.fixedEmi,
      lenderId: 'slice',
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

Borrowing _cardEmi({required DateTime start}) => Borrowing(
      id: 'card',
      title: 'MacBook',
      kind: BorrowingKind.fixedEmi,
      lenderId: 'hdfc-card-emi',
      lenderName: 'HDFC Card EMI',
      principal: 120000,
      interestRatePct: 16.05,
      tenureMonths: 12,
      startDate: start,
      createdAt: start,
    );

void main() {
  group('ForeclosureEstimate for the slice loan', () {
    test('after 4 paid installments, the payoff is free but for one day', () {
      final b = _sliceLoan();
      final schedule = BorrowingSummary.from(b, const []).schedule;
      final paid = [
        for (var i = 0; i < 4; i++)
          Repayment(
            id: 'p$i',
            borrowingId: b.id,
            amount: schedule[i].total,
            date: schedule[i].dueDate,
            installmentNo: i + 1,
          ),
      ];
      final summary = BorrowingSummary.from(b, paid);
      // Foreclose on the 4th due date itself: no interest has accrued since.
      final e = ForeclosureEstimate.of(
        summary: summary,
        lender: _slice,
        asOf: DateTime(2026, 6, 5),
      );

      expect(e.quote.fee, 0);
      expect(e.quote.gstOnFee, 0);
      // Exactly one extra day of interest on the balance still owed.
      final expectedOneDay =
          summary.remainingPrincipal * 31.15 / 100 / 365 * 1;
      expect(e.quote.accruedInterest, closeTo(expectedOneDay, 0.01));
      expect(e.isFree, isFalse, reason: 'one day of interest is not free');
      // Closing now dodges the remaining interest.
      expect(e.interestAvoided, greaterThan(0));
      expect(e.worthIt, isTrue);
    });
  });

  group('ForeclosureEstimate for a card EMI', () {
    test('inside the free window the fee is waived', () {
      final start = DateTime.now().subtract(const Duration(days: 10));
      final summary = BorrowingSummary.from(_cardEmi(start: start), const []);
      final e = ForeclosureEstimate.of(summary: summary, lender: _hdfc);
      expect(e.insideFreeWindow, isTrue);
      expect(e.quote.fee, 0);
    });

    test('outside the free window it is 3% plus GST', () {
      final start = DateTime.now().subtract(const Duration(days: 200));
      final summary = BorrowingSummary.from(_cardEmi(start: start), const []);
      final e = ForeclosureEstimate.of(summary: summary, lender: _hdfc);
      expect(e.insideFreeWindow, isFalse);
      expect(e.quote.fee, closeTo(summary.remainingPrincipal * 0.03, 0.01));
      expect(e.quote.gstOnFee, closeTo(e.quote.fee * 0.18, 0.01));
    });
  });

  group('an unknown lender is never guessed at', () {
    test('a null lender leaves the fee at zero and says so', () {
      final summary = BorrowingSummary.from(
        _cardEmi(start: DateTime(2026, 1, 1)),
        const [],
      );
      final e = ForeclosureEstimate.of(summary: summary, lender: null);
      expect(e.rulesKnown, isFalse);
      expect(e.quote.fee, 0);
    });
  });
}
