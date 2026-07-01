import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../money_leak/presentation/controllers/money_leak_providers.dart';
import '../../recurring/presentation/controllers/recurring_providers.dart';
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
