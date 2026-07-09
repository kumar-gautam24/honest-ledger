import 'dart:math' as math;

import '../constants/app_constants.dart';
import 'date_x.dart';

/// How a processing fee is expressed.
enum FeeType { flat, percent }

/// Interest calculation method.
enum RateType { reducing, flat }

/// How interest is accrued between installments.
///
/// [monthlyUniform] — one twelfth of the annual rate per installment, whatever
/// the calendar says. What Indian card EMIs quote and what closed-form EMI
/// formulas assume.
/// [actual365] — interest accrues per day on the reducing balance
/// (`balance × rate/365 × days`), so an irregular first period costs more.
/// Personal loans disbursed mid-month bill this way (slice SFB, most NBFCs).
enum DayCountConvention { monthlyUniform, actual365 }

/// One billed period of a day-count schedule.
class DayCountRow {
  const DayCountRow({
    required this.number,
    required this.dueDate,
    required this.days,
    required this.openingBalance,
    required this.interest,
    required this.principal,
    required this.payment,
    required this.closingBalance,
  });

  final int number;
  final DateTime dueDate;

  /// Days this period accrued over — the first one is usually irregular.
  final int days;
  final double openingBalance;
  final double interest;

  /// Principal retired this period (`payment − interest`). Larger when the
  /// borrower paid more than the installment.
  final double principal;

  /// Cash actually leaving the borrower's hands this period.
  final double payment;
  final double closingBalance;
}

/// A day-count schedule rolled forward from real payments. When the borrower
/// only ever pays the installment this is the lender's own schedule; extra
/// payments retire principal early, so [rows] runs short and [totalPaid] falls.
class DayCountRun {
  const DayCountRun(this.rows);

  final List<DayCountRow> rows;

  /// Every rupee handed over across the schedule.
  double get totalPaid => rows.fold<double>(0, (s, r) => s + r.payment);

  /// Interest alone — no fees, no GST.
  double get totalInterest => rows.fold<double>(0, (s, r) => s + r.interest);

  /// What is still owed after the last row.
  double get closingBalance => rows.isEmpty ? 0 : rows.last.closingBalance;
}

/// The cost of clearing a borrowing today.
class ForeclosureQuote {
  const ForeclosureQuote({
    required this.outstandingPrincipal,
    required this.accruedInterest,
    required this.fee,
    required this.gstOnFee,
  });

  final double outstandingPrincipal;

  /// Interest since the last due date, plus any settlement-delay days the
  /// lender tacks on (slice charges 1).
  final double accruedInterest;
  final double fee;
  final double gstOnFee;

  /// The cheque you write to walk away.
  double get total => outstandingPrincipal + accruedInterest + fee + gstOnFee;

  /// Everything beyond the principal — the true price of foreclosing.
  double get cost => accruedInterest + fee + gstOnFee;
}

/// Result of a standard EMI calculation.
class EmiBreakdown {
  const EmiBreakdown({
    required this.principal,
    required this.emi,
    required this.totalInterest,
    required this.processingFee,
    required this.gstOnFee,
    required this.gstOnInterest,
    required this.totalPayable,
    required this.effectiveAnnualRatePct,
  });

  final double principal;
  final double emi;
  final double totalInterest;
  final double processingFee;
  final double gstOnFee;

  /// 18% GST on the interest, when charged (credit-card / consumer EMIs). Zero
  /// otherwise.
  final double gstOnInterest;

  /// principal + interest + GST-on-interest + fee + GST on fee.
  final double totalPayable;

  /// True annualised cost once the upfront fee is folded in.
  final double effectiveAnnualRatePct;

  /// Everything paid beyond what was borrowed.
  double get totalExtra => totalPayable - principal;
}

/// One exact installment of a fixed EMI schedule: the amount, its due date, and
/// the component split. Month 1 carries the upfront processing fee + its GST.
class EmiInstallment {
  const EmiInstallment({
    required this.number,
    required this.dueDate,
    required this.principal,
    required this.interest,
    required this.gstOnInterest,
    required this.fee,
    required this.gstOnFee,
  });

  final int number;
  final DateTime dueDate;
  final double principal;
  final double interest;
  final double gstOnInterest;
  final double fee;
  final double gstOnFee;

  /// The exact amount due this month.
  double get total => principal + interest + gstOnInterest + fee + gstOnFee;
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
    required this.merchantDiscount,
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

  /// The upfront discount the merchant gives so the EMIs sum back to the
  /// sticker price — it equals the bank's interest on the financed amount.
  final double merchantDiscount;

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

