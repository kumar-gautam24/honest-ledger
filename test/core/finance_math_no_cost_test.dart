import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/finance_math.dart';

void main() {
  group('FinanceMath.noCostDiscount', () {
    test('75000 @ 16% x 6: discount 3379.19, installment lands on price/6', () {
      final d = FinanceMath.noCostDiscount(
          price: 75000, bankAnnualRatePct: 16, months: 6);
      expect(d, closeTo(3379.19, 0.05));
      final emi = FinanceMath.reducingEmi(75000 - d, 16, 6);
      expect(emi * 6, closeTo(75000, 0.05));
    });

    test('zero rate needs zero discount', () {
      expect(
        FinanceMath.noCostDiscount(price: 30000, bankAnnualRatePct: 0, months: 3),
        closeTo(0, 0.01),
      );
    });
  });

  group('FinanceMath.noCostEmi (discount-exact model)', () {
    test('75000 @ 16% x 6, fee 299: golden breakdown', () {
      final b = FinanceMath.noCostEmi(
        price: 75000,
        months: 6,
        bankAnnualRatePct: 16,
        feeValue: 299,
      );
      expect(b.merchantDiscount, closeTo(3379.19, 0.05));
      expect(b.monthlyInstallment, closeTo(12500.00, 0.01));
      // Interest is on the DISCOUNTED principal, so GST is 608.25 — not the
      // ~637 the old full-price model produced.
      expect(b.bankInterest, closeTo(3379.19, 0.10));
      expect(b.gstOnInterest, closeTo(608.25, 0.10));
      expect(b.processingFee, 299);
      expect(b.gstOnFee, closeTo(53.82, 0.01));
      expect(b.totalExtra, closeTo(961.07, 0.20));
      expect(b.isActuallyFree, isFalse);
    });

    test('no fee, no discount forfeited, 0% rate really is free', () {
      final b = FinanceMath.noCostEmi(
          price: 12000, months: 3, bankAnnualRatePct: 0);
      expect(b.totalExtra, closeTo(0, 0.01));
      expect(b.isActuallyFree, isTrue);
    });
  });

  group('FinanceMath.financedFeeInterestShare (Slice KFS)', () {
    test('80634 @ 31.15% x 12 with 3634 financed fee', () {
      final totalInterest =
          FinanceMath.reducingEmi(80634, 31.15, 12) * 12 - 80634;
      expect(totalInterest, closeTo(14243.51, 0.5));
      final share = FinanceMath.financedFeeInterestShare(
        principal: 80634,
        financedAmount: 3634,
        totalInterest: totalInterest,
      );
      expect(share, closeTo(641.92, 1.0));
    });

    test('APR on net cash matches KFS ballpark', () {
      // Slice bills EMI 7936.53 (34-day first period); against ₹77,000 in hand
      // that is ≈41% IRR; our uniform-period EMI gives ≈40.4%. KFS: 39.73%.
      final apr = FinanceMath.effectiveAnnualRatePct(
        principal: 80634,
        emi: FinanceMath.reducingEmi(80634, 31.15, 12),
        months: 12,
        upfrontCost: 3634,
      );
      expect(apr, closeTo(40.4, 0.5));
    });
  });

  group('emiSchedule noCostEmi mode', () {
    test('rows bill price/n, GST tracks discounted-principal amortization', () {
      final rows = FinanceMath.emiSchedule(
        principal: 75000,
        annualRatePct: 16,
        months: 6,
        startDate: DateTime(2026, 7, 8),
        gstOnInterest: true,
        noCostEmi: true,
        feeValue: 299,
      );
      expect(rows.every((r) => (r.principal - 12500).abs() < 0.01), isTrue);
      expect(rows.every((r) => r.interest == 0), isTrue);
      final gst = rows.fold<double>(0, (s, r) => s + r.gstOnInterest);
      expect(gst, closeTo(608.25, 0.15));
      final total = rows.fold<double>(0, (s, r) => s + r.total);
      expect(total, closeTo(75000 + 608.25 + 299 * 1.18, 0.30));
      // GST is front-loaded like real statements: month 1 > month 6.
      expect(rows.first.gstOnInterest, greaterThan(rows.last.gstOnInterest));
    });
  });
}
