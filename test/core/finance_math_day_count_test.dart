import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/finance_math.dart';

/// Golden fixture: the user's real slice Small Finance Bank personal loan.
/// Source of record: `docs/slice/kfs-bb15e839-*.pdf` (disbursed 31 Jan 2026).
///
/// Sanctioned ₹80,634 = ₹77,000 cash + ₹3,634 fee financed into the loan.
/// 31.15% fixed, 12 EPIs of ₹7,936.53 due the 5th from 5 Mar 2026.
/// Interest accrues actual/365 on the reducing balance; the first period is the
/// 34 days the KFS states ("Commencement of repayments, post sanction: 34 days").
const _financed = 80634.0;
const _cashInHand = 77000.0;
const _rate = 31.15;
const _months = 12;
final _disbursal = DateTime(2026, 1, 31);
final _firstDue = DateTime(2026, 3, 5);
const _firstPeriodDays = 34;

/// The KFS repayment schedule's interest column, in order.
const _kfsInterest = <double>[
  2339.71, 1985.20, 1768.79, 1664.57, 1450.30, 1327.04,
  1152.18, 941.31, 787.62, 579.18, 403.84, 204.56,
];

void main() {
  group('FinanceMath.dayCountEmi (actual/365, irregular first period)', () {
    test('recovers the KFS EPI of 7936.53 from the loan terms alone', () {
      final emi = FinanceMath.dayCountEmi(
        financedPrincipal: _financed,
        annualRatePct: _rate,
        disbursalDate: _disbursal,
        firstDueDate: _firstDue,
        months: _months,
        firstPeriodDays: _firstPeriodDays,
      );
      expect(emi, closeTo(7936.53, 0.01));
    });

    test('a zero rate just divides the principal', () {
      final emi = FinanceMath.dayCountEmi(
        financedPrincipal: 12000,
        annualRatePct: 0,
        disbursalDate: DateTime(2026, 1, 1),
        firstDueDate: DateTime(2026, 2, 1),
        months: 3,
      );
      expect(emi, closeTo(4000, 0.01));
    });
  });

  group('FinanceMath.runDayCount — reproduces the Slice KFS exactly', () {
    late DayCountRun run;

    setUp(() {
      run = FinanceMath.runDayCount(
        financedPrincipal: _financed,
        annualRatePct: _rate,
        disbursalDate: _disbursal,
        firstDueDate: _firstDue,
        months: _months,
        firstPeriodDays: _firstPeriodDays,
        emi: 7936.53,
      );
    });

    test('bills 12 installments', () {
      expect(run.rows, hasLength(12));
    });

    test('every interest row matches the KFS to the paisa', () {
      for (var i = 0; i < 12; i++) {
        expect(
          run.rows[i].interest,
          closeTo(_kfsInterest[i], 0.01),
          reason: 'installment ${i + 1}',
        );
      }
    });

    test('the first period is the 34 days the KFS states', () {
      expect(run.rows.first.interest, closeTo(2339.71, 0.01));
      expect(run.rows.first.dueDate, DateTime(2026, 3, 5));
    });

    test('total interest is 14604.30 and total paid is 95238.30', () {
      expect(run.totalInterest, closeTo(14604.30, 0.10));
      expect(run.totalPaid, closeTo(95238.30, 0.10));
    });

    test('the schedule fully amortises: closing balance is zero', () {
      expect(run.rows.last.closingBalance, closeTo(0, 0.01));
    });

    test('true cost on the cash actually received is 18238.30', () {
      expect(run.totalPaid - _cashInHand, closeTo(18238.30, 0.10));
    });
  });

  group('FinanceMath.runDayCount — prepayment recalculates the waste', () {
    test('20k extra with the Jun EMI clears in 9 and saves 3939.06', () {
      final run = FinanceMath.runDayCount(
        financedPrincipal: _financed,
        annualRatePct: _rate,
        disbursalDate: _disbursal,
        firstDueDate: _firstDue,
        months: _months,
        firstPeriodDays: _firstPeriodDays,
        emi: 7936.53,
        extraPayments: [(DateTime(2026, 6, 5), 20000.0)],
      );
      expect(run.rows, hasLength(9));
      expect(run.totalPaid, closeTo(91299.24, 0.10));
      final waste = run.totalPaid - _cashInHand;
      expect(waste, closeTo(14299.24, 0.10));
      expect(18238.30 - waste, closeTo(3939.06, 0.10));
    });

    test('paying exactly the EMI changes nothing', () {
      final run = FinanceMath.runDayCount(
        financedPrincipal: _financed,
        annualRatePct: _rate,
        disbursalDate: _disbursal,
        firstDueDate: _firstDue,
        months: _months,
        firstPeriodDays: _firstPeriodDays,
        emi: 7936.53,
        extraPayments: const [],
      );
      expect(run.rows, hasLength(12));
      expect(run.totalPaid, closeTo(95238.30, 0.10));
    });
  });

  group('FinanceMath.nominalAprPct — the rate lenders advertise', () {
    test("reproduces Slice's published 39.73% APR", () {
      // KFS footnote 1: "APR is calculated excluding the GST component of flat
      // fee", i.e. against 80,634 − 3,079.66 = 77,554.34, not the 77,000 cash.
      final apr = FinanceMath.nominalAprPct(
        netAmount: 77554.34,
        emi: 7936.53,
        months: 12,
      );
      expect(apr, closeTo(39.73, 0.02));
    });

    test('the effective rate on the same loan is far higher', () {
      final eff = FinanceMath.effectiveAprPct(
        netAmount: 77554.34,
        emi: 7936.53,
        months: 12,
      );
      expect(eff, closeTo(47.83, 0.05));
    });
  });

  group('FinanceMath.foreclosureQuote', () {
    test('Slice: zero fee, but one extra day of interest', () {
      final q = FinanceMath.foreclosureQuote(
        outstandingPrincipal: 50159.92,
        annualRatePct: _rate,
        daysSinceLastDue: 0,
        feePct: 0,
        feeMin: 0,
        extraInterestDays: 1,
        gstOnFee: false,
      );
      expect(q.fee, 0);
      expect(q.gstOnFee, 0);
      // 50,159.92 × 31.15% / 365 × 1 day
      expect(q.accruedInterest, closeTo(42.81, 0.01));
      expect(q.total, closeTo(50202.73, 0.02));
    });

    test('HDFC: 3% of outstanding plus 18% GST on the fee', () {
      final q = FinanceMath.foreclosureQuote(
        outstandingPrincipal: 50000,
        annualRatePct: 16,
        daysSinceLastDue: 0,
        feePct: 3,
        feeMin: 0,
        extraInterestDays: 0,
        gstOnFee: true,
      );
      expect(q.fee, closeTo(1500, 0.01));
      expect(q.gstOnFee, closeTo(270, 0.01));
      expect(q.total, closeTo(51770, 0.02));
    });

    test('Axis: the ₹300 floor beats 3% on a small balance', () {
      final q = FinanceMath.foreclosureQuote(
        outstandingPrincipal: 5000,
        annualRatePct: 16,
        daysSinceLastDue: 0,
        feePct: 3,
        feeMin: 300,
        extraInterestDays: 0,
        gstOnFee: true,
      );
      expect(q.fee, closeTo(300, 0.01)); // 3% would be only 150
    });
  });
}
