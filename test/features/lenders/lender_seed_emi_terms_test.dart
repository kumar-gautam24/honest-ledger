import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/lenders/data/lender_seed.dart';
import 'package:recurring/features/lenders/domain/entities/lender.dart';

/// Locks each ICICI EMI *channel* to its published terms so a seed edit can't
/// silently mis-price an EMI. Amounts here are illustrative, not real bookings.
void main() {
  Lender byId(String id) => kSeedLenders.firstWhere((l) => l.id == id);

  group('ICICI EMI-on-Call (post-purchase) terms', () {
    final lender = byId('icici-emi-on-call');

    test('carries the 18% / 2% / foreclosure-3% post-purchase terms', () {
      expect(lender.typicalRatePct, 18);
      expect(lender.feeType, FeeType.percent);
      expect(lender.feeValue, 2);
      expect(lender.feeCap, isNull); // no ₹299 Instant-EMI cap on this product
      expect(lender.foreclosurePct, 3);
    });

    test('a 2% fee with no cap resolves to 2% of the amount', () {
      final fee = FinanceMath.processingFee(
        principal: 100000,
        type: lender.feeType,
        value: lender.feeValue,
        cap: lender.feeCap,
        min: lender.feeMin,
      );
      expect(fee, 2000); // 2% of 100,000, uncapped
    });

    test('breakdown is internally consistent (GST rides on interest + fee)', () {
      final b = FinanceMath.emiBreakdown(
        principal: 100000,
        annualRatePct: lender.typicalRatePct,
        months: 12,
        feeType: lender.feeType,
        feeValue: lender.feeValue,
        gstOnInterest: true,
      );
      expect(b.totalInterest, closeTo(b.emi * 12 - b.principal, 0.5));
      expect(b.gstOnInterest, closeTo(b.totalInterest * 0.18, 0.5));
      expect(b.processingFee, 2000);
      expect(
        b.totalExtra,
        closeTo(b.totalInterest + b.gstOnInterest + b.processingFee + b.gstOnFee, 0.5),
      );
    });
  });

  test('Instant EMI channel stays 15.99% / 2.99% capped ₹299', () {
    final instant = byId('icici-card-emi');
    expect(instant.typicalRatePct, 15.99);
    expect(instant.feeType, FeeType.percent);
    expect(instant.feeValue, 2.99);
    expect(instant.feeCap, 299);
  });

  test('No-Cost EMI on the Instant rate is not actually free (18% GST leaks)', () {
    final instant = byId('icici-card-emi');
    final r = FinanceMath.noCostEmi(
      price: 50000,
      months: 12,
      bankAnnualRatePct: instant.typicalRatePct, // the toggle reuses the template rate
    );
    expect(r.gstOnInterest, greaterThan(0));
    expect(r.trueCost, greaterThan(r.price));
    expect(r.isActuallyFree, isFalse);
  });
}
