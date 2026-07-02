import '../../../money_leak/domain/entities/borrowing_summary.dart';

/// How much a single lender has cost the user — the rows of the Leak
/// statement's "where it leaks" ranking. Closed borrowings still count:
/// their waste is real history.
class LenderWaste {
  const LenderWaste({
    required this.lenderName,
    required this.wastedSoFar,
    required this.projectedExtra,
    required this.count,
  });

  final String lenderName;

  /// Non-principal money already paid to this lender.
  final double wastedSoFar;

  /// Expected lifetime extra across this lender's borrowings.
  final double projectedExtra;

  /// Number of borrowings with this lender.
  final int count;

  /// Aggregate per lender, worst [projectedExtra] first.
  static List<LenderWaste> rank(List<BorrowingSummary> summaries) {
    final byLender = <String, ({double wasted, double projected, int count})>{};
    for (final s in summaries) {
      final prev = byLender[s.borrowing.lenderName] ??
          (wasted: 0.0, projected: 0.0, count: 0);
      byLender[s.borrowing.lenderName] = (
        wasted: prev.wasted + s.wastedSoFar,
        projected: prev.projected + s.projectedExtra,
        count: prev.count + 1,
      );
    }
    final ranked = [
      for (final MapEntry(:key, :value) in byLender.entries)
        LenderWaste(
          lenderName: key,
          wastedSoFar: value.wasted,
          projectedExtra: value.projected,
          count: value.count,
        ),
    ]..sort((a, b) => b.projectedExtra.compareTo(a.projectedExtra));
    return ranked;
  }
}
