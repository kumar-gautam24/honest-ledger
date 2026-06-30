import 'recurring_item.dart';

/// Dashboard roll-up across active recurring items.
class RecurringStats {
  const RecurringStats({
    required this.monthlyOutflow,
    required this.byType,
    required this.activeCount,
  });

  /// Total normalised monthly spend across all active items.
  final double monthlyOutflow;

  /// Monthly spend split by type.
  final Map<RecurringType, double> byType;
  final int activeCount;

  static const empty =
      RecurringStats(monthlyOutflow: 0, byType: {}, activeCount: 0);

  factory RecurringStats.from(List<RecurringItem> items) {
    final active = items.where((i) => i.isActive);
    final byType = <RecurringType, double>{};
    var total = 0.0;
    for (final i in active) {
      total += i.monthlyAmount;
      byType.update(
        i.type,
        (v) => v + i.monthlyAmount,
        ifAbsent: () => i.monthlyAmount,
      );
    }
    return RecurringStats(
      monthlyOutflow: total,
      byType: byType,
      activeCount: active.length,
    );
  }
}
