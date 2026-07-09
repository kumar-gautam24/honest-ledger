import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../lenders/domain/entities/lender.dart';
import 'borrowing_summary.dart';

/// What foreclosing a fixed EMI today actually costs, and whether it is worth
/// it — priced from the lender's own published rules rather than a number the
/// user has to look up and type.
///
/// The lender may be unknown (a hand-entered borrowing, a catalog entry with no
/// terms). In that case [rulesKnown] is false and the fee is left at zero: the
/// app would rather admit ignorance than invent a charge.
class ForeclosureEstimate {
  const ForeclosureEstimate({
    required this.quote,
    required this.interestAvoided,
    required this.rulesKnown,
    required this.insideFreeWindow,
    required this.extraInterestDays,
  });

  final ForeclosureQuote quote;

  /// Interest on the installments the user will never now pay.
  final double interestAvoided;

  /// Whether the lender's foreclosure terms are known at all.
  final bool rulesKnown;

  /// Inside the lender's free-cancellation window (HDFC 30 days, Axis 7), where
  /// the fee is waived. Note the processing fee is not refunded.
  final bool insideFreeWindow;

  /// Settlement days the lender tacks interest on for. slice charges 1.
  final int extraInterestDays;

  /// Foreclosing costs nothing at all — no fee, no extra interest.
  bool get isFree => quote.cost <= 0.005;

  /// Closing early saves more than it costs.
  bool get worthIt => interestAvoided > quote.cost;

  /// Net gain from foreclosing today. Negative when the fee outweighs the
  /// interest dodged — which is exactly when a lender's 3% bites.
  double get netSaving => interestAvoided - quote.cost;

  static ForeclosureEstimate of({
    required BorrowingSummary summary,
    required Lender? lender,
    DateTime? asOf,
  }) {
    final b = summary.borrowing;
    final now = (asOf ?? DateTime.now()).dateOnly;
    final outstanding = summary.remainingPrincipal;

    // Days of interest since the last installment fell due — a foreclosure
    // settles the stub period, not just the principal.
    final passed = summary.schedule
        .where((e) => !e.dueDate.isAfter(now))
        .fold<DateTime?>(null, (last, e) => e.dueDate);
    final lastDue = passed ?? b.startDate.dateOnly;
    final daysSinceLastDue = now.difference(lastDue).inDays.clamp(0, 400);

    final window = lender?.foreclosureFreeWindowDays;
    final insideFreeWindow =
        window != null && now.difference(b.startDate.dateOnly).inDays <= window;

    final rulesKnown = lender?.foreclosurePct != null;
    final extraDays = lender?.foreclosureExtraInterestDays ?? 0;

    final quote = FinanceMath.foreclosureQuote(
      outstandingPrincipal: outstanding,
      annualRatePct: b.interestRatePct,
      daysSinceLastDue: daysSinceLastDue,
      feePct: insideFreeWindow ? 0 : (lender?.foreclosurePct ?? 0),
      feeMin: insideFreeWindow ? 0 : (lender?.foreclosureMin ?? 0),
      extraInterestDays: extraDays,
      gstOnFee: lender?.foreclosureGst ?? true,
    );

    // Interest the user escapes: everything still scheduled, minus the stub
    // period they must settle anyway.
    final futureInterest = summary.schedule
        .where((e) => !summary.isInstallmentPaid(e.number))
        .fold<double>(0, (s, e) => s + e.interest);
    final avoided = (futureInterest - quote.accruedInterest)
        .clamp(0.0, double.infinity);

    return ForeclosureEstimate(
      quote: quote,
      interestAvoided: avoided,
      rulesKnown: rulesKnown,
      insideFreeWindow: insideFreeWindow,
      extraInterestDays: extraDays,
    );
  }
}
