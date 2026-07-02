import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../money_leak/presentation/controllers/money_leak_providers.dart';
import '../../recurring/presentation/controllers/recurring_providers.dart';
import '../domain/entities/month_plan.dart';
import '../domain/entities/monthly_obligation_stats.dart';
import '../domain/entities/outflow_projection.dart';
import 'obligation_view.dart';

part 'home_providers.g.dart';

/// The unified home feed: every borrowing and recurring item as one list of
/// [ObligationView]s, sorted by urgency (overdue and soonest-due first). The
/// filter is applied in the UI so the sorted list is computed once.
@riverpod
List<ObligationView> homeFeed(Ref ref) {
  final borrowings =
      ref.watch(borrowingSummariesProvider).asData?.value ?? const [];
  final recurring = ref.watch(recurringItemsProvider).asData?.value ?? const [];

  return <ObligationView>[
    ...borrowings.map(BorrowingObligation.new),
    ...recurring.map(RecurringObligation.new),
  ]..sort((a, b) => a.sortKey.compareTo(b.sortKey));
}

/// True while either underlying stream has yet to deliver its first value.
@riverpod
bool homeFeedLoading(Ref ref) {
  final b = ref.watch(borrowingSummariesProvider);
  final r = ref.watch(recurringItemsProvider);
  return (b.isLoading && !b.hasValue) || (r.isLoading && !r.hasValue);
}

/// The true committed monthly outgo — EMIs + loan plans + recurring — split by
/// kind. Drives the home "PER MONTH" statement line.
@riverpod
MonthlyObligationStats monthlyObligationStats(Ref ref) {
  final borrowings =
      ref.watch(borrowingSummariesProvider).asData?.value ?? const [];
  final recurring = ref.watch(recurringItemsProvider).asData?.value ?? const [];
  return MonthlyObligationStats.from(borrowings, recurring);
}

/// The current calendar month as a statement: due, paid, remaining.
@riverpod
MonthPlan monthPlan(Ref ref) {
  final borrowings =
      ref.watch(borrowingSummariesProvider).asData?.value ?? const [];
  final recurring = ref.watch(recurringItemsProvider).asData?.value ?? const [];
  return MonthPlan.from(
    summaries: borrowings,
    items: recurring,
    now: DateTime.now(),
  );
}

/// Month-by-month outflow over the coming year, with freed-up moments.
@riverpod
OutflowProjection outflowProjection(Ref ref) {
  final borrowings =
      ref.watch(borrowingSummariesProvider).asData?.value ?? const [];
  final recurring = ref.watch(recurringItemsProvider).asData?.value ?? const [];
  return OutflowProjection.from(
    summaries: borrowings,
    items: recurring,
    now: DateTime.now(),
  );
}