  /// Processing fee from a [FeeType]/value pair, with optional [cap]/[min]
  /// (e.g. ICICI Instant EMI is 2.99% of the amount but capped at ₹299).
  static double processingFee({
    required double principal,
    required FeeType type,
    required double value,
    double? cap,
    double? min,
  }) {
    var fee = switch (type) {
      FeeType.flat => value,
      FeeType.percent => principal * value / 100,
    };
    if (min != null && fee < min) fee = min;
    if (cap != null && fee > cap) fee = cap;
    return fee;
  }

  static double gstOn(double amount, {double rate = AppConstants.gstRate}) {
    return amount * rate;
  }

  /// Full EMI breakdown including processing fee + GST and effective rate. When
  /// [gstOnInterest] is true, 18% GST on the interest is folded into the total
  /// (as on Indian credit-card / consumer EMIs).
  static EmiBreakdown emiBreakdown({
    required double principal,
    required double annualRatePct,
    required int months,
    RateType rateType = RateType.reducing,
    FeeType feeType = FeeType.flat,
    double feeValue = 0,
    bool gstOnInterest = false,
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
    final gstInterest = gstOnInterest ? gstOn(totalInterest, rate: gstRate) : 0.0;
    final totalPayable = emi * months + gstInterest + fee + gstFee;
    return EmiBreakdown(
      principal: principal,
      emi: emi,
      totalInterest: totalInterest,
      processingFee: fee,
      gstOnFee: gstFee,
      gstOnInterest: gstInterest,
      totalPayable: totalPayable,
      effectiveAnnualRatePct: effectiveAnnualRatePct(
        principal: principal,
        emi: emi,
        months: months,
        upfrontCost: fee + gstFee,
      ),
    );
  }

  /// The exact, dated installment schedule for a fixed EMI. Reducing loans use
  /// the amortization split; flat loans spread interest evenly. GST on interest
  /// is added per row when [gstOnInterest] is set, and the processing fee + its
  /// GST land on installment 1.
  ///
  /// When [noCostEmi] is true (only meaningful with [RateType.reducing] —
  /// flat-rate loans have no discount mechanism, so the flag is ignored for
  /// them), each row bills `principal / months` with zero interest: the
  /// merchant's discount ([noCostDiscount]) absorbs the bank's interest so the
  /// card statement never shows it. The interest still exists on the bank's
  /// books (on the discounted principal) purely to attract GST, so
  /// [EmiInstallment.gstOnInterest] tracks that underlying amortization even
  /// though [EmiInstallment.interest] is zero.
  static List<EmiInstallment> emiSchedule({
    required double principal,
    required double annualRatePct,
    required int months,
    required DateTime startDate,
    RateType rateType = RateType.reducing,
    bool gstOnInterest = false,
    FeeType feeType = FeeType.flat,
    double feeValue = 0,
    double gstRate = AppConstants.gstRate,
    bool noCostEmi = false,
  }) {
    if (months <= 0) return const [];
    final fee = processingFee(principal: principal, type: feeType, value: feeValue);
    final gstFee = gstOn(fee, rate: gstRate);

    // (principal, interest) per month, by rate type; gstBase is the per-month
    // amount GST-on-interest is computed on — equal to `interest` in every
    // path except no-cost EMI, where the row shows zero interest but GST
    // still tracks the bank's underlying (discounted-principal) amortization.
    List<(double, double)> parts;
    List<double> gstBase;
    switch (rateType) {
      case RateType.reducing:
        if (noCostEmi) {
          final discount = noCostDiscount(
            price: principal,
            bankAnnualRatePct: annualRatePct,
            months: months,
          );
          final underlying = amortizationSchedule(
            principal: principal - discount,
            annualRatePct: annualRatePct,
            months: months,
          );
          final principalEach = principal / months;
          parts = [for (final _ in underlying) (principalEach, 0.0)];
          gstBase = [for (final e in underlying) e.interest];
        } else {
          final amort = amortizationSchedule(
            principal: principal,
            annualRatePct: annualRatePct,
            months: months,
          );
          parts = [for (final e in amort) (e.principalComponent, e.interest)];
          gstBase = [for (final e in amort) e.interest];
        }
      case RateType.flat:
        final interestEach = flatTotalInterest(principal, annualRatePct, months) / months;
        final principalEach = principal / months;
        parts = List.generate(months, (_) => (principalEach, interestEach));
        gstBase = List.generate(months, (_) => interestEach);
    }

    return [
      for (var i = 0; i < months; i++)
        EmiInstallment(
          number: i + 1,
          dueDate: startDate.addMonths(i + 1),
          principal: parts[i].$1,
          interest: parts[i].$2,
          gstOnInterest: gstOnInterest ? gstOn(gstBase[i], rate: gstRate) : 0,
          fee: i == 0 ? fee : 0,
          gstOnFee: i == 0 ? gstFee : 0,
        ),
    ];
  }

  /// Outstanding balance of a [flexible loan] as of [asOf]: interest accrues on
  /// the reducing balance each month from [startDate]; each payment lowers it,
  /// so larger payments leave less to accrue interest on. Never negative.
  static double outstandingFlexible({
    required double principal,
    required double annualRatePct,
    required DateTime startDate,
    required List<(DateTime, double)> payments,
    DateTime? asOf,
  }) {
    final r = annualRatePct / 12 / 100;
    final end = asOf ?? DateTime.now();
    final sorted = [...payments]..sort((a, b) => a.$1.compareTo(b.$1));
    var balance = principal;
    var pi = 0;
    var cursor = startDate;
    while (cursor.isBefore(end)) {
      final next = cursor.addMonths(1);
      while (pi < sorted.length && sorted[pi].$1.isBefore(next)) {
        balance -= sorted[pi].$2;
        pi++;
      }
      if (balance > 0 && r > 0) balance += balance * r;
      cursor = next;
    }
    while (pi < sorted.length && !sorted[pi].$1.isAfter(end)) {
      balance -= sorted[pi].$2;
      pi++;
    }
    return balance < 0 ? 0 : balance;
  }

  /// Interest incurred on a [flexible loan]'s reducing balance from [startDate]
  /// to [asOf], given the actual [payments] made. Mirrors [outstandingFlexible]'s
  /// month-by-month accrual but sums the interest instead of the balance.
  static double accruedInterestFlexible({
    required double principal,
    required double annualRatePct,
    required DateTime startDate,
    required List<(DateTime, double)> payments,
    DateTime? asOf,
  }) {
    final r = annualRatePct / 12 / 100;
    final end = asOf ?? DateTime.now();
    final sorted = [...payments]..sort((a, b) => a.$1.compareTo(b.$1));
    var balance = principal;
    var accrued = 0.0;
    var pi = 0;
    var cursor = startDate;
    while (cursor.isBefore(end)) {
      final next = cursor.addMonths(1);
      while (pi < sorted.length && sorted[pi].$1.isBefore(next)) {
        balance -= sorted[pi].$2;
        pi++;
      }
      if (balance > 0 && r > 0) {
        final interest = balance * r;
        accrued += interest;
        balance += interest;
      }
      cursor = next;
    }
    return accrued < 0 ? 0 : accrued;
  }

  /// Total interest paid to clear [principal] by paying a fixed [monthlyPayment]
  /// against a reducing balance. Returns [double.infinity] when the payment is
  /// too small to ever amortise. Drives the "interest saved by paying more" hint.
  static double projectedInterestFlexible({
    required double principal,
    required double annualRatePct,
    required double monthlyPayment,
    int maxMonths = 600,
  }) {
    final r = annualRatePct / 12 / 100;
    if (monthlyPayment <= 0) return double.infinity;
    var balance = principal;
    var totalInterest = 0.0;
    for (var m = 0; m < maxMonths; m++) {
      final interest = balance * r;
      // Payment can't cover even the interest → the debt never clears.
      if (monthlyPayment <= interest) return double.infinity;
      totalInterest += interest;
      balance += interest;
      balance -= monthlyPayment;
      if (balance <= 0.01) break;
    }
    return totalInterest;
  }

  /// The month-by-month payments that clear [principal] at a fixed
  /// [monthlyPayment] against a reducing balance; the last entry is the smaller
  /// residual payment. Returns null when the payment can never amortise the
  /// balance. Companion to [projectedInterestFlexible] for the outflow timeline.
  static List<double>? flexiblePaymentPlan({
    required double principal,
    required double annualRatePct,
    required double monthlyPayment,
    int maxMonths = 600,
  }) {
    if (monthlyPayment <= 0 || principal <= 0) return null;
    final r = annualRatePct / 12 / 100;
    final plan = <double>[];
    var balance = principal;
    for (var m = 0; m < maxMonths; m++) {
      final interest = balance * r;
      if (r > 0 && monthlyPayment <= interest) return null;
      balance += interest;
      final payment = math.min(monthlyPayment, balance);
      plan.add(payment);
      balance -= payment;
      if (balance <= 0.01) return plan;
    }
    return null;
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

  /// Merchant discount D behind a no-cost EMI: the bank finances (price − D)
  /// at [bankAnnualRatePct] and the EMIs sum back to exactly [price].
  /// Bisection — total repayment falls monotonically as D grows.
  static double noCostDiscount({
    required double price,
    required double bankAnnualRatePct,
    required int months,
  }) {
    if (months <= 0 || bankAnnualRatePct <= 0) return 0;
    var lo = 0.0, hi = price;
    for (var i = 0; i < 100; i++) {
      final d = (lo + hi) / 2;
      final total = reducingEmi(price - d, bankAnnualRatePct, months) * months;
      if (total > price) {
        lo = d;
      } else {
        hi = d;
      }
    }
    return (lo + hi) / 2;
  }

  /// Interest attributable to a fee that was financed into the loan
  /// (Slice-style): the fee's proportional share of the total interest.
  static double financedFeeInterestShare({
    required double principal,
    required double financedAmount,
    required double totalInterest,
  }) {
    if (principal <= 0) return 0;
    return financedAmount / principal * totalInterest;
  }

  /// Reveals the real cost of a "No Cost EMI" offer. The seller's discount
  /// reduces the financed principal to exactly (price − discount), so the
  /// bank's interest — and its GST — is computed on that discounted amount,
  /// not the sticker price.
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
    final discount = noCostDiscount(
        price: price, bankAnnualRatePct: bankAnnualRatePct, months: months);
    final bankInterest =
        reducingEmi(price - discount, bankAnnualRatePct, months) * months -
            (price - discount);
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
      merchantDiscount: discount,
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

  // ---- Day-count (actual/365) schedules ------------------------------------

  /// Whole days each period covers. The first runs from disbursal to the first
  /// due date and is usually irregular; [firstPeriodDays] overrides it when the
  /// lender's own count differs from the calendar (slice's KFS says 34 where
  /// the dates give 33).
  static List<int> _periodDays({
    required DateTime disbursalDate,
    required DateTime firstDueDate,
    required int months,
    int? firstPeriodDays,
  }) {
    final days = <int>[];
    var previous = disbursalDate.dateOnly;
    for (var i = 0; i < months; i++) {
      final due = firstDueDate.dateOnly.addMonths(i);
      days.add(
        i == 0 && firstPeriodDays != null
            ? firstPeriodDays
            : due.difference(previous).inDays,
      );
      previous = due;
    }
    return days;
  }

  /// Balance left after paying a level [emi] across the whole schedule, with no
  /// clamping — negative once the EMI overshoots. Strictly decreasing in [emi],
  /// which is what makes [dayCountEmi]'s bisection valid.
  static double _dayCountResidual({
    required double financedPrincipal,
    required double annualRatePct,
    required List<int> periodDays,
    required double emi,
  }) {
    final daily = annualRatePct / 100 / 365;
    var balance = financedPrincipal;
    for (final days in periodDays) {
      balance += balance * daily * days;
      balance -= emi;
    }
    return balance;
  }

  /// The level installment that exactly clears [financedPrincipal] under
  /// actual/365 accrual. There is no closed form once periods differ in length,
  /// so this bisects on the residual balance.
  ///
  /// Recovers slice's ₹7,936.53 from the loan terms alone.
  static double dayCountEmi({
    required double financedPrincipal,
    required double annualRatePct,
    required DateTime disbursalDate,
    required DateTime firstDueDate,
    required int months,
    int? firstPeriodDays,
  }) {
    if (months <= 0 || financedPrincipal <= 0) return 0;
    final periodDays = _periodDays(
      disbursalDate: disbursalDate,
      firstDueDate: firstDueDate,
      months: months,
      firstPeriodDays: firstPeriodDays,
    );
    var lo = 0.0;
    // Repaying everything (principal + simple interest) in the first period is
    // always more than enough, so the root is bracketed.
    var hi = financedPrincipal * (1 + annualRatePct / 100 * months / 12) + 1;
    for (var i = 0; i < 200; i++) {
      final mid = (lo + hi) / 2;
      if (_dayCountResidual(
            financedPrincipal: financedPrincipal,
            annualRatePct: annualRatePct,
            periodDays: periodDays,
            emi: mid,
          ) >
          0) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    // Lenders bill in whole paise, and the final installment absorbs whatever
    // residual that rounding leaves — which is exactly why slice's last EPI is
    // ₹7,936.47 against the ₹7,936.53 of the other eleven.
    return ((lo + hi) / 2 * 100).roundToDouble() / 100;
  }

  /// Roll a day-count loan forward, billing [emi] each period plus whatever the
  /// borrower paid on top. Interest for a period is
  /// `balance × rate/365 × days`, matching how personal-loan lenders actually
  /// compute it.
  ///
  /// A period never bills more than clears the loan, so the final row is the
  /// residual — and an extra payment simply ends the schedule early. That is
  /// what makes prepayment recompute the waste: fewer rows, less interest.
  ///
  /// [extraPayments] are matched to the due date they fall on (by calendar day).
  static DayCountRun runDayCount({
    required double financedPrincipal,
    required double annualRatePct,
    required DateTime disbursalDate,
    required DateTime firstDueDate,
    required int months,
    required double emi,
    int? firstPeriodDays,
    List<(DateTime, double)> extraPayments = const [],
  }) {
    if (months <= 0 || financedPrincipal <= 0) return const DayCountRun([]);
    final periodDays = _periodDays(
      disbursalDate: disbursalDate,
      firstDueDate: firstDueDate,
      months: months,
      firstPeriodDays: firstPeriodDays,
    );
    final daily = annualRatePct / 100 / 365;
    final rows = <DayCountRow>[];
    var balance = financedPrincipal;

    for (var i = 0; i < months; i++) {
      if (balance <= 0.01) break;
      final due = firstDueDate.dateOnly.addMonths(i);
      final interest = balance * daily * periodDays[i];
      final extra = extraPayments
          .where((p) => p.$1.dateOnly == due)
          .fold<double>(0, (s, p) => s + p.$2);
      // Never take more than settles the loan: this both absorbs the final
      // residual installment and lets a prepayment close the schedule early.
      final payment = math.min(emi + extra, balance + interest);
      final principalPart = payment - interest;
      final closing = balance - principalPart;
      rows.add(
        DayCountRow(
          number: i + 1,
          dueDate: due,
          days: periodDays[i],
          openingBalance: balance,
          interest: interest,
          principal: principalPart,
          payment: payment,
          closingBalance: closing < 0.01 ? 0 : closing,
        ),
      );
      balance = closing;
    }
    return DayCountRun(rows);
  }

  // ---- Advertised vs true annualised cost ----------------------------------

  /// The monthly IRR that discounts a level [emi] annuity back to [netAmount].
  static double _monthlyIrr({
    required double netAmount,
    required double emi,
    required int months,
  }) {
    if (netAmount <= 0 || emi <= 0 || months <= 0) return 0;
    double pv(double m) {
      if (m <= 1e-12) return emi * months;
      return emi * (1 - math.pow(1 + m, -months)) / m;
    }

    var lo = 1e-9, hi = 1.0;
    for (var i = 0; i < 300; i++) {
      final mid = (lo + hi) / 2;
      if (pv(mid) > netAmount) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  /// The APR lenders publish: the monthly IRR simply multiplied by 12, with no
  /// compounding. slice's KFS quotes 39.73% this way. Flattering but standard.
  static double nominalAprPct({
    required double netAmount,
    required double emi,
    required int months,
  }) =>
      _monthlyIrr(netAmount: netAmount, emi: emi, months: months) * 12 * 100;

  /// What the same loan actually costs once monthly compounding is honoured.
  /// On slice's loan this is 47.83% against the advertised 39.73%.
  static double effectiveAprPct({
    required double netAmount,
    required double emi,
    required int months,
  }) {
    final m = _monthlyIrr(netAmount: netAmount, emi: emi, months: months);
    return (math.pow(1 + m, 12) - 1) * 100;
  }

  // ---- Foreclosure ---------------------------------------------------------

  /// What it costs to clear a borrowing today: the principal still owed, the
  /// interest accrued since the last due date, the lender's foreclosure fee
  /// (a percent of the outstanding, floored at [feeMin]) and GST on that fee.
  ///
  /// [extraInterestDays] covers the days a lender tacks on for settlement —
  /// slice charges 1, which is invisible until you read the KFS footnote.
  static ForeclosureQuote foreclosureQuote({
    required double outstandingPrincipal,
    required double annualRatePct,
    required int daysSinceLastDue,
    required double feePct,
    required double feeMin,
    required int extraInterestDays,
    required bool gstOnFee,
    double gstRate = AppConstants.gstRate,
  }) {
    if (outstandingPrincipal <= 0) {
      return const ForeclosureQuote(
        outstandingPrincipal: 0,
        accruedInterest: 0,
        fee: 0,
        gstOnFee: 0,
      );
    }
    final daily = annualRatePct / 100 / 365;
    final days = daysSinceLastDue + extraInterestDays;
    final accrued = outstandingPrincipal * daily * days;
    final fee = math.max(outstandingPrincipal * feePct / 100, feeMin);
    return ForeclosureQuote(
      outstandingPrincipal: outstandingPrincipal,
      accruedInterest: accrued < 0 ? 0 : accrued,
      fee: fee,
      gstOnFee: gstOnFee ? gstOn(fee, rate: gstRate) : 0,
    );
  }
}
