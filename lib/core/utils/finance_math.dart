import 'dart:math' as math;

import '../constants/app_constants.dart';

/// How a processing fee is expressed.
enum FeeType { flat, percent }

/// Interest calculation method.
enum RateType { reducing, flat }

/// Result of a standard EMI calculation.
class EmiBreakdown {
  const EmiBreakdown({
    required this.principal,
    required this.emi,
    required this.totalInterest,
    required this.processingFee,
    required this.gstOnFee,
    required this.totalPayable,
    required this.effectiveAnnualRatePct,
  });

  final double principal;
  final double emi;
  final double totalInterest;
  final double processingFee;
  final double gstOnFee;

  /// principal + interest + fee + GST on fee.
  final double totalPayable;

  /// True annualised cost once the upfront fee is folded in.
  final double effectiveAnnualRatePct;

  /// Everything paid beyond what was borrowed.
  double get totalExtra => totalPayable - principal;
}

/// One row of a reducing-balance amortization schedule.
class AmortEntry {
  const AmortEntry({
    required this.month,
    required this.openingBalance,
    required this.emi,
    required this.interest,
    required this.principalComponent,
    required this.closingBalance,
  });

  final int month;
  final double openingBalance;
  final double emi;
  final double interest;
  final double principalComponent;
  final double closingBalance;
}

/// Result of analysing a "No Cost EMI" offer.
class NoCostEmiBreakdown {
  const NoCostEmiBreakdown({
    required this.price,
    required this.months,
    required this.monthlyInstallment,
    required this.bankInterest,
    required this.gstOnInterest,
    required this.processingFee,
    required this.gstOnFee,
    required this.forfeitedDiscount,
    required this.trueCost,
    required this.effectiveAnnualRatePct,
  });

  final double price;
  final int months;

  /// What shows on the card statement each month (price / months).
  final double monthlyInstallment;

  /// Interest the bank actually charges (absorbed by the seller's discount).
  final double bankInterest;

  /// 18% GST on [bankInterest] — paid by you, the hidden cost.
  final double gstOnInterest;

  final double processingFee;
  final double gstOnFee;

  /// Any upfront cash discount you gave up by choosing EMI.
  final double forfeitedDiscount;

  /// price + GST-on-interest + fee + GST-on-fee + forfeited discount.
  final double trueCost;

  final double effectiveAnnualRatePct;

  /// The amount the "0%" offer actually costs you.
  double get totalExtra => trueCost - price;

  bool get isActuallyFree => totalExtra < 1;
}

/// Pure financial calculations. No I/O, no Flutter — fully unit-tested.
abstract final class FinanceMath {
  /// Reducing-balance EMI:
  /// `EMI = P·r·(1+r)^n / ((1+r)^n − 1)`, where `r = annualRate/12/100`.
  static double reducingEmi(double principal, double annualRatePct, int months) {
    if (months <= 0) return 0;
    final r = annualRatePct / 12 / 100;
    if (r == 0) return principal / months;
    final pow = math.pow(1 + r, months);
    return principal * r * pow / (pow - 1);
  }

  /// Total interest for a flat-rate loan: `P · rate · years`.
  static double flatTotalInterest(
    double principal,
    double annualRatePct,
    int months,
  ) {
    return principal * (annualRatePct / 100) * (months / 12);
  }

  /// Flat-rate EMI: `(principal + flat interest) / months`.
  static double flatEmi(double principal, double annualRatePct, int months) {
    if (months <= 0) return 0;
    final interest = flatTotalInterest(principal, annualRatePct, months);
    return (principal + interest) / months;
  }

  /// Processing fee from a [FeeType]/value pair.
  static double processingFee({
    required double principal,
    required FeeType type,
    required double value,
  }) {
    return switch (type) {
      FeeType.flat => value,
      FeeType.percent => principal * value / 100,
    };
  }

  static double gstOn(double amount, {double rate = AppConstants.gstRate}) {
    return amount * rate;
  }

