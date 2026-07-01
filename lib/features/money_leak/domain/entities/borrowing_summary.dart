import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/finance_math.dart';
import 'borrowing.dart';
import 'repayment.dart';

/// A borrowing plus the derived figures the UI needs: how much has been repaid,
/// what's still owed, and how much has leaked away beyond the principal.
///
/// The derivation splits by [Borrowing.kind]: a fixed EMI carries a dated
/// [schedule] and tracks progress in installments (N of tenure); a flexible loan
/// accrues interest on the outstanding balance and tracks a minimum due.
class BorrowingSummary {
  const BorrowingSummary({
    required this.borrowing,
    required this.repayments,
    required this.totalRepaid,
    required this.scheduledTotal,
    required this.outstanding,
    required this.wastedSoFar,
    required this.projectedExtra,
    required this.schedule,
  });

  final Borrowing borrowing;
  final List<Repayment> repayments;

  /// Sum of all ledger payments.
  final double totalRepaid;

  /// Expected total to repay: every installment (incl. GST + fees) for an EMI,
  /// or principal + fees for a flexible loan.
  final double scheduledTotal;

  /// Still owed. For an EMI this is against [scheduledTotal]; for a flexible loan
  /// it is the interest-accrued balance. Never negative.
  final double outstanding;

  /// Money paid beyond the principal so far. Never negative.
  final double wastedSoFar;

  /// Expected total waste over the whole borrowing (scheduled − principal).
  final double projectedExtra;

  /// The dated installment plan. Empty for a flexible loan.
  final List<EmiInstallment> schedule;

  factory BorrowingSummary.from(Borrowing b, List<Repayment> repayments) {
    final totalRepaid = repayments.fold<double>(0, (s, r) => s + r.amount);

    if (b.isEmi && b.tenureMonths > 0) {
      final schedule = FinanceMath.emiSchedule(
        principal: b.principal,
        annualRatePct: b.interestRatePct,
        months: b.tenureMonths,
        startDate: b.startDate,
        rateType: b.rateType,
        gstOnInterest: b.gstOnInterest,
        feeValue: b.processingFee,
      );
      final scheduledTotal = schedule.fold<double>(0, (s, e) => s + e.total);
      final outstanding = scheduledTotal - totalRepaid;
      final projectedExtra = scheduledTotal - b.principal;
      // Interest + GST + fees actually incurred = the non-principal portion of
      // every installment already cleared. (A repayment's amount is mostly
      // principal early on, so counting `repaid − principal` would wrongly read
      // zero until the whole loan is paid off.)
      final paidNums = {
        for (final r in repayments)
          if (r.installmentNo != null) r.installmentNo!,
      };
      final wastedSoFar = schedule
          .where((e) => paidNums.contains(e.number))
          .fold<double>(0, (s, e) => s + (e.total - e.principal));
      return BorrowingSummary(
        borrowing: b,
        repayments: repayments,
        totalRepaid: totalRepaid,
        scheduledTotal: scheduledTotal,
        outstanding: outstanding < 0 ? 0 : outstanding,
        wastedSoFar: wastedSoFar,
        projectedExtra: projectedExtra < 0 ? 0 : projectedExtra,
        schedule: schedule,
      );
    }

    // Flexible loan: outstanding accrues interest on the reducing balance.
    final outstanding = FinanceMath.outstandingFlexible(
      principal: b.principal,
      annualRatePct: b.interestRatePct,
      startDate: b.startDate,
      payments: [for (final r in repayments) (r.date, r.amount)],
    );
    final scheduledTotal = b.principal + b.processingFee + b.gstOnFee;
    return BorrowingSummary(
      borrowing: b,
      repayments: repayments,
      totalRepaid: totalRepaid,
      scheduledTotal: scheduledTotal,
      outstanding: outstanding,
      wastedSoFar:
          FinanceMath.extraPaid(principal: b.principal, totalRepaid: totalRepaid),
      projectedExtra: (scheduledTotal - b.principal).clamp(0, double.infinity),
      schedule: const [],
    );
  }

