import '../../../../core/utils/finance_math.dart';
import 'borrowing.dart';
import 'repayment.dart';

/// A borrowing plus the derived figures the UI needs: how much has been repaid,
/// what's still owed, and how much has leaked away beyond the principal.
class BorrowingSummary {
  const BorrowingSummary({
    required this.borrowing,
    required this.repayments,
    required this.totalRepaid,
    required this.scheduledTotal,
    required this.outstanding,
    required this.wastedSoFar,
    required this.projectedExtra,
  });

  final Borrowing borrowing;
  final List<Repayment> repayments;

  /// Sum of all ledger payments.
  final double totalRepaid;

  /// Expected total to repay: EMI·n + processing fee + GST (or just principal +
  /// fees when no tenure/rate is set).
  final double scheduledTotal;

  /// Still owed against [scheduledTotal]. Never negative.
  final double outstanding;

  /// Money paid beyond the principal so far. Never negative.
  final double wastedSoFar;

  /// Expected total waste over the whole borrowing (scheduled − principal).
  final double projectedExtra;

  factory BorrowingSummary.from(Borrowing b, List<Repayment> repayments) {
    final totalRepaid = repayments.fold<double>(0, (s, r) => s + r.amount);
    final emi = b.tenureMonths > 0
        ? switch (b.rateType) {
            RateType.reducing =>
              FinanceMath.reducingEmi(b.principal, b.interestRatePct, b.tenureMonths),
            RateType.flat =>
              FinanceMath.flatEmi(b.principal, b.interestRatePct, b.tenureMonths),
          }
        : 0.0;
    final scheduledTotal = b.tenureMonths > 0
        ? emi * b.tenureMonths + b.processingFee + b.gstOnFee
        : b.principal + b.processingFee + b.gstOnFee;
    final outstanding = scheduledTotal - totalRepaid;
    final projectedExtra = scheduledTotal - b.principal;
    return BorrowingSummary(
      borrowing: b,
      repayments: repayments,
      totalRepaid: totalRepaid,
      scheduledTotal: scheduledTotal,
      outstanding: outstanding < 0 ? 0 : outstanding,
      wastedSoFar: FinanceMath.extraPaid(
        principal: b.principal,
        totalRepaid: totalRepaid,
      ),
      projectedExtra: projectedExtra < 0 ? 0 : projectedExtra,
    );
  }

  /// 0..1 share of the scheduled total already repaid.
  double get progress =>
      scheduledTotal <= 0 ? 0 : (totalRepaid / scheduledTotal).clamp(0, 1);
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