  /// Full EMI breakdown including processing fee + GST and effective rate.
  static EmiBreakdown emiBreakdown({
    required double principal,
    required double annualRatePct,
    required int months,
    RateType rateType = RateType.reducing,
    FeeType feeType = FeeType.flat,
    double feeValue = 0,
    double gstRate = AppConstants.gstRate,
  }) {
    final emi = switch (rateType) {
      RateType.reducing => reducingEmi(principal, annualRatePct, months),
      RateType.flat => flatEmi(principal, annualRatePct, months),
    };
    final totalInterest = emi * months - principal;
    final fee = processingFee(
      principal: principal,
      type: feeType,
      value: feeValue,
    );
    final gstFee = gstOn(fee, rate: gstRate);
    final totalPayable = emi * months + fee + gstFee;
    return EmiBreakdown(
      principal: principal,
      emi: emi,
      totalInterest: totalInterest,
      processingFee: fee,
      gstOnFee: gstFee,
      totalPayable: totalPayable,
      effectiveAnnualRatePct: effectiveAnnualRatePct(
        principal: principal,
        emi: emi,
        months: months,
        upfrontCost: fee + gstFee,
      ),
    );
  }

  /// Reducing-balance amortization schedule, one [AmortEntry] per month.
  static List<AmortEntry> amortizationSchedule({
    required double principal,
    required double annualRatePct,
    required int months,
  }) {
    final r = annualRatePct / 12 / 100;
    final emi = reducingEmi(principal, annualRatePct, months);
    final schedule = <AmortEntry>[];
    var balance = principal;
    for (var m = 1; m <= months; m++) {
      final interest = balance * r;
      var principalPart = emi - interest;
      var closing = balance - principalPart;
      // Absorb floating dust in the final installment.
      if (m == months) {
        principalPart += closing;
        closing = 0;
      }
      schedule.add(
        AmortEntry(
          month: m,
          openingBalance: balance,
          emi: emi,
          interest: interest,
          principalComponent: principalPart,
          closingBalance: closing < 0 ? 0 : closing,
        ),
      );
      balance = closing;
    }
    return schedule;
  }

  /// Reveals the real cost of a "No Cost EMI" offer.
  static NoCostEmiBreakdown noCostEmi({
    required double price,
    required int months,
    required double bankAnnualRatePct,
    FeeType feeType = FeeType.flat,
    double feeValue = 0,
    double forfeitedDiscount = 0,
    double gstRate = AppConstants.gstRate,
  }) {
    final monthly = months <= 0 ? 0.0 : price / months;
    final bankInterest =
        reducingEmi(price, bankAnnualRatePct, months) * months - price;
    final gstInterest = gstOn(bankInterest, rate: gstRate);
    final fee = processingFee(principal: price, type: feeType, value: feeValue);
    final gstFee = gstOn(fee, rate: gstRate);
    final trueCost =
        price + gstInterest + fee + gstFee + forfeitedDiscount;
    // Effective rate: you receive goods worth `price`, then pay `monthly`
    // installments while the extra (GST + fees + lost discount) is your cost.
    final effectiveEmi = months <= 0 ? 0.0 : trueCost / months;
    return NoCostEmiBreakdown(
      price: price,
      months: months,
      monthlyInstallment: monthly,
      bankInterest: bankInterest,
      gstOnInterest: gstInterest,
      processingFee: fee,
      gstOnFee: gstFee,
      forfeitedDiscount: forfeitedDiscount,
      trueCost: trueCost,
      effectiveAnnualRatePct: effectiveAnnualRatePct(
        principal: price,
        emi: effectiveEmi,
        months: months,
      ),
    );
  }

  /// Money paid above the amount borrowed. Never negative.
  static double extraPaid({
    required double principal,
    required double totalRepaid,
  }) {
    final extra = totalRepaid - principal;
    return extra < 0 ? 0 : extra;
  }

  /// Effective annual rate (APR) implied by equal [emi] installments against
  /// [principal] over [months], optionally with an [upfrontCost] deducted from
  /// the disbursed amount. Solved numerically (bisection on the monthly rate).
  static double effectiveAnnualRatePct({
    required double principal,
    required double emi,
    required int months,
    double upfrontCost = 0,
  }) {
    if (months <= 0 || principal <= 0) return 0;
    final net = principal - upfrontCost; // cash actually in hand
    final totalPaid = emi * months + upfrontCost;
    if (totalPaid <= principal) return 0;

    // f(r) = emi · (1 − (1+r)^-n) / r − net ; strictly decreasing in r.
    double f(double r) =>
        emi * (1 - math.pow(1 + r, -months)) / r - net;

    var lo = 1e-9;
    var hi = 2.0; // 200%/month upper bound — ample headroom.
    if (f(lo) < 0) return 0;
    if (f(hi) > 0) return hi * 12 * 100;
    for (var i = 0; i < 200; i++) {
      final mid = (lo + hi) / 2;
      if (f(mid) > 0) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2 * 12 * 100;
  }
}