  bool get isEmi => borrowing.isEmi && schedule.isNotEmpty;

  /// Total installments in a fixed EMI's plan.
  int get totalInstallments => schedule.length;

  /// Installment numbers that have a logged payment against them.
  Set<int> get paidInstallmentNumbers =>
      {for (final r in repayments) if (r.installmentNo != null) r.installmentNo!};

  int get paidInstallments => paidInstallmentNumbers.length;

  bool isInstallmentPaid(int number) => paidInstallmentNumbers.contains(number);

  /// The next unpaid installment, or null once the plan is cleared.
  EmiInstallment? get nextDueInstallment {
    for (final e in schedule) {
      if (!isInstallmentPaid(e.number)) return e;
    }
    return null;
  }

  /// Unpaid installments whose due date has already passed — money the user has
  /// missed or simply not logged yet.
  List<EmiInstallment> get overdueInstallments => [
        for (final e in schedule)
          if (!isInstallmentPaid(e.number) && e.dueDate.daysFromNow < 0) e,
      ];

  int get overdueCount => overdueInstallments.length;

  double get overdueAmount =>
      overdueInstallments.fold<double>(0, (s, e) => s + e.total);

  /// Minimum payment allowed on a flexible loan.
  double get minDue => borrowing.minPayment;

  /// Total interest saved over the life of a flexible loan by paying [monthly]
  /// instead of the minimum. Zero when it doesn't apply or doesn't help.
  double interestSavedIfPaid(double monthly) {
    if (isEmi || minDue <= 0 || monthly <= minDue) return 0;
    final atMin = FinanceMath.projectedInterestFlexible(
      principal: outstanding,
      annualRatePct: borrowing.interestRatePct,
      monthlyPayment: minDue,
    );
    final atMore = FinanceMath.projectedInterestFlexible(
      principal: outstanding,
      annualRatePct: borrowing.interestRatePct,
      monthlyPayment: monthly,
    );
    if (!atMin.isFinite || !atMore.isFinite) return 0;
    final saved = atMin - atMore;
    return saved < 0 ? 0 : saved;
  }

  /// 0..1 progress. Installment share for an EMI; repaid share of the balance
  /// for a flexible loan.
  double get progress {
    if (isEmi) {
      return totalInstallments == 0
          ? 0
          : (paidInstallments / totalInstallments).clamp(0, 1);
    }
    final denom = totalRepaid + outstanding;
    return denom <= 0 ? 0 : (totalRepaid / denom).clamp(0, 1);
  }

  /// e.g. `3/12` for an EMI; null for a flexible loan.
  String? get installmentLabel =>
      isEmi ? '$paidInstallments/$totalInstallments' : null;
}

/// Roll-up across every borrowing — drives the dashboard hero.
class LifetimeStats {
  const LifetimeStats({
    required this.totalBorrowed,
    required this.totalRepaid,
    required this.totalWasted,
    required this.projectedWaste,
    required this.count,
  });

  final double totalBorrowed;
  final double totalRepaid;

  /// Extra paid beyond principal so far, across all borrowings.
  final double totalWasted;

  /// Extra expected over the lifetime of all borrowings.
  final double projectedWaste;
  final int count;

  static const empty = LifetimeStats(
    totalBorrowed: 0,
    totalRepaid: 0,
    totalWasted: 0,
    projectedWaste: 0,
    count: 0,
  );

  factory LifetimeStats.from(List<BorrowingSummary> summaries) {
    var borrowed = 0.0, repaid = 0.0, wasted = 0.0, projected = 0.0;
    for (final s in summaries) {
      borrowed += s.borrowing.principal;
      repaid += s.totalRepaid;
      wasted += s.wastedSoFar;
      projected += s.projectedExtra;
    }
    return LifetimeStats(
      totalBorrowed: borrowed,
      totalRepaid: repaid,
      totalWasted: wasted,
      projectedWaste: projected,
      count: summaries.length,
    );
  }
}
