import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/finance_math.dart';

void main() {
  group('reducingEmi', () {
    test('₹1,00,000 @ 12% for 12 months ≈ ₹8,884.88', () {
      expect(
        FinanceMath.reducingEmi(100000, 12, 12),
        closeTo(8884.88, 0.5),
      );
    });

    test('zero interest splits principal evenly', () {
      expect(FinanceMath.reducingEmi(12000, 0, 12), closeTo(1000, 0.001));
    });
  });

  group('flat rate', () {
    test('flat interest = P·rate·years', () {
      expect(
        FinanceMath.flatTotalInterest(100000, 12, 12),
        closeTo(12000, 0.001),
      );
    });

    test('flat EMI is higher than reducing EMI for the same nominal rate', () {
      final flat = FinanceMath.flatEmi(100000, 12, 12);
      final reducing = FinanceMath.reducingEmi(100000, 12, 12);
      expect(flat, closeTo(9333.33, 0.5));
      expect(flat, greaterThan(reducing));
    });
  });

  group('amortizationSchedule', () {
    final schedule = FinanceMath.amortizationSchedule(
      principal: 100000,
      annualRatePct: 12,
      months: 12,
    );

    test('has one row per month and closes at zero', () {
      expect(schedule.length, 12);
      expect(schedule.last.closingBalance, closeTo(0, 0.01));
    });

    test('principal components sum to the principal', () {
      final totalPrincipal =
          schedule.fold<double>(0, (s, e) => s + e.principalComponent);
      expect(totalPrincipal, closeTo(100000, 0.01));
    });

    test('interest shrinks every month (reducing balance)', () {
      for (var i = 1; i < schedule.length; i++) {
        expect(schedule[i].interest, lessThan(schedule[i - 1].interest));
      }
    });
  });

  group('emiBreakdown', () {
    test('effective rate ≈ nominal when there is no fee', () {
      final b = FinanceMath.emiBreakdown(
        principal: 100000,
        annualRatePct: 12,
        months: 12,
      );
      expect(b.effectiveAnnualRatePct, closeTo(12, 0.4));
      expect(b.totalExtra, closeTo(b.totalInterest, 0.01));
    });

    test('processing fee pushes the effective rate above nominal', () {
      final withFee = FinanceMath.emiBreakdown(
        principal: 100000,
        annualRatePct: 12,
        months: 12,
        feeValue: 2000,
      );
      expect(withFee.processingFee, 2000);
      expect(withFee.gstOnFee, closeTo(360, 0.01)); // 18% GST
      expect(withFee.effectiveAnnualRatePct, greaterThan(12));
    });
  });

  group('noCostEmi', () {
    test('a real offer is never actually free — GST + fee leak through', () {
      final b = FinanceMath.noCostEmi(
        price: 10000,
        months: 9,
        bankAnnualRatePct: 36,
        feeValue: 800,
      );
      expect(b.monthlyInstallment, closeTo(1111.11, 0.5));
      expect(b.bankInterest, closeTo(1559, 5));
      expect(b.gstOnInterest, closeTo(280.7, 1));
      expect(b.gstOnFee, closeTo(144, 0.5));
      // True cost folds in GST-on-interest + fee + GST-on-fee, but NOT the
      // bank interest itself (the seller's discount cancels that):
      // 10000 + 280.63 + 800 + 144 ≈ 11224.63
      expect(b.trueCost, closeTo(11225, 5));
      expect(b.isActuallyFree, isFalse);
      expect(b.totalExtra, greaterThan(0));
    });

    test('with no interest and no fee it really is free', () {
      final b = FinanceMath.noCostEmi(
        price: 10000,
        months: 6,
        bankAnnualRatePct: 0,
      );
      expect(b.isActuallyFree, isTrue);
      expect(b.trueCost, closeTo(10000, 0.01));
    });
  });

  group('extraPaid', () {
    test('captures the money-leak: ₹10k borrowed, ₹15k repaid → ₹5k wasted', () {
      expect(
        FinanceMath.extraPaid(principal: 10000, totalRepaid: 15000),
        5000,
      );
    });

    test('never negative when repaid less than principal', () {
      expect(
        FinanceMath.extraPaid(principal: 5000, totalRepaid: 4000),
        0,
      );
    });
  });
}
